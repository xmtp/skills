# useIdentity Hook

Resolves Ethereum addresses to human-readable names and avatars via ENS or custom resolvers.

> **WARNING:** This hook accepts Ethereum addresses (0x...), NOT XMTP inbox IDs.
> If you pass an inbox ID, ENS resolution will fail silently.
> See [identity-resolution.md](../identity-resolution.md) for the full conversion chain.

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
- Results cached by address
- In-flight requests deduplicated
- Failed lookups cached as null (prevents retry spam)

## Rules

**MUST:**
- Accept Ethereum addresses (0x...), NOT XMTP inbox IDs
- Cache resolved names in Zustand store
- Show address immediately, update when resolved (never block UI)
- Use request token pattern to prevent stale closure bugs
- Deduplicate in-flight requests for same address

**NEVER:**
- Pass inbox IDs to this hook (must be address)
- Fire duplicate requests for same address
- Return stale data after address prop changes
- Block UI waiting for resolution

## States

| State | Display |
|-------|---------|
| `isLoading: true, displayName: null` | Show truncated address |
| `isLoading: false, displayName: present` | Show resolved ENS name |
| `isLoading: false, displayName: null` | Show truncated address (no ENS) |

## Look Up

Before implementing, check:

1. **viem ENS utilities**: How to resolve address → name and address → avatar
2. **ENS normalization**: Proper address/name normalization requirements
3. **RPC client**: How to get or create an Ethereum RPC client for ENS resolution
4. **CORS considerations**: Which public Ethereum RPC endpoints support browser CORS
5. **Wagmi integration**: If wagmi is present, how to reuse its configured client
