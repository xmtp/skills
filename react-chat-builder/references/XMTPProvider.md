# XMTPProvider

React context provider that manages XMTP client lifecycle and provides client access to child components.

## Interface

```typescript
interface XMTPProviderProps {
  children: React.ReactNode;
}

interface XMTPContextValue {
  client: Client | null;
  isConnecting: boolean;
  isConnected: boolean;
  error: Error | null;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
}

// Client type is intentionally opaque
type Client = { inboxId: string };
```

## Behavior

**Initialization:**
- Client created lazily on `connect()` call, NOT on mount
- Signer obtained from wallet provider context
- Single client instance enforced per app

**Disconnection:**
- Stops all active streams
- Closes client connection
- Clears client reference (OPFS data persists)

**Wallet integration:**
- Listens for wallet account changes
- If account changes while connected: disconnect and prompt reconnect
- If wallet disconnects: set error state, clear client

## Rules

**MUST:**
- Enforce single client instance per app
- Initialize client lazily (on connect, not mount)
- Get signer from wallet provider context
- Clean up streams and close client on disconnect
- Capture errors in state (don't throw)
- Render safely on server

**NEVER:**
- Create client on provider mount
- Leave orphaned clients when user switches accounts
- Expose raw SDK errors
- Log sensitive data (keys, signatures)

## States

| State | Description |
|-------|-------------|
| `client: null, isConnecting: false` | Ready to connect |
| `client: null, isConnecting: true` | Wallet signature pending |
| `client: present, isConnected: true` | Connected, ready for operations |
| `error: present` | Connection failed |

## Look Up

Before implementing, query `/xmtp-docs` for:

1. **Create client**: How to create an XMTP client with a signer
2. **Client options**: How to configure database path, environment, logging
3. **Close client**: How to properly close/cleanup a client
4. **Check registration**: How to check if address is registered on XMTP
5. **Signer interface**: Current structure for EOA signers
