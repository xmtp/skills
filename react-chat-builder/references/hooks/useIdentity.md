# useIdentity Hook

Resolves Ethereum addresses to human-readable names and avatars via ENS or custom resolvers.

## Interface

```typescript
interface UseIdentityReturn {
  displayName: string | null;
  avatar: string | null;
  isLoading: boolean;
}

function useIdentity(address: string): UseIdentityReturn;
```

## Behavior

**Resolution flow:**
1. Accept Ethereum address (NOT inbox ID)
2. Return truncated address immediately
3. Fire ENS lookup in background
4. Update displayName and avatar when resolved
5. Cache result in store

**Caching:**
- Results cached by lowercase address
- In-flight requests deduplicated
- Failed lookups cached as null (prevents retry spam)

## Rules

**MUST:**
- Accept Ethereum addresses (0x...), NOT XMTP inbox IDs
- Cache resolved names in Zustand store
- Show address immediately, update when resolved (never block UI)
- Use request token pattern to prevent stale closure bugs
- Use wagmi's configured client when available

**NEVER:**
- Pass inbox IDs to this hook
- Fire duplicate requests for same address
- Return stale data after address prop changes
- Create standalone viem clients for ENS resolution

## States

| State | Display |
|-------|---------|
| `isLoading: true, displayName: null` | Show truncated address |
| `isLoading: false, displayName: present` | Show resolved ENS name |
| `isLoading: false, displayName: null` | Show truncated address (no ENS) |

## Look Up

Before implementing, check:

1. **viem ENS utilities**: How to resolve address → name and address → avatar
2. **ENS normalization**: Proper address/name normalization
3. **wagmi client reuse**: How to get configured public client from wagmi
4. **CORS-friendly RPCs**: Which public Ethereum RPC endpoints support browser CORS
