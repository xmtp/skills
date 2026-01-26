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

Training data may contain outdated patterns like:
- Deprecated client initialization methods
- Old package names (`@xmtp/xmtp-js` vs `@xmtp/browser-sdk`)
- Removed or renamed content type APIs
- Obsolete streaming patterns

Always query documentation first to get current, working patterns.

## How to Query

Use WebFetch with the XMTP llms.txt endpoint:

```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract current browser SDK patterns for [specific feature]"
})
```

This file contains the full XMTP documentation optimized for LLM consumption.

## Effective Query Prompts

| Need | Prompt |
|------|--------|
| Client setup | `"Extract current browser SDK client creation and initialization patterns with signer"` |
| Streaming | `"Extract patterns for streaming conversations and messages with callbacks"` |
| Group chat | `"Extract group chat creation, permissions, and member management patterns"` |
| Consent/spam | `"Extract consent state management patterns for allow, block, and spam filtering"` |
| Content types | `"Extract content type patterns for attachments, reactions, and replies"` |
| Sync/history | `"Extract conversation and message sync patterns for loading history"` |
| Installation | `"Extract browser SDK package names and installation instructions"` |
| Bundler config | `"Extract webpack and vite configuration for WASM and workers"` |

## Workflow

### Step 1: Identify What You Need

Before querying, identify the specific XMTP features you need:
- Client initialization?
- Message streaming?
- Group management?
- Content types?

### Step 2: Query Documentation

Make a targeted WebFetch request:

```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract the current method signatures and code examples for creating an XMTP client with a wallet signer in the browser SDK"
})
```

### Step 3: Extract and Apply

From the response, extract:
- Correct import statements and package names
- Current method signatures
- Working code examples

Apply these patterns directly—don't mix with training data.

## Query Tips

1. **Be specific** - "browser SDK client creation" not just "client"
2. **Ask for examples** - "with code examples" gets working snippets
3. **Include context** - "for React/Next.js" if framework-specific
4. **Request signatures** - "method signatures" gets exact APIs

## Common Queries

### Before Creating a Client
```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract browser SDK client creation patterns including signer setup, environment configuration, and database options"
})
```

### Before Implementing Streaming
```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract patterns for streaming new conversations and messages, including how to cancel streams"
})
```

### Before Adding Content Types
```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract content type registration and codec patterns for attachments and reactions"
})
```

### Before Configuring Bundler
```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract Next.js and Vite configuration requirements for XMTP WASM and workers"
})
```

## Integration with Other Skills

This skill provides the documentation lookup pattern for XMTP-related skills. When building XMTP features:

1. Query documentation using the patterns above
2. Extract current method signatures
3. Generate code using looked-up patterns, not training data
