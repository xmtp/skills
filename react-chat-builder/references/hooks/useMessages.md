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
  senderInboxId: string;  // NOTE: This is NOT an Ethereum address - must resolve before ENS lookup
  content: MessageContent;
  sentAtNs: string;
  status?: 'sending' | 'sent' | 'failed';
}

// IMPORTANT: senderInboxId must be resolved to Ethereum address before identity display.
// See identity-resolution.md for the conversion chain.

type MessageContent =
  | { type: 'text'; text: string }
  | { type: 'attachment'; filename: string; mimeType: string; data: Uint8Array }
  | { type: 'reaction'; reference: string; emoji: string; action: 'added' | 'removed' }
  | { type: 'reply'; reference: string; content: MessageContent };

function useMessages(conversationId: string): UseMessagesReturn;
```

## Behavior

**Streaming:**
- Starts message stream when conversation selected
- New messages added to store immediately
- Stream cleaned up when conversation changes or unmounts

**Sending:**
- Creates optimistic message with 'sending' status immediately
- Replaces with real message on success (status: 'sent')
- Updates to 'failed' status on error (message kept for retry)

**Pagination:**
- Initial load fetches recent messages
- `loadMore()` fetches older messages using cursor
- `hasMore` indicates if more history exists

## Rules

**MUST:**
- Implement optimistic updates for sent messages
- Deduplicate messages by ID (streams may deliver duplicates)
- Sort messages by sentAtNs before displaying
- Use XMTPStreamManager pattern for streaming
- Clean up streams on unmount or conversation change
- Cache getSnapshot results when using useSyncExternalStore

**NEVER:**
- Show duplicate messages in the UI
- Block UI while sending
- Leave orphaned streams when switching conversations
- Assume message order from network
- Create new array/object references in getSnapshot

## States

| State | User Experience |
|-------|-----------------|
| `isLoading: true` | Show skeleton messages |
| `isSending: true` | Show spinner on send button |
| `streamStatus: reconnecting` | Silent (no UI indicator) |
| `hasMore: true` | Show "load more" or trigger on scroll |

**Message status:**

| Status | Display |
|--------|---------|
| `sending` | Dimmed/spinner, not yet confirmed |
| `sent` | Normal display |
| `failed` | Error indicator with retry button |

## Look Up

Before implementing, query XMTP docs for:

1. **Loading messages**: How to fetch messages from a conversation (pagination parameters)
2. **Streaming messages**: How to subscribe to new messages
3. **Sending text**: How to send a plain text message
4. **Sending attachments**: How to send file attachments (content type package)
5. **Sending reactions**: How to send emoji reactions (content type package)
6. **Sending replies**: How to send reply messages (content type package)
7. **Content type registration**: How to register content type codecs
8. **Message structure**: What fields are on a decoded message object
