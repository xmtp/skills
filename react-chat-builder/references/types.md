# XMTP Types

TypeScript type definitions for the XMTP integration.

**IMPORTANT:** Most types should be re-exported from the SDK, not redefined. Only create custom types for app-specific needs (like optimistic UI state) that the SDK doesn't provide.

## Interface

```typescript
// Re-export SDK types (look up actual exports from docs)
export type { Client, Conversation, DecodedMessage, /* etc */ } from '[sdk-package]';

// App-level configuration (custom - not from SDK)
interface XMTPConfig {
  env: 'dev' | 'production';
  debug?: boolean;
}

// Wrapper for UI needs (extends SDK types with app-specific state)
interface MessageWithStatus {
  message: DecodedMessage; // SDK type, not recreated
  status: 'sending' | 'sent' | 'failed'; // App-specific optimistic state
  localId?: string; // For optimistic messages before server confirms
}
```

## Rules

**MUST:**
- Import and re-export SDK types (Client, Conversation, Message, etc.) - do NOT recreate them
- Create app-specific wrapper types only for UI needs not covered by SDK (e.g., optimistic message status)
- Look up actual SDK type exports before writing any type definitions

**NEVER:**
- Define types that the SDK already exports (ConsentState, Message, Conversation, etc.)
- Guess at type structures - look them up from docs
- Create parallel type hierarchies that duplicate SDK types

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
