# Zustand Store Implementation

Scalable state management for XMTP chat applications.

## Table of Contents
- [Store Interface](#store-interface)
- [Implementation](#implementation)
- [Selectors](#selectors)
- [Optimistic Updates](#optimistic-updates)
- [Pagination](#pagination)

## Store Interface

```typescript
// stores/inbox.ts
import { create } from 'zustand';
import { immer } from 'zustand/middleware/immer';

// Use Record<string, T> instead of Map for DevTools compatibility
interface InboxState {
  // Conversations
  conversations: Record<string, Conversation>;

  // Messages per conversation
  messages: Record<string, Record<string, Message>>;

  // Pagination cursors
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

## Implementation

```typescript
// stores/inbox.ts
const initialState: InboxState = {
  conversations: {},
  messages: {},
  cursors: {},
  hasMore: {},
  lastSyncedAt: null,
  status: 'disconnected',
};

export const useInboxStore = create<InboxStore>()(
  immer((set, get) => ({
    ...initialState,

    // Conversations
    upsertConversation: (conv) => set((state) => {
      state.conversations[conv.id] = conv;
      // Initialize messages map if needed
      if (!state.messages[conv.id]) {
        state.messages[conv.id] = {};
      }
    }),

    upsertConversations: (convs) => set((state) => {
      for (const conv of convs) {
        state.conversations[conv.id] = conv;
        if (!state.messages[conv.id]) {
          state.messages[conv.id] = {};
        }
      }
    }),

    removeConversation: (id) => set((state) => {
      delete state.conversations[id];
      delete state.messages[id];
      delete state.cursors[id];
      delete state.hasMore[id];
    }),

    // Messages
    upsertMessage: (convId, msg) => set((state) => {
      if (!state.messages[convId]) {
        state.messages[convId] = {};
      }
      state.messages[convId][msg.id] = msg;

      // Update conversation's last message timestamp
      if (state.conversations[convId]) {
        const sentAt = BigInt(msg.sentAtNs);
        const lastAt = state.conversations[convId].lastMessageAt;
        if (!lastAt || sentAt > lastAt) {
          state.conversations[convId].lastMessageAt = sentAt;
        }
      }
    }),

    upsertMessages: (convId, msgs) => set((state) => {
      if (!state.messages[convId]) {
        state.messages[convId] = {};
      }
      for (const msg of msgs) {
        state.messages[convId][msg.id] = msg;
      }
    }),

    updateMessageStatus: (convId, msgId, status) => set((state) => {
      if (state.messages[convId]?.[msgId]) {
        state.messages[convId][msgId].status = status;
      }
    }),

    removeMessage: (convId, msgId) => set((state) => {
      if (state.messages[convId]) {
        delete state.messages[convId][msgId];
      }
    }),

    // Pagination
    setCursor: (convId, cursor) => set((state) => {
      state.cursors[convId] = cursor;
    }),

    setHasMore: (convId, hasMore) => set((state) => {
      state.hasMore[convId] = hasMore;
    }),

    // Sync
    setLastSyncedAt: (timestamp) => set((state) => {
      state.lastSyncedAt = timestamp;
    }),

    setStatus: (status) => set((state) => {
      state.status = status;
    }),

    // Reset
    reset: () => set(initialState),
  }))
);
```

## Selectors

### Rule: Derived selectors must return stable references

Selectors returning derived data (sorted, filtered, transformed) must not create new arrays/objects on every call—this causes infinite re-render loops with React's warning:

> "The result of getSnapshot should be cached to avoid an infinite loop"

### Why This Happens

Both `useSyncExternalStore` and Zustand's `useStore` call `getSnapshot`/selector on every render. If the function returns a new reference (even with identical content), React detects a "change" and re-renders, creating an infinite loop.

```typescript
// ❌ BAD: Object.values() creates new array every call
const messages = useInboxStore(state => Object.values(state.messages[convId] ?? {}));

// ❌ BAD: .filter() creates new array every call
const allowed = useInboxStore(state =>
  Object.values(state.conversations).filter(c => c.consentState === 'allowed')
);

// ❌ BAD: Spread creates new object every call
const pagination = useInboxStore(state => ({
  cursor: state.cursors[convId],
  hasMore: state.hasMore[convId]
}));
```

### Solution: Use useShallow or Memoized Selectors

```typescript
import { useShallow } from 'zustand/react/shallow';

// ✅ GOOD: useShallow does shallow comparison, prevents re-render if values equal
const messages = useInboxStore(
  useShallow(state => Object.values(state.messages[convId] ?? {}))
);

// ✅ GOOD: useShallow with object
const pagination = useInboxStore(
  useShallow(state => ({
    cursor: state.cursors[convId] ?? null,
    hasMore: state.hasMore[convId] ?? true
  }))
);

// ✅ GOOD: Select primitive directly (no transformation)
const status = useInboxStore(state => state.status);

// ✅ GOOD: Select by ID returns stable reference if object is stable
const conversation = useInboxStore(state => state.conversations[id] ?? null);
```

### Alternative: Pre-compute in Store

Structure the store so derived data is pre-computed on write, not computed on read:

```typescript
// Instead of filtering conversations by consent on read,
// maintain separate indexes updated on write
interface InboxState {
  conversations: Record<string, Conversation>;
  // Pre-computed indexes
  conversationIdsByConsent: Record<ConsentState, string[]>;
}
```

### Interface

```typescript
// stores/selectors.ts
import { useShallow } from 'zustand/react/shallow';

// Primitives: direct selectors are fine
export const useConnectionStatus = () => useInboxStore(state => state.status);

// Single item by ID: stable if item reference is stable
export const useConversation = (id: string) => useInboxStore(
  state => state.conversations[id] ?? null
);

// Derived data: MUST use useShallow
export const useMessages = (convId: string) => useInboxStore(
  useShallow(state => Object.values(state.messages[convId] ?? {}))
);

export const useSortedConversations = () => useInboxStore(
  useShallow(state =>
    Object.values(state.conversations).sort((a, b) =>
      Number((b.lastMessageAt ?? 0n) - (a.lastMessageAt ?? 0n))
    )
  )
);

export const usePagination = (convId: string) => useInboxStore(
  useShallow(state => ({
    cursor: state.cursors[convId] ?? null,
    hasMore: state.hasMore[convId] ?? true
  }))
);
```

## Optimistic Updates

Update UI immediately, rollback on error:

```typescript
// hooks/useSendMessage.ts
export function useSendMessage(conversationId: string) {
  const { upsertMessage, updateMessageStatus, removeMessage } = useInboxStore();
  const conversation = useConversation(conversationId);

  const send = async (content: string) => {
    if (!conversation) return;

    // Create optimistic message
    const tempId = crypto.randomUUID();
    const optimisticMessage: Message = {
      id: tempId,
      conversationId,
      senderInboxId: 'self', // Will be replaced
      content: { type: 'text', text: content },
      sentAtNs: BigInt(Date.now() * 1_000_000).toString(),
      status: 'sending',
    };

    // Optimistic update
    upsertMessage(conversationId, optimisticMessage);

    try {
      // Send via XMTP
      const realMessage = await conversation.send(content);

      // Replace optimistic with real
      removeMessage(conversationId, tempId);
      upsertMessage(conversationId, {
        ...realMessage,
        status: 'sent',
      });
    } catch (error) {
      // Mark as failed (don't remove - let user retry)
      updateMessageStatus(conversationId, tempId, 'failed');
      throw error;
    }
  };

  return { send };
}
```

## Pagination

Load more messages with cursor-based pagination:

```typescript
// hooks/useLoadMoreMessages.ts
export function useLoadMoreMessages(conversationId: string) {
  const { upsertMessages, setCursor, setHasMore } = useInboxStore();
  const { cursor, hasMore } = usePagination(conversationId);
  const conversation = useConversation(conversationId);
  const [isLoading, setIsLoading] = useState(false);

  const loadMore = async () => {
    if (!conversation || !hasMore || isLoading) return;

    setIsLoading(true);

    try {
      const PAGE_SIZE = 50;
      const result = await conversation.messages({
        cursor,
        limit: PAGE_SIZE,
        direction: 'before',
      });

      upsertMessages(conversationId, result.messages);
      setCursor(conversationId, result.cursor ?? null);
      setHasMore(conversationId, result.messages.length === PAGE_SIZE);
    } finally {
      setIsLoading(false);
    }
  };

  return { loadMore, isLoading, hasMore };
}
```

## Types

```typescript
// types/xmtp.ts
type MessageStatus = 'sending' | 'sent' | 'failed';

interface Message {
  id: string;
  conversationId: string;
  senderInboxId: string;
  content: MessageContent;
  sentAtNs: string;
  status?: MessageStatus;
}

type MessageContent =
  | { type: 'text'; text: string }
  | { type: 'attachment'; url: string; mimeType: string; filename: string }
  | { type: 'reaction'; emoji: string; referenceId: string }
  | { type: 'reply'; referenceId: string; content: MessageContent };

interface Conversation {
  id: string;
  topic: string;
  peerAddress?: string; // For DMs - resolved from inbox ID (required for ENS display)
  members?: string[];   // For groups - resolved from inbox IDs
  name?: string;        // Group name
  lastMessageAt?: bigint;
  consentState: ConsentState;
  isGroup: boolean;
}

enum ConsentState {
  Unknown = 'unknown',
  Allowed = 'allowed',
  Denied = 'denied',
}
```
