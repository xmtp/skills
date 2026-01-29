# useXMTP Hook

Core hook for XMTP client initialization and connection state.

## Interface

```typescript
interface UseXMTPReturn {
  // Client state
  client: XMTPClient | null;
  inboxId: string | null;

  // Connection state
  isConnecting: boolean;
  isConnected: boolean;
  error: Error | null;

  // Actions
  initialize: (signer: Signer) => Promise<void>;
  disconnect: () => Promise<void>;
  updateActivity: () => void;
}

// Minimal type for client reference - only properties the hook exposes
type XMTPClient = { inboxId: string; close: () => Promise<void> };

// Signer type - LOOK UP current structure from XMTP docs
type Signer = unknown; // Shape depends on SDK version

function useXMTP(): UseXMTPReturn;
```

## Behavior

**Initialization:**
- Takes a signer from wallet provider
- Creates XMTP client with environment config
- Stores client reference and updates connection state

**Disconnection:**
- Closes existing client
- Clears store state
- Resets connection status

**Session timeout:**
- Tracks user activity
- Disconnects after inactivity period (default: 30 minutes)
- `updateActivity()` resets the timeout

## Rules

**MUST:**
- Track connection with token/counter to handle race conditions
- Close existing client before creating new one
- Validate XMTP environment at runtime (dev/production)
- Implement session timeout for inactivity
- Normalize all errors to `Error` type

**NEVER:**
- Leave stale clients open when initializing new connection
- Expose raw SDK error types to consumers
- Hard-code environment values

## States

| State | Description |
|-------|-------------|
| `client: null, isConnecting: false` | Disconnected, ready to connect |
| `client: null, isConnecting: true` | Connection in progress |
| `client: present, isConnected: true` | Connected, ready for operations |
| `error: present` | Connection failed, display error |

## Look Up

Before implementing, query XMTP docs for:

1. **Client creation**: How to create an XMTP client with a signer
2. **Environment config**: How to specify dev vs production network
3. **Signer interface**: Current structure for EOA signers (type, methods, identifier format)
4. **Client cleanup**: How to properly close/disconnect a client
5. **Package exports**: Package name and exports for browser SDK
6. **Signature format**: Does the SDK expect hex strings or Uint8Array for signatures?
7. **Identifier structure**: What fields does the identifier object need?
