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

## Behavior

**Stream lifecycle:**
- Each stream start returns a cleanup function
- Cleanup must be called on component unmount
- Multiple message streams can run simultaneously (one per active conversation)

**Reconnection:**
- Auto-reconnect on network disconnect
- Exponential backoff: 1s, 2s, 4s, 8s... max 30s
- Reset attempt counter on success
- Stop reconnection if client disconnects

## Rules

**MUST:**
- Return cleanup function from every stream start
- Stop streams when component unmounts
- Deduplicate messages by ID
- Sort messages by timestamp before displaying
- Reconnect automatically on network disconnect
- Use exponential backoff for reconnection

**NEVER:**
- Create duplicate streams for the same conversation
- Show UI indicators during reconnection (silent reconnect)
- Block UI while reconnecting

## States

| Stream State | Behavior |
|--------------|----------|
| `connected` | Receiving real-time updates |
| `reconnecting` | Auto-reconnecting (silent) |
| `disconnected` | Cleanup called, no longer receiving |

**Reconnection thresholds:**

| Attempts | Behavior |
|----------|----------|
| 1-10 | Silent reconnection with backoff |
| 10+ | Show toast notification to user |
| Client closed | Stop reconnection attempts |

## Look Up

Before implementing, query `/xmtp-docs` for:

1. **Stream conversations**: How to stream new conversations in real-time
2. **Stream messages**: How to stream messages for a specific conversation
3. **Stop stream**: How to properly close/cancel a stream
4. **Stream events**: What events/callbacks does the stream provide
5. **Stream errors**: What errors can streams throw
