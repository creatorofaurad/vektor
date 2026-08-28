# VEKTOR BINARY PROTOCOL SPECIFICATION (v1.0)

---

## 1. Frame Structure

Every network frame sent over Vektor P2P sockets consists of a fixed **17-byte Header** followed by a variable-length **Payload**.

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Magic (0x564B5452)                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
| MsgType (u8)  |             Payload Length (u32)              |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                       Sender ID (u64)                         +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                                                               |
+                      Timestamp (i64)                          +
|                                                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                         Payload Bytes...                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

---

## 2. Message Types (`MsgType`)

| Code | Name | Description |
| :--- | :--- | :--- |
| `0x01` | **Handshake** | Initial peer node discovery & capability exchange |
| `0x02` | **TaskDelegation** | Routing a subagent task payload to a worker node |
| `0x03` | **ComputeShare** | Advertising available RAM, CPU threads, and VRAM |
| `0x04` | **Heartbeat** | Periodic liveness & latency check (every 5000ms) |
| `0x05` | **ResultPayload** | Returning completed task outputs & execution telemetry |
| `0x06` | **EmergencyPurge** | Instant termination signal for rogue/stuck agents |

---

## 3. Serialization Rules
- All multi-byte integers are serialized in **Big-Endian (Network Byte Order)**.
- String fields are prefixed with a `u32` length field followed by raw UTF-8 bytes.
- Payloads are validated against cryptographic checksums before execution.
