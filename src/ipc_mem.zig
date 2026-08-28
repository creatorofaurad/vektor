const std = @import("std");
const windows = std.os.windows;

pub const CACHE_LINE: usize = 64;

pub const BlockNode = struct {
    next: ?*BlockNode,
};

/// IpcMem provides a zero-copy, SIMD-aligned (64-byte) shared memory buffer
/// for sub-millisecond inter-process communication on Windows with fixed-size block recycling.
pub const IpcMem = struct {
    name: []const u8,
    size: usize,
    block_size: usize,
    /// 64-byte aligned pointer for AVX-512 / SIMD operations
    ptr: [*]align(CACHE_LINE) u8,
    handle: windows.HANDLE,
    free_head: ?*BlockNode,

    // Win32 API Definitions for shared memory
    const kernel32 = struct {
        extern "kernel32" fn CreateFileMappingA(
            hFile: windows.HANDLE,
            lpFileMappingAttributes: ?*anyopaque,
            flProtect: windows.DWORD,
            dwMaximumSizeHigh: windows.DWORD,
            dwMaximumSizeLow: windows.DWORD,
            lpName: ?[*:0]const u8,
        ) callconv(.c) ?windows.HANDLE;

        extern "kernel32" fn MapViewOfFile(
            hFileMappingObject: windows.HANDLE,
            dwDesiredAccess: windows.DWORD,
            dwFileOffsetHigh: windows.DWORD,
            dwFileOffsetLow: windows.DWORD,
            dwNumberOfBytesToMap: windows.SIZE_T,
        ) callconv(.c) ?*anyopaque;

        extern "kernel32" fn UnmapViewOfFile(
            lpBaseAddress: ?*const anyopaque,
        ) callconv(.c) windows.BOOL;
    };

    /// Initialize or open a named shared memory segment with block recycling
    pub fn init(name: []const u8, size: usize, requested_block_size: usize) !IpcMem {
        var name_buf: [256]u8 = undefined;
        if (name.len >= 256) return error.NameTooLong;
        
        // Null-terminate the name for Windows API
        @memcpy(name_buf[0..name.len], name);
        name_buf[name.len] = 0;
        
        const PAGE_READWRITE = 0x04;
        const FILE_MAP_ALL_ACCESS = 0xF001F;

        // Use INVALID_HANDLE_VALUE to allocate from the paging file
        const handle = kernel32.CreateFileMappingA(
            windows.INVALID_HANDLE_VALUE,
            null,
            PAGE_READWRITE,
            @as(u32, @intCast((size >> 32) & 0xFFFFFFFF)),
            @as(u32, @intCast(size & 0xFFFFFFFF)),
            @as(?[*:0]const u8, @ptrCast(&name_buf)),
        );

        const h_map = handle orelse return error.CreateFileMappingFailed;
        
        const mapped_ptr = kernel32.MapViewOfFile(
            h_map,
            FILE_MAP_ALL_ACCESS,
            0,
            0,
            size,
        );

        if (mapped_ptr == null) {
            windows.CloseHandle(h_map);
            return error.MapViewOfFileFailed;
        }

        // Ensure 64-byte alignment (MapViewOfFile returns 64K-aligned addresses by default)
        const addr = @intFromPtr(mapped_ptr);
        if (addr % CACHE_LINE != 0) {
            windows.CloseHandle(h_map);
            return error.AlignmentFailed;
        }

        const ptr: [*]align(CACHE_LINE) u8 = @ptrCast(@alignCast(mapped_ptr.?));

        // Align block size to CACHE_LINE and ensure it can fit BlockNode
        const aligned_block_size = @max(
            std.mem.alignForward(usize, requested_block_size, CACHE_LINE),
            std.mem.alignForward(usize, @sizeOf(BlockNode), CACHE_LINE),
        );

        var self = IpcMem{
            .name = name,
            .size = size,
            .block_size = aligned_block_size,
            .ptr = ptr,
            .handle = h_map,
            .free_head = null,
        };

        // Initialize intrusive free-list for zero-copy block recycling
        var offset: usize = 0;
        while (offset + aligned_block_size <= size) : (offset += aligned_block_size) {
            const node: *BlockNode = @ptrCast(@alignCast(&self.ptr[offset]));
            node.next = self.free_head;
            self.free_head = node;
        }

        return self;
    }

    /// Rent a zero-copy aligned block from the pool
    pub fn allocBlock(self: *IpcMem) ?[*]align(CACHE_LINE) u8 {
        const node = self.free_head orelse return null;
        self.free_head = node.next;
        return @ptrCast(@alignCast(node));
    }

    /// Return a zero-copy aligned block to the pool
    pub fn freeBlock(self: *IpcMem, block_ptr: [*]align(CACHE_LINE) u8) void {
        const node: *BlockNode = @ptrCast(@alignCast(block_ptr));
        node.next = self.free_head;
        self.free_head = node;
    }

    /// Unmap memory and close handle
    pub fn deinit(self: *IpcMem) void {
        _ = kernel32.UnmapViewOfFile(self.ptr);
        windows.CloseHandle(self.handle);
    }
};
