//====================================================================
//                 VEKTOR AGENT DELEGATION MANAGER                   
//            Autonomous Subagent Spawning & Task Routing            
//====================================================================
const std = @import("std");

pub const AgentStatus = enum {
    Idle,
    Executing,
    Completed,
    Failed,
};

pub const Subagent = struct {
    id: u64,
    role: []const u8,
    status: AgentStatus,
    tasks_completed: u32,

    pub fn init(id: u64, role: []const u8) Subagent {
        return .{
            .id = id,
            .role = role,
            .status = .Idle,
            .tasks_completed = 0,
        };
    }
};

pub const AgentManager = struct {
    allocator: std.mem.Allocator,
    agents: std.ArrayList(Subagent),

    pub fn init(allocator: std.mem.Allocator) AgentManager {
        return .{
            .allocator = allocator,
            .agents = .{ .items = &.{}, .capacity = 0 },
        };
    }

    pub fn deinit(self: *AgentManager) void {
        self.agents.deinit(self.allocator);
    }

    pub fn registerAgent(self: *AgentManager, id: u64, role: []const u8) !void {
        const agent = Subagent.init(id, role);
        try self.agents.append(self.allocator, agent);
        std.debug.print(" [VEKTOR AGENT MANAGER] REGISTERED SUBAGENT 0x{X:0>16} | ROLE: {s}\n", .{ id, role });
    }
};
