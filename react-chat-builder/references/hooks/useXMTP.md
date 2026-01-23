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
  getIdentifier: () => Identifier;
  signMessage: (message: string) => Promise<Uint8Array>;
};

// IMPORTANT: identifierKind is a string literal, not an enum import
type Identifier = {
  identifier: string;        // Ethereum address (0x...)
  identifierKind: "Ethereum"; // Literal string - NOT an enum
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
- Use `identifierKind: "Ethereum"` as a **string literal** - the browser SDK does not export an enum
- Convert wallet signature hex strings to `Uint8Array` before returning from `signMessage`

**NEVER:**
- Import SDK types at the top level of the file
- Leave stale clients open when initializing a new connection
- Expose raw SDK error types to consumers
- Hard-code environment values - read from env vars
- Try to import `IdentifierKind` enum from browser SDK - it doesn't exist (Node SDK only)

**ERROR HANDLING:**
- Signature rejected → Ask user to sign again
- Network error → Retry connection
- Database/OPFS error → Close other tabs using XMTP
- Invalid signer → Check wallet connection

**CREATING A SIGNER FROM WAGMI/VIEM:**

```typescript
import { useWalletClient } from "wagmi";
import { toBytes } from "viem";

function createSigner(walletClient: WalletClient): Signer {
  const address = walletClient.account.address;

  return {
    type: "EOA",
    getIdentifier: () => ({
      identifier: address.toLowerCase(),
      identifierKind: "Ethereum",  // String literal, not enum
    }),
    signMessage: async (message: string) => {
      const signature = await walletClient.signMessage({ message });
      return toBytes(signature);  // Convert hex to Uint8Array
    },
  };
}
```

## Look Up

Before implementing, query XMTP docs for current patterns:

1. **Client creation**: How to create an XMTP client with a signer
2. **Environment config**: How to specify dev vs production network
3. **Signer interface**: Current structure for EOA signers (identifier, identifierKind)
4. **Client cleanup**: How to properly close/disconnect a client
5. **Dynamic import**: Confirm the package name and exports for browser SDK
