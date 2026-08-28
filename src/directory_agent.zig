//====================================================================
//               VEKTOR DISTRIBUTED DIRECTORY & ACTOR MAILBOX         
//      Semantic Capabilities Registry & Inter-Agent Routing         
//====================================================================
const std = @import("std");
const print = std.debug.print;

pub const CapabilityRecord = struct {
    peer_id: u64,
    agent_type: []const u8,
    cores: u8,
    ram_mb: u32,
    supported_ops: []const u8,
};

pub const DirectoryAgent = struct {
    allocator: std.mem.Allocator,
    registry: std.ArrayList(CapabilityRecord),

    pub fn init(allocator: std.mem.Allocator) DirectoryAgent {
        return .{
            .allocator = allocator,
            .registry = std.ArrayList(CapabilityRecord){ .items = &.{}, .capacity = 0 },
        };
    }

    pub fn deinit(self: *DirectoryAgent) void {
        self.registry.deinit(self.allocator);
    }

    pub fn registerCapability(self: *DirectoryAgent, peer_id: u64, agent_type: []const u8, ops: []const u8) !void {
        try self.registry.append(self.allocator, .{
            .peer_id = peer_id,
            .agent_type = agent_type,
            .cores = 8,
            .ram_mb = 16384,
            .supported_ops = ops,
        });
        print(" [VEKTOR DIRECTORY] REGISTERED CAPABILITY: PEER 0x{X:0>16} -> {s} [{s}]\n", .{ peer_id, agent_type, ops });
    }

    pub fn routeAgentMessage(self: *DirectoryAgent, from_id: u64, to_id: u64, msg: []const u8) !void {
        _ = self;
        print(" [VEKTOR ACTOR MAILBOX] AGENT 0x{X:0>16} -> AGENT 0x{X:0>16}: \"{s}\"\n", .{ from_id, to_id, msg });
    }
};
