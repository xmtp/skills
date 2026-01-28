# useConversations Hook

Stream and list conversations with consent filtering.

## Interface

```typescript
interface GroupOptions {
  name?: string;
  description?: string;
  imageUrl?: string;
  permissions?: GroupPermissions;
}

interface GroupPermissions {
  addMembers?: 'admin' | 'all';
  removeMembers?: 'admin' | 'all';
  updateMetadata?: 'admin' | 'all';
}

interface UseConversationsOptions {
  consentStates?: ConsentState[];  // Filter by consent state
}

interface UseConversationsReturn {
  conversations: Conversation[];
  isLoading: boolean;
  isSyncing: boolean;
  streamStatus: StreamStatus;
  sync: () => Promise<void>;
  create: (peerAddress: string) => Promise<Conversation>;
  createGroup: (members: string[], options?: GroupOptions) => Promise<Conversation>;
}

function useConversations(options?: UseConversationsOptions): UseConversationsReturn;
```

Note: The interface exposes `peerAddress` (Ethereum address). Implementation handles SDK transformations internally.

## Behavior

**Syncing:**
- Syncs existing conversations on mount
- Streams new conversations in real-time
- Filters by consent state before adding to store

**Creating DMs:**
- Validates address format
- Checks if peer can receive XMTP messages
- Resolves address to inbox identifier
- Creates conversation and adds to store

**Creating Groups:**
- Validates all member addresses
- Allows empty members array (creator-only group)
- Applies permissions and metadata options

## Rules

**MUST:**
- Lowercase all addresses before SDK operations
- Check if peer can receive messages BEFORE creating DM
- Resolve address to inbox identifier before DM creation
- Use XMTPStreamManager pattern for streaming
- Filter conversations by consent state
- Clean up streams on unmount
- Stabilize array options (use constants or refs for defaults)
- Use `instanceof` to determine conversation type (Dm vs Group)

**NEVER:**
- Expose inbox IDs in the hook's public API
- Skip the "can receive messages" check
- Pass raw Ethereum addresses to creation methods (resolve first)
- Assume stream methods are synchronous
- Use inline arrays in useEffect/useCallback dependencies

## States

| Consent State | Description | UI Location |
|---------------|-------------|-------------|
| `allowed` | User accepted | Main inbox |
| `unknown` | New sender | Requests inbox |
| `denied` | User blocked | Hidden |

| Hook State | User Experience |
|------------|-----------------|
| `isLoading: true` | Show skeleton conversation list |
| `isSyncing: true` | Subtle refresh indicator |
| `streamStatus: reconnecting` | Silent (no UI indicator) |

## Look Up

Before implementing, query XMTP docs for:

1. **Syncing conversations**: How to sync and list existing conversations
2. **Streaming conversations**: How to subscribe to new/updated conversations
3. **Creating a DM**: How to create a 1:1 conversation (identifier resolution)
4. **Creating a group**: How to create a multi-party conversation with options
5. **Reachability check**: How to check if an address can receive XMTP messages
6. **Address to inbox**: How to resolve Ethereum address to inbox identifier
7. **Inbox to address**: How to resolve inbox ID back to Ethereum address
8. **Consent state**: How to read a conversation's consent state
