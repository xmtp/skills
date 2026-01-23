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

Selectors returning derived data (sorted, filtered, transformed) must not create new arrays/objects on every render—this causes infinite re-render loops and repeated XMTP client initialization.

### Look Up: React state selector patterns

See prerequisite skill for stable selector and memoization patterns.

### Interface

```typescript
// stores/selectors.ts

// Primitives: direct selectors are fine
export const useConnectionStatus = () => useInboxStore(
  (state) => state.status
);

// Single item by ID: stable if item reference is stable
export const useConversation = (id: string) => useInboxStore(
  (state) => state.conversations[id] ?? null
);

// Derived data: Look Up current patterns for stable references
// DO NOT return Object.values(), .sort(), .filter(), or {...} directly from selector
export function useSortedConversations(): Conversation[];
export function useMessages(convId: string): Message[];
export function useConversationsByConsent(consentState: ConsentState): Conversation[];
export function usePagination(convId: string): { cursor: string | null; hasMore: boolean };
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
  peerAddress?: string; // For DMs
  members?: string[];   // For groups
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
