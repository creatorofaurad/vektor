//====================================================================
//                     VEKTOR PROTOCOL SPEC v1.0                      
//           Zero-Copy Binary Serialization & Wire Protocol          
//====================================================================
const std = @import("std");

pub const MAGIC_BYTES: u32 = 0x564B5452; // "VKTR"

pub const MessageType = enum(u8) {
    Handshake       = 0x01,
    TaskDelegation  = 0x02,
    ComputeShare    = 0x03,
    Heartbeat       = 0x04,
    ResultPayload   = 0x05,
    EmergencyPurge  = 0x06,
};

pub const HEADER_SIZE = 17;

pub const Header = packed struct {
    magic: u32 = MAGIC_BYTES,
    msg_type: MessageType,
    payload_len: u32,
    sender_id: u64,

    pub fn validate(bytes: []const u8) !Header {
        if (bytes.len < HEADER_SIZE) return error.InvalidFrameSize;

        const magic = std.mem.readInt(u32, bytes[0..4], .big);
        if (magic != MAGIC_BYTES) return error.InvalidMagic;

        const msg_type_val = bytes[4];
        const msg_type: MessageType = @enumFromInt(msg_type_val);

        const payload_len = std.mem.readInt(u32, bytes[5..9], .big);
        const sender_id = std.mem.readInt(u64, bytes[9..17], .big);

        return .{
            .magic = magic,
            .msg_type = msg_type,
            .payload_len = payload_len,
            .sender_id = sender_id,
        };
    }
};

pub const TaskPayload = struct {
    task_id: u64,
    agent_role: []const u8,
    instruction: []const u8,

    pub fn serialize(self: TaskPayload, allocator: std.mem.Allocator) ![]u8 {
        var list = std.ArrayList(u8).init(allocator);
        var writer = list.writer();

        try writer.writeInt(u64, self.task_id, .big);
        try writer.writeInt(u32, @intCast(self.agent_role.len), .big);
        try writer.writeAll(self.agent_role);
        try writer.writeInt(u32, @intCast(self.instruction.len), .big);
        try writer.writeAll(self.instruction);

        return list.toOwnedSlice();
    }
};
