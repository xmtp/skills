# Hook Coordination

Documents the dependency graph, data flow, and state ownership between XMTP hooks.

## Dependency Graph

```
XMTPProvider (context)
       │
       ▼
    useXMTP ──────────────────────────────────────┐
       │                                          │
       ▼                                          │
useConversations ─────────┐                       │
       │                  │                       │
       ▼                  ▼                       │
useMessages        useConversation                │
       │                  │                       │
       ▼                  ▼                       │
  [UI Layer]        useConsent                    │
                          │                       │
                          ▼                       │
                    useIdentity ◄─────────────────┘
```

## Data Flow

### Connection Flow

```
User clicks "Connect"
       ↓
XMTPProvider.connect() called
       ↓
Wallet prompts for signature
       ↓
useXMTP.initialize() creates client
       ↓
Store: status = 'connected'
       ↓
useConversations starts sync + stream
       ↓
Store: conversations populated
       ↓
UI renders conversation list
```

### Message Flow

```
User selects conversation
       ↓
useMessages(conversationId) called
       ↓
Load initial messages from SDK
       ↓
Store: messages[convId] populated
       ↓
Start message stream
       ↓
New messages → Store → UI updates
```

### Send Flow

```
User types and sends
       ↓
useMessages.send() called
       ↓
Optimistic message added (status: 'sending')
       ↓
Store update → UI shows message immediately
       ↓
SDK sends to network
       ↓
Success: Replace with real message (status: 'sent')
Failure: Update status to 'failed'
```

## State Ownership

| State | Owner | Consumers |
|-------|-------|-----------|
| XMTP Client | XMTPProvider | useXMTP, useConversations, useMessages |
| Connection status | Zustand store | useXMTP, UI components |
| Conversations | Zustand store | useConversations, ConversationList |
| Messages | Zustand store | useMessages, MessageThread |
| Consent state | Zustand store | useConsent, RequestsInbox |
| Identity cache | Zustand store | useIdentity, IdentityBadge |
| Stream state | XMTPStreamManager | useConversations, useMessages |

## Hook Initialization Order

| Order | Hook | Trigger | Depends On |
|-------|------|---------|------------|
| 1 | useXMTP | Provider mount | Nothing |
| 2 | useConversations | Client connected | useXMTP.client |
| 3 | useMessages | Conversation selected | useConversations |
| 4 | useConversation | Conversation selected | useConversations |
| 5 | useConsent | Conversation selected | useConversation |
| 6 | useIdentity | Address available | Nothing (independent) |

## Rules

**MUST:**
- useXMTP provides client to all other hooks via context
- Hooks read from Zustand store for shared state
- Each hook writes to its own slice of store state
- Stream cleanup happens in the hook that started the stream

**NEVER:**
- Hooks directly read from other hooks' internal state
- Multiple hooks manage the same store slice
- Streams outlive their owning component
- Hooks assume initialization order (guard with null checks)

## Store Slices by Hook

| Hook | Reads | Writes |
|------|-------|--------|
| useXMTP | status | status, client reference (context) |
| useConversations | conversations, status | conversations |
| useMessages | messages[convId], cursors, hasMore | messages[convId], cursors, hasMore |
| useConversation | conversations[id] | conversations[id] (consent, metadata) |
| useConsent | conversations[id].consentState | conversations[id].consentState |
| useIdentity | identities | identities |

## Cleanup Coordination

| Event | Actions |
|-------|---------|
| Component unmount | Stop streams owned by that component |
| Conversation change | Stop old message stream, start new one |
| Disconnect | Stop all streams, clear client, reset store |
| Account change | Disconnect, prompt reconnect |

## Look Up

Before implementing, check:

1. **React context patterns**: Optimal provider structure
2. **Zustand slice patterns**: How to organize store slices
3. **Stream lifecycle**: SDK stream management patterns
