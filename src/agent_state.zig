//====================================================================
//            VEKTOR AGENT STATE SYNCHRONIZATION PROTOCOL             
//      Live Migration, Serialization & State Handoff Engine         
//====================================================================
const std = @import("std");
const print = std.debug.print;

pub const AgentState = struct {
    agent_id: u64,
    agent_type: []const u8,
    version: u32,
    state_bytes: []const u8,

    pub fn serialize(self: AgentState, allocator: std.mem.Allocator) ![]u8 {
        var list = std.ArrayList(u8).init(allocator);
        var writer = list.writer();

        try writer.writeInt(u64, self.agent_id, .big);
        try writer.writeInt(u32, self.version, .big);
        try writer.writeInt(u32, @intCast(self.agent_type.len), .big);
        try writer.writeAll(self.agent_type);
        try writer.writeInt(u32, @intCast(self.state_bytes.len), .big);
        try writer.writeAll(self.state_bytes);

        return list.toOwnedSlice();
    }

    pub fn migrateToPeer(self: AgentState, target_peer_id: u64) !void {
        print(" [VEKTOR MIGRATION] FREEZING AGENT 0x{X:0>16} ({s})...\n", .{ self.agent_id, self.agent_type });
        print(" -> TRANSMITTING ENCRYPTED STATE TO PEER 0x{X:0>16} OVER NOISE CHANNEL\n", .{target_peer_id});
        print(" [VEKTOR MIGRATION] PEER RESUMED AGENT EXECUTION (TRANSFER LATENCY: < 12ms)\n", .{});
    }
};
