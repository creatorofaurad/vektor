//====================================================================
//                 VEKTOR P2P NODE DISCOVERY ENGINE                   
//       UDP Multicast & Local Network Peer Discovery Protocol        
//====================================================================
const std = @import("std");
const net = std.net;
const print = std.debug.print;

pub const DISCOVERY_PORT: u16 = 9091;
pub const MULTICAST_ADDR = "239.255.255.250";

pub const PeerInfo = struct {
    node_id: u64,
    ip_address: [16]u8,
    port: u16,
    last_seen_ms: i64,
};

pub const DiscoveryEngine = struct {
    allocator: std.mem.Allocator,
    node_id: u64,

    pub fn init(allocator: std.mem.Allocator, node_id: u64) DiscoveryEngine {
        return .{
            .allocator = allocator,
            .node_id = node_id,
        };
    }

    pub fn broadcastPresence(self: *DiscoveryEngine) !void {
        print(" [VEKTOR DISCOVERY] BROADCASTING NODE PRESENCE 0x{X:0>16} ON UDP {}\n", .{ self.node_id, DISCOVERY_PORT });
        // Send UDP Multicast beacon frame
    }
};
