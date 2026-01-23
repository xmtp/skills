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
  updateActivity: () => void; // Reset session timeout on user interaction
}

// Local type for client reference (avoids build-time WASM resolution)
type XMTPClient = { inboxId: string; close: () => Promise<void> };

// Signer interface for wallet integration
type Signer = {
  type: "EOA";
  getIdentifier: () => { identifier: string; identifierKind: unknown };
  signMessage: (message: string) => Promise<Uint8Array>;
};

export function useXMTP(): UseXMTPReturn;
```

Note: The `XMTPClient` type is intentionally minimal to avoid importing SDK types at build time.

## Rules

**MUST:**
- Use dynamic import for `@xmtp/browser-sdk` - never static import (SSR/WASM compatibility)
- Track connection with a token/counter to handle race conditions when user switches accounts
- Close existing client before creating a new one
- Validate XMTP environment at runtime (dev/production)
- Implement session timeout to disconnect after inactivity (default: 30 minutes)
- Normalize all errors to `Error` type before exposing

**NEVER:**
- Import SDK types at the top level of the file
- Leave stale clients open when initializing a new connection
- Expose raw SDK error types to consumers
- Hard-code environment values - read from env vars

**ERROR HANDLING:**
- Signature rejected → Ask user to sign again
- Network error → Retry connection
- Database/OPFS error → Close other tabs using XMTP
- Invalid signer → Check wallet connection

## Look Up

Before implementing, query XMTP docs for current patterns:

1. **Client creation**: How to create an XMTP client with a signer
2. **Environment config**: How to specify dev vs production network
3. **Signer interface**: Current structure for EOA signers (identifier, identifierKind)
4. **Client cleanup**: How to properly close/disconnect a client
5. **Dynamic import**: Confirm the package name and exports for browser SDK
