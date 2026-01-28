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

// Minimal type for client reference
type XMTPClient = { inboxId: string; close: () => Promise<void> };

// Signer interface for wallet integration
type Signer = {
  type: "EOA";
  getIdentifier: () => Identifier;
  signMessage: (message: string) => Promise<Uint8Array>;
};

type Identifier = {
  identifier: string;        // Ethereum address (0x...)
  identifierKind: "Ethereum"; // Literal string, NOT an enum
};

function useXMTP(): UseXMTPReturn;
```

Note: The `XMTPClient` type is intentionally minimal—only properties the hook exposes.

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
- Use `identifierKind: "Ethereum"` as string literal (not enum)
- Convert wallet signature hex strings to Uint8Array

**NEVER:**
- Leave stale clients open when initializing new connection
- Expose raw SDK error types to consumers
- Hard-code environment values
- Try to import `IdentifierKind` enum from browser SDK (doesn't exist)

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
3. **Signer interface**: Current structure for EOA signers
4. **Client cleanup**: How to properly close/disconnect a client
5. **Package exports**: Package name and exports for browser SDK
