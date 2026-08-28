//====================================================================
//                     VEKTOR MESH KERNEL v6.0                        
//      Real P2P Node Daemon — real TCP serve + task delegation       
//====================================================================
const std = @import("std");
const cli = @import("cli.zig");

pub const protocol             = @import("protocol.zig");
pub const agent_mgr            = @import("agent_manager.zig");
pub const transport            = @import("transport.zig");
pub const discovery            = @import("node_discovery.zig");
pub const ipc_mem              = @import("ipc_mem.zig");
pub const p2p_socket           = @import("p2p_socket.zig");
pub const noise_handshake      = @import("noise_handshake.zig");
pub const peer_table           = @import("peer_table.zig");
pub const tensor_task          = @import("tensor_task.zig");
pub const work_stealing        = @import("work_stealing.zig");
pub const gossip_mesh          = @import("gossip_mesh.zig");
pub const agent_state          = @import("agent_state.zig");
pub const directory_agent      = @import("directory_agent.zig");
pub const transformer_pipeline = @import("transformer_pipeline.zig");

pub fn main(startup: std.process.Init) !void {
    const allocator = startup.gpa;

    // Collect args into a slice of strings using Zig 0.16.0 Args.Iterator
    var args_list = std.ArrayList([]const u8){ .items = &.{}, .capacity = 0 };
    defer args_list.deinit(allocator);

    var it = try std.process.Args.Iterator.initAllocator(startup.minimal.args, allocator);
    defer it.deinit();
    while (it.next()) |arg| {
        try args_list.append(allocator, arg);
    }

    try cli.Cli.parseAndExecute(allocator, args_list.items);
}
