# GroupManagement Component

Member list and admin controls for group conversations.

## Interface

```typescript
interface GroupManagementProps {
  conversationId: string;
  onClose: () => void;
  className?: string;
}
```

## UX Rules

**MUST:**
- Show member list with IdentityBadge for each
- Add/remove member controls (if user has permission)
- Loading state while fetching/updating

**NEVER:**
- Allow removing self from group via this UI
- Show admin actions if user is not admin

**ACCESSIBILITY:**
- Member list uses proper list semantics
- Remove buttons have descriptive `aria-label`

## Look Up

Before implementing, check:

1. **XMTP group member API**: Query docs for member management
2. **useConversation hook**: Check for group operations
3. **IdentityBadge**: For displaying member identities
