# ErrorBoundary

React error boundary for XMTP components with retry capability.

## Interface

```typescript
interface ErrorBoundaryProps {
  children: React.ReactNode;
  /** Fallback UI when error occurs. Receives error and retry function. */
  fallback?: (error: Error, retry: () => void) => React.ReactNode;
  /** Called when error is caught */
  onError?: (error: Error, errorInfo: React.ErrorInfo) => void;
  /** Reset error state when these values change */
  resetKeys?: unknown[];
}
```

## Rules

**MUST:**
- Wrap XMTP-related component trees, not the entire app
- Provide retry action in every fallback UI
- Preserve XMTPProvider when catching errors (only unmount failing subtree)
- Map SDK errors to user-friendly messages
- Log full error details in debug mode
- Support `resetKeys` to auto-retry when dependencies change

**NEVER:**
- Show raw error messages to users
- Unmount the entire app on XMTP errors
- Swallow errors without logging

**ERROR MESSAGE MAPPING:**

Map error categories to friendly messages:

| Error Category | User Message |
|----------------|--------------|
| Network/connection errors | "Connection lost. Check your internet and try again." |
| Wallet disconnected | "Wallet disconnected. Please reconnect your wallet." |
| Not registered on XMTP | "This wallet isn't registered on XMTP yet." |
| Permission/signature denied | "Permission denied. Please approve the request in your wallet." |
| Unknown/other | "Something went wrong. Please try again." |

Detect error category by examining error message content or error class name - look up actual SDK error types before implementing.

**FALLBACK UI REQUIREMENTS:**
- Warning/error icon
- User-friendly message (from mapping above)
- Retry button with visual feedback on click
- Match app's design system styling

## Look Up

Before implementing, query `/xmtp-docs` for:

| Purpose | What to Find |
|---------|--------------|
| SDK errors | What error types/classes does the SDK throw? |
| Error messages | What error messages indicate which failure modes? |
| Error codes | Are there error codes for programmatic handling? |
