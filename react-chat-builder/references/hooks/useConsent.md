# useConsent Hook

Manages conversation consent state for spam filtering.

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

## Behavior

**State reading:**
- Returns current consent state from conversation
- Updates reactively when state changes

**State changes:**
- `allow()` marks conversation as allowed (moves to inbox)
- `deny()` marks conversation as denied (hides it)
- Both use optimistic updates

## Rules

**MUST:**
- Optimistic update on allow/deny
- Revert optimistic update on failure
- Sync consent state to Zustand store
- Expose error state for UI handling

**NEVER:**
- Block UI during consent update
- Allow setting consent on non-existent conversations

## States

| Consent State | Location | Behavior |
|---------------|----------|----------|
| `unknown` | Requests inbox | Awaiting user decision |
| `allowed` | Main inbox | Full messaging enabled |
| `denied` | Hidden | No notifications, not visible |

| Hook State | Description |
|------------|-------------|
| `isUpdating: true` | Consent change in progress |
| `error: present` | Last update failed |

## Look Up

Before implementing, check:

1. **XMTP consent API**: Query docs for consent patterns
2. **Conversation consent field**: How consent state is stored
3. **Optimistic update patterns**: How app handles async state
