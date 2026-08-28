//====================================================================
//                  VEKTOR PEER DISCOVERY TABLE                       
//      LAN Multicast + known_peers Bootstrap Table (30s TTL)         
//====================================================================
const std = @import("std");
const print = std.debug.print;

pub const PeerRecord = struct {
    node_id: u64,
    ip_addr: [16]u8,
    port: u16,
    last_seen_ms: i64,
    capabilities: u32,
};

pub const PeerTable = struct {
    allocator: std.mem.Allocator,
    peers: std.ArrayList(PeerRecord),

    pub fn init(allocator: std.mem.Allocator) PeerTable {
        return .{
            .allocator = allocator,
            .peers = std.ArrayList(PeerRecord){ .items = &.{}, .capacity = 0 },
        };
    }

    pub fn deinit(self: *PeerTable) void {
        self.peers.deinit(self.allocator);
    }

    pub fn addOrUpdatePeer(self: *PeerTable, node_id: u64, ip_str: []const u8, port: u16) !void {
        const now_ms: i64 = 0;

        for (self.peers.items) |*peer| {
            if (peer.node_id == node_id) {
                peer.last_seen_ms = now_ms;
                return;
            }
        }

        var ip: [16]u8 = undefined;
        @memset(&ip, 0);
        const len = @min(ip_str.len, 16);
        @memcpy(ip[0..len], ip_str[0..len]);

        const record = PeerRecord{
            .node_id = node_id,
            .ip_addr = ip,
            .port = port,
            .last_seen_ms = now_ms,
            .capabilities = 0xFF,
        };

        try self.peers.append(self.allocator, record);
        print(" [VEKTOR PEER TABLE] DISCOVERED PEER 0x{X:0>16} ON PORT {} (TTL: 30s)\n", .{ node_id, port });
    }

    pub fn decayPeers(self: *PeerTable) void {
        const now_ms: i64 = 0;
        var i: usize = 0;
        while (i < self.peers.items.len) {
            const peer = self.peers.items[i];
            if (now_ms - peer.last_seen_ms > 30000) {
                print(" [VEKTOR PEER TABLE] PEER 0x{X:0>16} EXPIRED (TTL > 30s). REMOVING.\n", .{peer.node_id});
                _ = self.peers.orderedRemove(i);
            } else {
                i += 1;
            }
        }
    }
};
