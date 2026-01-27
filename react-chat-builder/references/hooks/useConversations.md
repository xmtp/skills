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

export function useConversations(options?: UseConversationsOptions): UseConversationsReturn;
```

Note: The interface exposes `peerAddress` (user-friendly Ethereum address). The implementation handles any SDK-required transformations internally.

## Rules

**MUST:**
- Lowercase all addresses before any SDK operation
- Check if peer can receive messages BEFORE attempting to create a DM
- Resolve address to inbox identifier before creating DM (SDK requires identifier, not raw address)
- Use XMTPStreamManager pattern for streaming (connection tokens, AbortController, auto-reconnect)
- Filter conversations by consent state before adding to store
- Clean up streams on unmount
- **Stabilize array options** - Use constants or refs for default values (see below)
- **Use `instanceof` to determine conversation type** - See mapping pattern below

**NEVER:**
- Expose inbox IDs in the hook's public API - users work with addresses
- Skip the "can receive messages" check - it prevents confusing errors
- Pass raw Ethereum addresses to DM/group creation methods - resolve to inbox first
- Assume stream methods are synchronous
- **Use inline arrays in useEffect/useCallback dependencies** - Creates new reference each render

**ARRAY STABILITY PATTERN:**

Options like `consentStates` are arrays. Passing inline arrays (`["allowed", "unknown"]`) creates new references each render, breaking memoization:

```typescript
// ❌ BAD: New array reference every render
useConversations({ consentStates: ["allowed", "unknown"] });

// ✅ GOOD: Stable reference via constant
const DEFAULT_CONSENT_STATES: ConsentState[] = ["allowed", "unknown"];
useConversations({ consentStates: DEFAULT_CONSENT_STATES });
```

**Inside the hook implementation**, stabilize with string comparison:

```typescript
// Stabilize array props to prevent infinite loops
const consentStatesKey = options?.consentStates?.sort().join(",") ?? "";
const stableConsentStates = useMemo(
  () => options?.consentStates ?? DEFAULT_CONSENT_STATES,
  [consentStatesKey]
);

// Guard against re-initialization
const initializedRef = useRef(false);
useEffect(() => {
  if (initializedRef.current) return;
  initializedRef.current = true;
  // ... initialization logic
}, [stableConsentStates]);
```

**CONVERSATION TYPES:**

The SDK has separate `Dm` and `Group` classes (both extend `Conversation`). To determine type:
- Use `instanceof Dm` or `instanceof Group` when mapping from `list()` results
- Or use `listGroups()` / `listDms()` to get type-specific results directly

Look up current SDK class properties and methods before implementing the mapping.

**INBOX ID VS ADDRESS:**

XMTP conversations expose inbox IDs (opaque identifiers), not Ethereum addresses. For features like ENS display or identity resolution, you need the underlying address:
- Store the peer's Ethereum address in your local Conversation type, not just inbox ID
- Resolve inbox ID → address when mapping SDK conversations to your store
- Look up how to perform this resolution before implementing

**OPTIMISTIC GROUP CREATION:**
- Allow creating a group with no members (empty array) - user can add members later
- This enables "create first, invite later" UX patterns
- The creator is always a member, so a "no members" group has 1 member (the creator)

**CONSENT STATES:**
| State | Description | UI Location |
|-------|-------------|-------------|
| `Allowed` | User accepted | Main inbox |
| `Unknown` | New sender | Requests inbox |
| `Denied` | User blocked | Hidden |

**ERROR HANDLING:**
- Address not on XMTP → "Address is not registered on XMTP" with helpful signup info
- Could not find inbox → Check address format and network
- Group member not on XMTP → List which member(s) need to register

## Look Up

Before implementing, query XMTP docs for current patterns:

1. **Syncing conversations**: How to sync and list existing conversations
2. **Streaming conversations**: How to subscribe to new/updated conversations
3. **Creating a DM**: How to create a 1:1 conversation (what identifier/inbox resolution is needed?)
4. **Creating a group**: How to create a multi-party conversation with options
5. **Reachability check**: How to check if an address can receive XMTP messages
6. **Address to inbox**: How to resolve an Ethereum address to the SDK's inbox identifier
7. **Inbox to address**: How to resolve an inbox ID back to the underlying Ethereum address
8. **Consent state**: How to read a conversation's consent state for filtering
