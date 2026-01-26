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

## Available Tools

| Tool | Purpose | Parameters |
|------|---------|------------|
| `search_xmtp_docs` | Keyword search across all XMTP docs | `query` (string), `limit` (number, default 5) |
| `get_xmtp_doc_chunk` | Fetch full content of a specific chunk | `id` (string from search), `maxChars` (number, default 6000) |

## Workflow

### Step 1: Search

Use targeted queries with multiple relevant keywords:

```
search_xmtp_docs("browser SDK client create initialize signer")
```

Review the returned chunks. Each result includes:
- `id` - Use this to fetch full content
- `title` - Document title
- `snippet` - Preview of the content

### Step 2: Retrieve

Fetch full content for relevant chunks:

```
get_xmtp_doc_chunk(id: "chunk-id-from-search", maxChars: 6000)
```

**maxChars guidance:**
- `3000` - Quick reference, single concept
- `6000` - Full examples with context (default)
- `10000+` - Complete guides or tutorials

### Step 3: Present

Extract the specific patterns needed and present them clearly:
- Method signatures with current parameter names
- Import statements with correct package names
- Working code examples adapted to the user's context

## Effective Query Patterns

| Need | Query |
|------|-------|
| Client setup | `"browser SDK client create initialize signer"` |
| Streaming messages | `"stream conversations messages real-time callbacks"` |
| Group chat | `"group chat create permissions members admin"` |
| Consent/spam | `"consent state allow block spam filter"` |
| Content types | `"content types attachments reactions replies"` |
| Sync/history | `"sync conversations messages history"` |
| Installation | `"browser SDK npm package install dependencies"` |
| WASM/bundler | `"webpack vite WASM worker configuration"` |

### Query Tips

1. **Include SDK context** - Add "browser SDK" to distinguish from Node.js patterns
2. **Use multiple keywords** - `"stream messages"` finds more than `"streaming"`
3. **Be specific** - `"group permissions admin"` vs just `"groups"`
4. **Check multiple chunks** - First result may not be the most relevant

## Fallback: WebFetch

If the XMTP docs MCP is unavailable, use the llms.txt endpoint:

```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract current browser SDK patterns for [specific feature]"
})
```

This file contains the full documentation optimized for LLM consumption.

## Integration with Other Skills

This skill is a foundation for XMTP-related skills. For example, `react-chat-builder` uses these patterns in its Phase 0 documentation lookup.

When building XMTP features:
1. Run documentation queries using this skill's patterns
2. Extract current method signatures
3. Generate code using looked-up patterns, not training data

## Common Lookup Scenarios

### Before Creating a Client
```
search_xmtp_docs("browser SDK client create signer wallet")
get_xmtp_doc_chunk(id: "...", maxChars: 6000)
```

### Before Implementing Streaming
```
search_xmtp_docs("stream conversations messages callbacks cancel")
get_xmtp_doc_chunk(id: "...", maxChars: 6000)
```

### Before Adding Content Types
```
search_xmtp_docs("content types register codec attachments")
get_xmtp_doc_chunk(id: "...", maxChars: 6000)
```

### Before Configuring Bundler
```
search_xmtp_docs("webpack vite next.js WASM configuration")
get_xmtp_doc_chunk(id: "...", maxChars: 10000)
```
