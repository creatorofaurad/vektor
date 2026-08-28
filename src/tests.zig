//====================================================================
//                 VEKTOR NATIVE UNIT TEST SUITE                      
//====================================================================
const std = @import("std");
const testing = std.testing;

const protocol        = @import("protocol.zig");
const noise_handshake = @import("noise_handshake.zig");
const peer_table      = @import("peer_table.zig");

test "Vektor Magic Bytes Header Test" {
    try testing.expectEqual(@as(u32, 0x564B5452), protocol.MAGIC_BYTES);
}

test "Noise_IK Handshake Session Key Test" {
    const allocator = std.heap.page_allocator;
    const noise = try noise_handshake.NoiseHandshake.init(allocator);

    var dummy_peer: [32]u8 = undefined;
    @memset(&dummy_peer, 0xAA);

    const session_key = try noise.performHandshake(dummy_peer);
    try testing.expect(session_key != 0);
}

test "PeerTable Add Peer Test" {
    const allocator = std.heap.page_allocator;
    var table = peer_table.PeerTable.init(allocator);
    defer table.deinit();

    try table.addOrUpdatePeer(0x1234567890ABCDEF, "127.0.0.1", 9090);
    try testing.expectEqual(@as(usize, 1), table.peers.items.len);
}
