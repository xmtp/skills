# Identity Resolution

How participant identities are resolved from XMTP identifiers to human-readable display names and avatars.

## The Resolution Chain

XMTP uses internal identifiers for participants. To display a human-readable name and avatar:

```
XMTP identifier → Ethereum address → ENS name + avatar
```

| Step | Source | Speed | Caching |
|------|--------|-------|---------|
| Identifier → address | XMTP SDK | Fast (local lookup) | SDK handles |
| Address → ENS name | Ethereum RPC | Slow (network) | App caches |
| Address → ENS avatar | Ethereum RPC | Slow (network) | App caches |

## Behavior

**Step 1: XMTP Identifier → Address**
- Conversations and messages contain participant identifiers
- SDK provides method to resolve identifier to Ethereum address
- Implementation details depend on SDK version (look up)

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
- Resolve XMTP identifier to address BEFORE calling useIdentity
- Cache results by address
- Deduplicate in-flight requests
- Cache failed lookups as null

**NEVER:**
- Pass raw XMTP identifiers to useIdentity (must be address)
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
| ConversationList | Participant identifiers | Resolved names/avatars |
| MessageThread | Sender identifier | Sender name/avatar |
| GroupManagement | Member identifiers | Member names/avatars |
| IdentityBadge | Ethereum address | Name + avatar |

## Look Up

Before implementing, query `/xmtp-docs` for:

1. **Identifier → address**: SDK method to get Ethereum address from participant identifier
2. **Participant structure**: How participants are represented in conversations/messages
3. **Address format**: Does SDK return checksummed or lowercase addresses?
4. **Identifier terminology**: What does SDK call internal identifiers (inboxId, etc.)?
