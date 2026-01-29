# Identity Resolution

How participant identities are resolved from XMTP identifiers to human-readable display names and avatars.

## CRITICAL: Inbox IDs Are NOT Ethereum Addresses

**XMTP inbox IDs and Ethereum addresses are different things.**

```
WRONG: useIdentity(inboxId)        // Will not resolve ENS
RIGHT: useIdentity(ethereumAddress) // Will resolve ENS
```

| Identifier | Format | Example | Use For |
|------------|--------|---------|---------|
| Inbox ID | Opaque string | `"abc123..."` | XMTP internal operations |
| Ethereum Address | `0x` + 40 hex chars | `"0xd8dA6BF..."` | ENS resolution, display |

**You MUST convert inbox ID → address before ENS lookup.**

## The Resolution Chain

```
┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐
│    Inbox ID     │  →   │ Ethereum Address│  →   │  ENS Name +     │
│ (XMTP internal) │      │   (0x...)       │      │    Avatar       │
└─────────────────┘      └─────────────────┘      └─────────────────┘
        │                        │                        │
   From SDK:              SDK method to              viem/wagmi
   conversations,         resolve inbox ID           ENS resolution
   messages               to address
```

| Step | What You Have | What You Need | How |
|------|---------------|---------------|-----|
| 1 | Inbox ID from SDK | Ethereum address | SDK method (look up) |
| 2 | Ethereum address | ENS name + avatar | `useIdentity(address)` |

## Data Flow by Conversation Type

### DM Conversations

```
conversation.peerInboxId
       ↓
  SDK: resolve inbox ID → address (REQUIRED STEP - DO NOT SKIP)
       ↓
  useIdentity(peerAddress)
       ↓
  Display: ENS name or truncated address
```

### Group Conversations

```
conversation.members[].inboxId
       ↓
  SDK: resolve each inbox ID → address (REQUIRED STEP - DO NOT SKIP)
       ↓
  useIdentity(memberAddress) for each
       ↓
  Display: ENS names or truncated addresses
```

### Messages

```
message.senderInboxId
       ↓
  SDK: resolve inbox ID → address (REQUIRED STEP - DO NOT SKIP)
       ↓
  useIdentity(senderAddress)
       ↓
  Display: Sender name
```

## Rules

**MUST:**
- Convert inbox ID to Ethereum address BEFORE calling useIdentity
- Handle BOTH DM peers AND group members (different code paths)
- Cache address resolution results (inbox ID → address mapping)
- Cache ENS resolution results (address → name mapping)

**NEVER:**
- Pass inbox IDs to useIdentity (it expects Ethereum addresses)
- Assume inbox ID format matches address format
- Skip the inbox ID → address conversion step
- Display inbox IDs to users (they're not human-readable)

## Common Mistake

```typescript
// WRONG - passing inbox ID to identity hook
const peerInboxId = conversation.peerInboxId;
const { displayName } = useIdentity(peerInboxId); // BROKEN - inbox ID is not an address

// RIGHT - resolve to address first
const peerInboxId = conversation.peerInboxId;
const peerAddress = await resolveInboxIdToAddress(peerInboxId); // SDK method
const { displayName } = useIdentity(peerAddress); // Works - address resolves to ENS
```

## Implementation Checklist

- [ ] DM conversations: Resolve `peerInboxId` → address before identity lookup
- [ ] Group conversations: Resolve each `member.inboxId` → address before identity lookup
- [ ] Messages: Resolve `senderInboxId` → address before identity lookup
- [ ] Never pass raw inbox IDs to useIdentity hook
- [ ] Cache both mappings: inbox ID → address, and address → ENS

## States

| Resolution State | Display |
|------------------|---------|
| Initial | Truncated address (0xd8dA...6045) |
| Resolving | Truncated address (loading indicator optional) |
| Resolved | ENS name (vitalik.eth) |
| Failed | Truncated address (permanent) |

## Look Up

Before implementing, query `/xmtp-docs` for:

1. **Inbox ID → address method**: The specific SDK method to resolve inbox ID to Ethereum address
2. **DM peer identifier**: How to get the peer's inbox ID from a DM conversation
3. **Group member identifiers**: How to get member inbox IDs from a group conversation
4. **Message sender identifier**: How to get sender's inbox ID from a message
5. **Batch resolution**: Can multiple inbox IDs be resolved in one call?
6. **Caching**: Does the SDK cache inbox ID → address mappings internally?
