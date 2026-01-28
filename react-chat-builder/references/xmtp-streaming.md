# XMTP Streaming

Manages real-time message and conversation streams with automatic reconnection.

## Interface

```typescript
interface StreamManager {
  /** Start streaming new conversations. Returns cleanup function. */
  startConversationStream: (
    onConversation: (conversation: Conversation) => void
  ) => Promise<() => void>;

  /** Start streaming messages for a conversation. Returns cleanup function. */
  startMessageStream: (
    conversationId: string,
    onMessage: (message: Message) => void
  ) => Promise<() => void>;

  /** Stop all active streams */
  stopAllStreams: () => void;
}
```

## Rules

**MUST:**
- Return cleanup function from every stream start
- Stop streams when component unmounts
- Deduplicate messages by ID (streams may deliver duplicates)
- Sort messages by timestamp before displaying (order not guaranteed)
- Reconnect automatically on network disconnect
- Use exponential backoff for reconnection: 1s, 2s, 4s, 8s... max 30s

**NEVER:**
- Create duplicate streams for the same conversation
- Show UI indicators during reconnection (silent reconnect)
- Block UI while reconnecting

**RECONNECTION:**
- On stream disconnect, attempt reconnection automatically
- After max attempts (10), show toast notification to user
- Reset attempt counter on successful reconnection
- If client is disconnected, stop reconnection attempts

**ERROR HANDLING:**
- Network errors → trigger reconnection
- Client closed → stop stream, don't reconnect
- Unknown errors → log and trigger reconnection

## Look Up

Before implementing, query `/xmtp-docs` for:

| Purpose | What to Find |
|---------|--------------|
| Stream conversations | How to stream new conversations in real-time |
| Stream messages | How to stream messages for a specific conversation |
| Stop stream | How to properly close/cancel a stream |
| Stream events | What events/callbacks does the stream provide |
| Stream errors | What errors can streams throw |
