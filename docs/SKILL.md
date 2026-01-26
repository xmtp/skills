---
name: xmtp-docs
description: >
  Query XMTP documentation for current SDK patterns, methods, and examples.
  Use when: (1) Looking up XMTP SDK methods or patterns, (2) Verifying
  current API signatures before coding, (3) Finding examples for XMTP
  features like streaming, consent, groups, or content types.
---

# XMTP Documentation Lookup

Query current XMTP documentation to find accurate SDK patterns before writing code.

## Why This Skill Exists

> **CRITICAL:** Never use training data for XMTP SDK methods. The SDK evolves
> frequently and method names change between versions. All method names,
> signatures, and patterns MUST be looked up from current documentation.

## How to Query

Use WebFetch with specific documentation pages for SDK code examples:

```
WebFetch({
  url: "https://docs.xmtp.org/chat-apps/sdks/browser",
  prompt: "Extract code examples for [specific feature]"
})
```

## SDK Implementation Pages

These pages contain code examples. Use for implementation lookups:

| Need | URL |
|------|-----|
| Browser SDK setup | `https://docs.xmtp.org/chat-apps/sdks/browser` |
| Create a signer | `https://docs.xmtp.org/chat-apps/core-messaging/create-a-signer` |
| Create a client | `https://docs.xmtp.org/chat-apps/core-messaging/create-a-client` |
| Create conversations | `https://docs.xmtp.org/chat-apps/core-messaging/create-conversations` |
| Send messages | `https://docs.xmtp.org/chat-apps/core-messaging/send-messages` |
| List conversations | `https://docs.xmtp.org/chat-apps/list-stream-sync/list` |
| Stream messages | `https://docs.xmtp.org/chat-apps/list-stream-sync/stream` |
| Sync conversations | `https://docs.xmtp.org/chat-apps/list-stream-sync/sync-and-syncall` |
| Group permissions | `https://docs.xmtp.org/chat-apps/core-messaging/group-permissions` |
| User consent | `https://docs.xmtp.org/chat-apps/user-consent/support-user-consent` |
| Content types | `https://docs.xmtp.org/chat-apps/content-types/content-types` |
| Attachments | `https://docs.xmtp.org/chat-apps/content-types/attachments` |
| Reactions | `https://docs.xmtp.org/chat-apps/content-types/reactions` |
| Replies | `https://docs.xmtp.org/chat-apps/content-types/replies` |

## Protocol Concepts

For understanding how XMTP works (not code examples), use the full docs:

```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract [concept] - how it works and why"
})
```

Good for: identity model, epochs, gateway service setup, fee structure, security properties.

## Example Queries

### Get browser SDK code patterns
```
WebFetch({
  url: "https://docs.xmtp.org/chat-apps/sdks/browser",
  prompt: "Extract all code examples for client creation, conversations, and messaging"
})
```

### Get signer implementation
```
WebFetch({
  url: "https://docs.xmtp.org/chat-apps/core-messaging/create-a-signer",
  prompt: "Extract signer creation code for EOA and smart contract wallets"
})
```

### Get streaming patterns
```
WebFetch({
  url: "https://docs.xmtp.org/chat-apps/list-stream-sync/stream",
  prompt: "Extract code examples for streaming conversations and messages"
})
```

### Understand the identity model
```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract the identity model - how inbox IDs, identities, and installations work"
})
```
