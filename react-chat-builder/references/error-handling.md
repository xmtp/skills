# Error Handling

Consolidated error patterns for XMTP chat applications.

## Error Categories

### Connection Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| Signature rejected | "Please sign the message to connect" | Prompt to retry |
| Network error | "Couldn't connect. Check your internet connection." | "Try again" button |
| Database/OPFS error | "Storage conflict. Close other tabs using this app." | Automatic retry after tab check |
| Invalid signer | "Wallet connection issue. Please reconnect." | Prompt wallet reconnect |
| Unknown client error | "Connection failed" | "Try again" button |

### Sending Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| Send failed | "Message not sent" | "Retry" button on message |
| Network timeout | "Taking too long. Check connection." | Auto-retry with backoff |
| Recipient unreachable | "Couldn't deliver message" | "Retry" button |
| Content too large | "File too large to send" | User resizes/compresses |

### Streaming Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| Stream disconnected | [Silent - no message] | Auto-reconnect |
| Reconnection failed (>10 attempts) | "Lost connection. Trying to reconnect..." | Toast notification |
| Client closed | [No message - expected] | Stop reconnection |

### Identity Resolution Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| Invalid address format | "Invalid Ethereum address" | User corrects input |
| ENS resolution failed | "Couldn't resolve [name]" | Show address instead |
| Address not on XMTP | "This address hasn't joined XMTP yet" | Provide signup info |
| Inbox lookup failed | "Couldn't find this contact" | Suggest retry |

### Conversation Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| Create DM failed | "Couldn't start conversation" | "Try again" button |
| Create group failed | "Couldn't create group" | "Try again" button |
| Member not on XMTP | "[address] isn't on XMTP yet" | List invalid addresses |
| Not authorized | "You don't have permission for this action" | Explain required permission |
| Sync failed | "Couldn't load conversations" | "Refresh" button |

### Consent Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| Allow failed | "Couldn't accept conversation" | Auto-retry |
| Block failed | "Couldn't block sender" | Auto-retry |

## Rules

**MUST:**
- Normalize all SDK errors to standard Error type
- Include user-friendly message for every error
- Provide actionable recovery for recoverable errors
- Log errors for debugging (respecting debug flag)
- Update UI state to reflect error condition

**NEVER:**
- Expose raw SDK error messages to users
- Show technical details in production
- Leave UI in loading state after error
- Block user interaction during error recovery
- Log sensitive data (keys, signatures, personal info)

## Error Boundaries

| Boundary | Catches | Fallback |
|----------|---------|----------|
| Root | Entire chat crashes | "Something went wrong. Refresh to try again." |
| ConversationList | List rendering errors | "Couldn't load conversations" + retry |
| MessageThread | Message rendering errors | "Couldn't load messages" + retry |
| MessageComposer | Send form errors | Reset form, show error toast |

## Toast Notifications

| Scenario | Type | Duration | Message |
|----------|------|----------|---------|
| Send failed | Error | Persistent | "Message not sent" + retry action |
| Connection lost (10+ retries) | Warning | Persistent | "Reconnecting..." |
| Connection restored | Success | 3s | "Connected" |
| Action completed | Success | 2s | "[Action] successful" |

## Look Up

Before implementing, check:

1. **SDK error types**: What errors does the XMTP SDK throw?
2. **Error codes**: Does the SDK use specific error codes?
3. **Retry guidance**: SDK recommendations for retry logic?
