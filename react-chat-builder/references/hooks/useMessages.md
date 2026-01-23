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
- Await stream methods (they return Promises in current SDK)
- Support cursor-based pagination for loading older messages
- Clean up streams on unmount or conversation change
- Dynamic import content type packages (SSR compatibility)

**NEVER:**
- Show duplicate messages in the UI
- Block UI while sending (use optimistic updates)
- Leave orphaned streams when switching conversations
- Assume message order from network (sort by sentAtNs)

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

1. **Loading messages**: How to fetch messages from a conversation with pagination
2. **Streaming messages**: How to subscribe to new messages in a conversation
3. **Sending text**: How to send a plain text message
4. **Sending attachments**: How to send file attachments (what content type package?)
5. **Sending reactions**: How to send emoji reactions to messages (what content type package?)
6. **Sending replies**: How to send reply messages (what content type package?)
7. **Content type registration**: How to register content type codecs with the client
8. **Message structure**: What fields are on a decoded message object
