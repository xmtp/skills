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

// Client type is intentionally opaque - consumers only need these properties
type Client = { inboxId: string };
```

## Rules

**MUST:**
- Enforce single client instance per app
- Initialize client lazily (on `connect()` call, not on mount)
- Get signer from wallet provider context (wagmi, ethers, etc.)
- Clean up streams and close client on `disconnect()`
- Capture errors in state, not throw - let components handle gracefully
- Render safely on server (client initialization browser-only)

**NEVER:**
- Create client on provider mount
- Leave orphaned clients when user switches accounts
- Expose raw SDK errors - normalize to standard Error type
- Log sensitive data (keys, signatures)

**PERSISTENCE:**
- Client persists messages in OPFS (Origin Private File System)
- Same wallet address = same message history across sessions
- OPFS data persists after `disconnect()` - only client reference is cleared

**WALLET INTEGRATION:**
- Listen for wallet account changes
- If account changes while connected, disconnect and prompt to reconnect
- If wallet disconnects, set error state and clear client

## Look Up

Before implementing, query `/xmtp-docs` for:

| Purpose | What to Find |
|---------|--------------|
| Create client | How to create an XMTP client with a signer |
| Client options | How to configure database path, environment (dev/production), logging |
| Close client | How to properly close/cleanup a client |
| Check registration | How to check if an address is registered on XMTP network |
| Signer interface | Current structure for EOA signers |
