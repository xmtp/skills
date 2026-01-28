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
  senderInboxId: string;
  /** Message type determines rendering strategy */
  type: 'text' | 'system' | 'attachment' | 'reaction' | 'reply';
  /** Sending status for optimistic updates */
  status: 'sending' | 'sent' | 'failed';
  /** Local ID for optimistic messages before server confirmation */
  localId?: string;
}

/** System messages represent group events, not user-sent content */
interface SystemMessage {
  id: string;
  type: 'system';
  event: 'member_added' | 'member_removed' | 'member_left' | 'group_renamed' | 'group_created';
  /** Who performed the action (inboxId) */
  actorInboxId?: string;
  /** Who was affected (inboxId) - for add/remove events */
  targetInboxId?: string;
  /** Additional metadata (e.g., new group name) */
  metadata?: string;
  sentAt: Date;
}

/** Cached identity resolution result */
interface ResolvedIdentity {
  address: string;
  ensName: string | null;
  avatar: string | null;
  resolvedAt: number;
}
```

## Behavior

**Wrapper types:**
- App-specific types wrap SDK types with additional metadata
- Status tracking enables optimistic UI updates
- Local IDs track optimistic messages until confirmed

**System messages:**
- Represent group events, not user content
- Rendered differently (centered, no avatar)
- Actor and target resolved through identity chain

## Rules

**MUST:**
- Re-export SDK types from a single location
- Create app-specific wrapper types for UI needs
- Use opaque types for SDK internals
- Track message status for optimistic updates
- Assign local IDs to optimistic messages

**NEVER:**
- Redefine SDK types (re-export them)
- Assume SDK type structure in app code
- Hardcode content type structures
- Store addresses when SDK provides inboxIds

## Look Up

Before implementing, query `/xmtp-docs` for:

1. **SDK exports**: What types does the browser SDK export? Package name?
2. **Message structure**: What properties does a decoded message have?
3. **Conversation structure**: What properties does a conversation have?
4. **Content types**: Type structures for attachment, reaction, reply
5. **Identifier types**: How are addresses/identifiers structured?
