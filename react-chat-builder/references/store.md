# Zustand Store

Scalable state management for XMTP chat applications.

## Interface

```typescript
interface InboxState {
  // Conversations (keyed by ID)
  conversations: Record<string, Conversation>;

  // Messages per conversation (keyed by conversation ID, then message ID)
  messages: Record<string, Record<string, Message>>;

  // Pagination state
  cursors: Record<string, string | null>;
  hasMore: Record<string, boolean>;

  // Sync state
  lastSyncedAt: number | null;

  // Connection state
  status: 'disconnected' | 'connecting' | 'connected' | 'reconnecting' | 'failed';
}

interface InboxActions {
  // Conversations
  upsertConversation: (conv: Conversation) => void;
  upsertConversations: (convs: Conversation[]) => void;
  removeConversation: (id: string) => void;

  // Messages
  upsertMessage: (convId: string, msg: Message) => void;
  upsertMessages: (convId: string, msgs: Message[]) => void;
  updateMessageStatus: (convId: string, msgId: string, status: MessageStatus) => void;
  removeMessage: (convId: string, msgId: string) => void;

  // Pagination
  setCursor: (convId: string, cursor: string | null) => void;
  setHasMore: (convId: string, hasMore: boolean) => void;

  // Sync
  setLastSyncedAt: (timestamp: number) => void;
  setStatus: (status: InboxState['status']) => void;

  // Reset
  reset: () => void;
}

type InboxStore = InboxState & InboxActions;
```

## Behavior

The store is the single source of truth for all XMTP data in the application. Components and hooks read from and write to this store.

**Data structures:**
- Use `Record<string, T>` instead of `Map` for DevTools compatibility
- Messages are nested by conversation ID for efficient per-conversation access
- Pagination state (cursors, hasMore) is tracked per conversation

**Upsert semantics:**
- `upsertConversation` creates or updates a conversation by ID
- `upsertMessage` creates or updates a message, also updates conversation's lastMessageAt
- Removal operations cascade (removing conversation removes its messages, cursors, hasMore)

## Rules

**MUST:**
- Use immer middleware for immutable updates
- Initialize messages map when upserting a conversation
- Update conversation's lastMessageAt when upserting messages
- Cascade deletes (conversation removal cleans up related state)

**NEVER:**
- Store derived data that can be computed from base state
- Use Map type (breaks DevTools compatibility)
- Mutate state directly (use immer's draft pattern)

## Selectors

**MUST:**
- Use `useShallow` from `zustand/react/shallow` for derived selectors
- Define stable empty array constants for fallbacks
- Select primitives directly when possible (stable by default)

**NEVER:**
- Create new array/object references in selectors (causes infinite re-renders)
- Use `Object.values()` or `.filter()` without `useShallow`
- Use inline arrays in useEffect/useCallback dependencies

**Selector types:**

| Access Pattern | Stability | Approach |
|----------------|-----------|----------|
| Primitive value | Stable | Direct selector |
| Single item by ID | Stable if item is stable | Direct selector with fallback |
| Derived list | Unstable without memoization | Use `useShallow` |
| Computed object | Unstable without memoization | Use `useShallow` |

## States

| Status | Description |
|--------|-------------|
| `disconnected` | No XMTP client, user not connected |
| `connecting` | Client initialization in progress |
| `connected` | Client ready, streams active |
| `reconnecting` | Stream lost, attempting reconnection |
| `failed` | Connection failed, requires user action |

## Look Up

Before implementing, query XMTP docs for:

1. **Message structure**: What fields does a decoded message have?
2. **Conversation structure**: What properties does a conversation have?
3. **Pagination**: What cursor/token does the SDK use for pagination?
