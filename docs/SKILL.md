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

### Step 1: Find the right page

Use the docs index to find which page has what you need:

```
WebFetch({
  url: "https://docs.xmtp.org/llms.txt",
  prompt: "Find the page URL for [topic]"
})
```

### Step 2: Fetch that page

Fetch the specific page for complete code examples:

```
WebFetch({
  url: "https://docs.xmtp.org/[path-from-step-1]",
  prompt: "Extract [specific feature] with code examples"
})
```

## Common Pages

| Need | Page |
|------|------|
| Browser SDK setup | `/chat-apps/sdks/browser` |
| Create a signer | `/chat-apps/core-messaging/create-a-signer` |
| Create a client | `/chat-apps/core-messaging/create-a-client` |
| Create conversations | `/chat-apps/core-messaging/create-conversations` |
| Send messages | `/chat-apps/core-messaging/send-messages` |
| List conversations | `/chat-apps/list-stream-sync/list` |
| Stream messages | `/chat-apps/list-stream-sync/stream` |
| Sync conversations | `/chat-apps/list-stream-sync/sync-and-syncall` |
| Group permissions | `/chat-apps/core-messaging/group-permissions` |
| User consent | `/chat-apps/user-consent/support-user-consent` |
| Content types | `/chat-apps/content-types/content-types` |
| Attachments | `/chat-apps/content-types/attachments` |
| Reactions | `/chat-apps/content-types/reactions` |
| Replies | `/chat-apps/content-types/replies` |

## Example

To find how to list conversations:

```
WebFetch({
  url: "https://docs.xmtp.org/chat-apps/list-stream-sync/list",
  prompt: "Extract how to list conversations with code examples"
})
```

## Tips

1. **Fetch specific pages** - The full docs (llms-full.txt) is 500KB+ and WebFetch may miss content
2. **Ask for code examples** - Docs include examples for Browser, Node, Kotlin, and Swift
3. **One topic per query** - Focused queries return better results
