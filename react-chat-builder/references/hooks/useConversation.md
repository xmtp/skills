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

export function useConversation(conversationId: string): UseConversationReturn;
```

Note: The `addMembers` function accepts Ethereum addresses. Implementation handles any SDK-required address resolution internally.

## Rules

**MUST:**
- Sync conversation before reading members (ensures fresh data)
- Check admin status before exposing admin actions
- Update local store after consent/metadata changes (optimistic feel)
- Lowercase all addresses before SDK operations
- Resolve addresses to inbox identifiers for member operations if SDK requires

**NEVER:**
- Allow non-admins to call admin methods (check isAdmin first)
- Expose raw SDK types in the hook's public API
- Skip sync before reading group members

**PERMISSION LEVELS:**
| Level | Can Send | Add Members | Remove Members | Edit Info |
|-------|----------|-------------|----------------|-----------|
| `member` | ✓ | ✗ | ✗ | ✗ |
| `admin` | ✓ | ✓ | ✓ (not other admins) | ✓ |
| `super_admin` | ✓ | ✓ | ✓ (including admins) | ✓ |

**CONSENT ACTIONS:**
- `allow()` → Moves conversation to main inbox, sender can message freely
- `block()` → Hides conversation, no notifications from this sender

**ERROR HANDLING:**
- Not authorized → "Must be admin to perform this action"
- Not a group → "This action is only available for group conversations"
- Member not on XMTP → "Address is not registered on XMTP"

## Look Up

Before implementing, query XMTP docs for current patterns:

1. **Getting conversation by ID**: How to retrieve a single conversation
2. **Listing group members**: How to get members of a group conversation
3. **Checking permission level**: How to determine if user is admin/super_admin
4. **Updating consent state**: How to allow or block a conversation
5. **Adding group members**: How to add new members (what identifier format?)
6. **Removing group members**: How to remove members (by inbox ID or address?)
7. **Updating group metadata**: How to change name and description
8. **Syncing conversation**: How to ensure conversation data is fresh
