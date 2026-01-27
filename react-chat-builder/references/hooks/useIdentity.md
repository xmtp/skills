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

## Rules

**MUST:**
- Accept Ethereum addresses (0x...), NOT XMTP inbox IDs
- Cache resolved names in Zustand store (stable selectors per store.md)
- Show address immediately, update when resolved (never block UI)
- Use request token pattern to prevent stale closure bugs
- Use wagmi's configured client when available (avoids rate-limited public endpoints)

**NEVER:**
- Pass inbox IDs to this hook (they're opaque identifiers, not resolvable via ENS)
- Fire duplicate requests for same address (dedupe in-flight)
- Return stale data after address prop changes
- Create standalone viem clients for ENS resolution (reuse wagmi's client)

**CORS ISSUES:**

ENS resolution requires RPC calls. Default endpoints may block browser requests (CORS). If resolution fails silently or with network errors, the RPC transport likely needs configuration. Look up CORS-friendly endpoints and custom transport configuration for wagmi.

## Look Up

Before implementing, check:

1. **viem ENS utilities**: How to resolve address → name and address → avatar
2. **ENS normalization**: Proper address/name normalization before resolution
3. **wagmi client reuse**: How to get the configured public client from wagmi
4. **CORS-friendly RPCs**: Which public Ethereum RPC endpoints support browser CORS
5. **Prerequisite React skill**: Request token and stale closure patterns
6. **Existing identity patterns**: Does user's codebase have address resolution?
