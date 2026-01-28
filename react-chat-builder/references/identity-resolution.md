# Identity Resolution

How participant identities are resolved from XMTP identifiers to human-readable display names and avatars.

## The Resolution Chain

XMTP uses `inboxId` internally. To display a human-readable name and avatar:

```
inboxId → address → ENS name + avatar
```

| Step | Source | Speed | Caching |
|------|--------|-------|---------|
| inboxId → address | XMTP SDK | Fast (local lookup) | SDK handles |
| address → ENS name | Ethereum RPC | Slow (network) | App caches |
| address → ENS avatar | Ethereum RPC | Slow (network) | App caches |

## Behavior

**Step 1: inboxId → Address**
- Conversations and messages contain `inboxId` for participants
- SDK provides local method to resolve inboxId to Ethereum address
- No network call required

**Step 2: Address → ENS Name + Avatar**
- Pass Ethereum address to `useIdentity` hook
- Hook performs ENS reverse resolution
- Results cached in Zustand store

**Display behavior:**
1. Truncated address shown immediately
2. ENS lookup fires in background
3. Name updates when resolved (fade transition)
4. Avatar displayed next to name

**Avatar fallback chain:**
1. ENS avatar (if set)
2. Generated avatar (deterministic from address)
3. Generic placeholder icon

## Rules

**MUST:**
- Resolve inboxId to address BEFORE calling useIdentity
- Cache results by lowercase address
- Deduplicate in-flight requests
- Cache failed lookups as null

**NEVER:**
- Pass inboxId to useIdentity (must be address)
- Block UI on identity resolution
- Fire duplicate requests for same address

## States

| Resolution State | Display |
|------------------|---------|
| Initial | Truncated address (0xd8dA...6045) |
| Resolving | Truncated address (loading) |
| Resolved | ENS name (vitalik.eth) |
| Failed | Truncated address (permanent) |

## Component Usage

| Component | Input | Display |
|-----------|-------|---------|
| ConversationList | Participant inboxIds | Resolved names/avatars |
| MessageThread | Sender inboxId | Sender name/avatar |
| GroupManagement | Member inboxIds | Member names/avatars |
| IdentityBadge | Ethereum address | Name + avatar |

## Look Up

Before implementing, query `/xmtp-docs` for:

1. **inboxId → address**: SDK method to get Ethereum address from inboxId
2. **Participant structure**: How participants are represented in conversations/messages
3. **Address format**: Checksummed or lowercase?
