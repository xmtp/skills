# useIdentity Hook

Resolves blockchain addresses to human-readable names and avatars via ENS or custom resolvers.

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
- Cache resolved names in Zustand store (stable selectors per store.md)
- Show address immediately, update when resolved (never block UI)
- Use request token pattern to prevent stale closure bugs

**NEVER:**
- Fire duplicate requests for same address (dedupe in-flight)
- Return stale data after address prop changes

## Look Up

Before implementing, check:

1. **viem ENS utilities**: `getEnsName`, `getEnsAvatar` patterns
2. **ENS normalization**: Import from `viem/ens` for proper address handling
3. **Prerequisite React skill**: Request token and stale closure patterns
4. **Existing identity patterns**: Does user's codebase have address resolution?
