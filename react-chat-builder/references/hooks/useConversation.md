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
  removeMembers: (inboxIds: string[]) => Promise<void>;
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

Note: `addMembers` accepts Ethereum addresses. Implementation handles resolution internally.

## Behavior

**Loading:**
- Syncs conversation to ensure fresh data
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
- Sync conversation before reading members
- Check admin status before exposing admin actions
- Update local store after consent/metadata changes
- Lowercase all addresses before SDK operations
- Resolve addresses to inbox identifiers for member operations

**NEVER:**
- Allow non-admins to call admin methods
- Expose raw SDK types in public API
- Skip sync before reading group members

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
5. **Adding group members**: How to add members (identifier format)
6. **Removing group members**: How to remove members (by inbox ID or address)
7. **Updating group metadata**: How to change name and description
8. **Syncing conversation**: How to ensure conversation data is fresh
