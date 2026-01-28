# XMTP Types

TypeScript type definitions for the XMTP integration.

## Interface

```typescript
// App-level configuration
interface XMTPConfig {
  /** XMTP environment: 'dev' for testing, 'production' for mainnet */
  env: 'dev' | 'production';
  /** Enable debug logging */
  debug?: boolean;
}

// Wrapper types for app-specific needs
interface ConversationWithMetadata {
  id: string;
  /** Last message preview text */
  lastMessagePreview?: string;
  /** Last message timestamp */
  lastMessageAt?: Date;
  /** Unread message count */
  unreadCount: number;
  /** Whether this is a group conversation */
  isGroup: boolean;
  /** Display title (peer address for DMs, group name for groups) */
  title: string;
}

interface MessageWithStatus {
  id: string;
  content: unknown; // Content structure depends on content type
  sentAt: Date;
  senderAddress: string;
  /** Sending status for optimistic updates */
  status: 'sending' | 'sent' | 'failed';
  /** Local ID for optimistic messages before server confirmation */
  localId?: string;
}
```

## Rules

**MUST:**
- Re-export SDK types from a single location for convenience
- Create app-specific wrapper types for UI needs (metadata, status tracking)
- Use opaque types for SDK internals - don't expose internal structure
- Track message status for optimistic UI updates
- Assign local IDs to optimistic messages until server confirms

**NEVER:**
- Redefine SDK types - re-export them
- Assume SDK type structure in app code - wrap and normalize
- Hardcode content type structures - look them up

**CONDITIONAL TYPES:**
Only include these if the corresponding feature is enabled:
- Attachment types (if Q6 includes attachments)
- Reaction types (if Q6 includes reactions)
- Reply types (if Q6 includes replies)

## Look Up

Before implementing, query `/xmtp-docs` for:

| Purpose | What to Find |
|---------|--------------|
| SDK exports | What types does the browser SDK export? Package name? |
| Message structure | What properties does a decoded message have? |
| Conversation structure | What properties does a conversation have? Group vs DM? |
| Content types | Type structures for attachment, reaction, reply content types |
| Identifier types | How are addresses/identifiers structured? |
