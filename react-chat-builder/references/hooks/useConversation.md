# useConversation Hook

Single conversation operations including consent and group admin features.

## Interface

```typescript
interface UseConversationReturn {
  conversation: Conversation | null;
  members: GroupMember[];
  isGroup: boolean;
  isLoading: boolean;

  // Consent
  consentState: ConsentState;
  allow: () => Promise<void>;
  block: () => Promise<void>;

  // Group admin (only when isAdmin === true)
  isAdmin: boolean;
  addMembers: (addresses: string[]) => Promise<void>;
  removeMembers: (memberIds: string[]) => Promise<void>;
  updateName: (name: string) => Promise<void>;
  updateDescription: (description: string) => Promise<void>;
}

type ConsentState = 'allowed' | 'denied' | 'unknown';

interface GroupMember {
  inboxId: string;
  address: string;
  permissionLevel: 'member' | 'admin' | 'super_admin';
}

function useConversation(conversationId: string): UseConversationReturn;
```

Note: `addMembers` accepts Ethereum addresses. Implementation handles any SDK-required transformations.

## Behavior

**Loading:**
- Fetches conversation data
- Fetches members for group conversations
- Determines admin status for current user

**Consent actions:**
- `allow()` moves conversation to main inbox
- `block()` hides conversation, stops notifications

**Group admin actions:**
- Only available when `isAdmin: true`
- Updates applied optimistically to local store

## Rules

**MUST:**
- Check admin status before exposing admin actions
- Update local store after consent/metadata changes (optimistic feel)

**NEVER:**
- Allow non-admins to call admin methods (check isAdmin first)
- Expose raw SDK types in public API

## States

**Permission levels:**

| Level | Send | Add Members | Remove Members | Edit Info |
|-------|------|-------------|----------------|-----------|
| `member` | Yes | No | No | No |
| `admin` | Yes | Yes | Yes (not other admins) | Yes |
| `super_admin` | Yes | Yes | Yes (including admins) | Yes |

**Hook states:**

| State | Description |
|-------|-------------|
| `isLoading: true` | Fetching conversation/members |
| `isGroup: true` | Group conversation (has members) |
| `isAdmin: true` | Current user can perform admin actions |

## Look Up

Before implementing, query XMTP docs for:

1. **Getting conversation by ID**: How to retrieve a single conversation
2. **Listing group members**: How to get members of a group
3. **Checking permission level**: How to determine admin/super_admin status
4. **Updating consent state**: How to allow or block a conversation
5. **Adding group members**: How to add members (what identifier format?)
6. **Removing group members**: How to remove members (by what identifier?)
7. **Updating group metadata**: How to change name and description
8. **Sync requirements**: Does SDK require sync before reading members?
9. **Address normalization**: Does SDK normalize addresses internally?
