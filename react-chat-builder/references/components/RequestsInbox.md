# RequestsInbox Component

Displays pending conversation requests for user approval before messages appear in main inbox.

## Interface

```typescript
interface RequestsInboxProps {
  onAllow: (conversationId: string) => void;
  onDeny: (conversationId: string) => void;
  className?: string;
}
```

## UX Rules

**MUST:**
- Show conversations with `consentState: 'unknown'`
- Allow button moves conversation to main inbox
- Show sender identity (use IdentityBadge) and message preview

**NEVER:**
- Auto-accept requests
- Show denied conversations

**ACCESSIBILITY:**
- Allow/Deny buttons have descriptive labels
- List uses proper list semantics

## Look Up

Before implementing, check:

1. **useConsent hook**: For consent state management
2. **ConversationList patterns**: Match existing list styling
3. **IdentityBadge**: For sender display
