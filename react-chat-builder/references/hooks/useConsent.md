# useConsent Hook

Manages conversation consent state (allow/deny) for spam filtering.

## Interface

```typescript
type ConsentState = 'unknown' | 'allowed' | 'denied';

interface UseConsentReturn {
  consentState: ConsentState;
  allow: () => Promise<void>;
  deny: () => Promise<void>;
  isUpdating: boolean;
  error: Error | null;
}

function useConsent(conversationId: string): UseConsentReturn;
```

## Rules

**MUST:**
- Optimistic update on allow/deny (update UI immediately)
- Revert optimistic update on failure, expose error
- Sync consent state to Zustand store

**NEVER:**
- Block UI during consent update
- Allow setting consent on non-existent conversations

## Look Up

Before implementing, check:

1. **XMTP consent API**: Query docs for consent patterns
2. **store.md**: Check Conversation type for consent state field
3. **Existing optimistic update patterns**: How does app handle async state?
