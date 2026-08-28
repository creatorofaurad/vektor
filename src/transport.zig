//====================================================================
//                 VEKTOR P2P SOCKET TRANSPORT ENGINE                 
//       Low-Latency Binary Socket Communication & Message Dispatch   
//====================================================================
const std = @import("std");
const net = std.net;
const protocol = @import("protocol.zig");

pub const SocketTransport = struct {
    allocator: std.mem.Allocator,
    port: u16,

    pub fn init(allocator: std.mem.Allocator, port: u16) SocketTransport {
        return .{
            .allocator = allocator,
            .port = port,
        };
    }

    pub fn sendHeader(stream: net.Stream, header: protocol.Header) !void {
        var writer = stream.writer();
        try writer.writeInt(u32, header.magic, .big);
        try writer.writeByte(@intFromEnum(header.msg_type));
        try writer.writeInt(u32, header.payload_len, .big);
        try writer.writeInt(u64, header.sender_id, .big);
    }
};
