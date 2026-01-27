# useMessages Hook

Message streaming, pagination, and sending for a conversation.

## Interface

```typescript
interface UseMessagesReturn {
  messages: Message[];
  isLoading: boolean;
  isSending: boolean;
  hasMore: boolean;
  loadMore: () => Promise<void>;
  send: (text: string) => Promise<void>;
  sendAttachment: (file: File) => Promise<void>;
  sendReaction: (emoji: string, messageId: string) => Promise<void>;
  sendReply: (text: string, messageId: string) => Promise<void>;
  streamStatus: StreamStatus;
}

type StreamStatus = 'connected' | 'reconnecting' | 'disconnected';

interface Message {
  id: string;
  conversationId: string;
  senderInboxId: string;
  content: MessageContent;
  sentAtNs: string;
  status?: 'sending' | 'sent' | 'failed';
}

type MessageContent =
  | { type: 'text'; text: string }
  | { type: 'attachment'; filename: string; mimeType: string; data: Uint8Array }
  | { type: 'reaction'; reference: string; emoji: string; action: 'added' | 'removed' }
  | { type: 'reply'; reference: string; content: MessageContent };

export function useMessages(conversationId: string): UseMessagesReturn;
```

## Rules

**MUST:**
- Implement optimistic updates for sent messages (show immediately with 'sending' status)
- Deduplicate messages by ID (streams may deliver duplicates)
- Use XMTPStreamManager pattern for streaming (AbortController, auto-reconnect)
- Support loading older messages on demand (pagination)
- Clean up streams on unmount or conversation change
- Ensure component is wrapped with `next/dynamic` and `{ ssr: false }` in Next.js (see SKILL.md)
- **Cache getSnapshot results** when using `useSyncExternalStore` (see below)

**NEVER:**
- Show duplicate messages in the UI
- Block UI while sending (use optimistic updates)
- Leave orphaned streams when switching conversations
- Assume message order from network (sort by sentAtNs)
- **Create new array/object references in getSnapshot** - causes infinite loops

**STABLE SNAPSHOT PATTERN (useSyncExternalStore):**

React's `useSyncExternalStore` requires `getSnapshot` to return a cached/stable reference. If it returns a new reference each call, React detects a "change" and re-renders infinitely.

```typescript
// ❌ BAD: Creates new array reference every call → infinite loop
const messages = useSyncExternalStore(
  store.subscribe,
  () => store.getState().messages.filter(m => m.conversationId === id)
);

// ✅ GOOD: Store messages by conversation ID, return stable reference
const EMPTY_MESSAGES: Message[] = [];
const messages = useSyncExternalStore(
  store.subscribe,
  () => store.getState().messagesByConversation.get(id) ?? EMPTY_MESSAGES
);

// ✅ GOOD: Use Zustand's useStore with shallow comparison
import { useShallow } from 'zustand/react/shallow';

const messages = useInboxStore(
  useShallow(state => state.messagesByConversation.get(id) ?? EMPTY_MESSAGES)
);
```

**Key insight:** Structure the store so filtered data is pre-computed (e.g., `Map<conversationId, Message[]>`) rather than filtering in `getSnapshot`.

**OPTIMISTIC UPDATE FLOW:**
```
send() called → Create temp message (status: 'sending')
                        ↓
            SDK sends to network
                        ↓
        ┌───────────────┴───────────────┐
        ↓                               ↓
   Success: replace temp           Failure: update
   with real message               status to 'failed'
   (status: 'sent')                (keep for retry)
```

**ERROR HANDLING:**
- Send failed → Keep message with 'failed' status, allow retry
- Stream disconnected → Auto-reconnect with backoff
- Conversation not found → Throw with helpful message

## Look Up

Before implementing, query XMTP docs for current patterns:

1. **Loading messages**: How to fetch messages from a conversation (what pagination parameters exist?)
2. **Streaming messages**: How to subscribe to new messages in a conversation
3. **Sending text**: How to send a plain text message
4. **Sending attachments**: How to send file attachments (what content type package?)
5. **Sending reactions**: How to send emoji reactions to messages (what content type package?)
6. **Sending replies**: How to send reply messages (what content type package?)
7. **Content type registration**: How to register content type codecs with the client
8. **Message structure**: What fields are on a decoded message object
