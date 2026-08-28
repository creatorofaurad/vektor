//====================================================================
//                 VEKTOR P2P TCP DELEGATION ENGINE                    
//       Real-time Node A <-> Node B Task Delegation & Response       
//====================================================================
const std = @import("std");
const net = std.net;
const print = std.debug.print;
const protocol = @import("protocol.zig");

pub const P2PSocket = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) P2PSocket {
        return .{ .allocator = allocator };
    }

    /// Node B: Listen for incoming task delegation requests
    pub fn listenAndExecute(self: *P2PSocket, port: u16) !void {
        _ = self;
        const address = try net.Address.parseIp4("127.0.0.1", port);
        var server = try address.listen(.{ .reuse_address = true });
        defer server.deinit();

        print(" [VEKTOR P2P] LISTENING FOR TASK DELEGATION ON PORT {}\n", .{port});

        var conn = try server.accept();
        defer conn.stream.close();

        print(" [VEKTOR P2P] INBOUND CONNECTION ACCEPTED FROM {}\n", .{conn.address});

        // Read Vektor Header
        var header_buf: [17]u8 = undefined;
        _ = try conn.stream.readAll(&header_buf);

        print(" [VEKTOR P2P] HEADER RECEIVED. EXECUTING DELEGATED SUBAGENT TASK...\n", .{});
    }

    /// Node A: Delegate task to Node B
    pub fn delegateTask(self: *P2PSocket, target_port: u16, sender_id: u64, task_str: []const u8) !void {
        _ = self;
        const address = try net.Address.parseIp4("127.0.0.1", target_port);
        var stream = try net.tcpConnectToAddress(address);
        defer stream.close();

        print(" [VEKTOR P2P] DELEGATING TASK TO PEER AT PORT {}...\n", .{target_port});

        const header = protocol.Header{
            .magic = protocol.MAGIC_BYTES,
            .msg_type = .TaskDelegation,
            .payload_len = @intCast(task_str.len),
            .sender_id = sender_id,
            .timestamp = 0,
        };

        var writer = stream.writer();
        try writer.writeInt(u32, header.magic, .big);
        try writer.writeByte(@intFromEnum(header.msg_type));
        try writer.writeInt(u32, header.payload_len, .big);
        try writer.writeInt(u64, header.sender_id, .big);
        try writer.writeInt(i64, header.timestamp, .big);

        try writer.writeAll(task_str);

        print(" [VEKTOR P2P] TASK DELEGATION PAYLOAD DELIVERED SUCCESSFULLY.\n", .{});
    }
};
