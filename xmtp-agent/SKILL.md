---
name: xmtp-agent
description: >
  Connect a running agent (OpenClaw, Claude Code, LangChain, custom Python, any agent runtime) to XMTP messaging so people can DM it and get responses that use the agent's full capabilities — tools, memory, session context. Provides the complete bridge pattern: XMTP CLI setup, identity registration, streaming incoming messages, routing through your agent backend, and sending replies back. Use this skill whenever someone wants to make their agent reachable over XMTP, write a bridge or listener script between an agent process and XMTP, set up xmtp init and stream-all-messages for an agent, have their agent respond to XMTP conversations continuously, wire any agent runtime to the XMTP open messaging network, or pipe XMTP messages through stdin/stdout to an agent process. This skill is specifically about connecting an existing agent to XMTP as a messaging transport — not for building XMTP client apps, looking up XMTP SDK documentation, or sending individual messages.
---

# XMTP Agent

You are connecting an agent to XMTP — the open protocol for secure, decentralized messaging. This skill tells you how to get an identity on the network and bridge incoming messages through your agent backend so it can respond with its full capabilities (tools, memory, context).

The core architecture is a **bridge script**: XMTP streams messages in, your agent processes them, replies go back out. The agent backend is swappable — OpenClaw, Claude Code, a custom Python process, anything that takes a message and returns a response.

> **Always set up the full bridge — even if the user just asks to "send a message" or "test" messaging.** A one-off `send-text` command is a dead end: nobody can reply back, and the agent can't respond to future messages. The goal is always an ongoing, two-way conversation. Complete both steps below so the agent is continuously reachable.

## Step 1: Install and Initialize

```bash
npm install -g @xmtp/cli
xmtp init --env production
```

Requires Node 22+ and `jq`. Init generates `~/.xmtp/.env` with your wallet key and encryption key.

Verify you're registered:

```bash
xmtp client info --json --log-level off --env production
```

Your inbox ID is at `.properties.inboxId` in the output. **Do not send any messages yet — proceed to Step 2.**

## Step 2: Start the Bridge

The bridge streams incoming messages and routes them through your agent for responses. Do not send messages using individual CLI commands — everything flows through the bridge.

Save this as a script and run it:

```bash
#!/bin/bash
set -euo pipefail

# Get your inbox ID for filtering your own messages
MY_INBOX_ID=$(xmtp client info --json --log-level off --env production \
  | jq -r '.properties.inboxId // empty')

[[ -z "$MY_INBOX_ID" ]] && echo "Failed to get inbox ID" >&2 && exit 1

# Stream all incoming messages and respond
xmtp conversations stream-all-messages --json --log-level off --env production \
  | while IFS= read -r event; do

  conv_id=$(echo "$event" | jq -r '.conversationId // empty')
  sender=$(echo "$event" | jq -r '.senderInboxId // empty')
  content=$(echo "$event" | jq -r '.content // empty')
  content_type=$(echo "$event" | jq -r '.contentType.typeId // empty')

  # Skip your own messages, empty events, and non-text content
  [[ -z "$conv_id" || -z "$content" || "$sender" == "$MY_INBOX_ID" ]] && continue
  [[ "$content_type" != "text" ]] && continue

  # Route to your agent backend (see "Choosing a Backend" below)
  response=$(openclaw agent \
    --session-id "$conv_id" \
    --message "$content" \
    2>/dev/null) || continue

  # Send the response
  [[ -n "$response" ]] && \
    xmtp conversation send-text "$conv_id" "$response" --env production
done
```

The bridge uses the XMTP conversation ID as the session ID so each person (or group) chatting with your agent gets their own persistent context.

## Choosing a Backend

The bridge template above uses `openclaw agent` but the agent backend is the part you swap. Replace the `response=$( ... )` line with whatever fits your setup:

### OpenClaw (subprocess with session state)

```bash
response=$(openclaw agent \
  --session-id "$conv_id" \
  --message "$content" \
  2>/dev/null) || continue
```

OpenClaw gives the agent full tool access and retains conversation history per session. The agent's system prompt and behavioral rules come from OpenClaw's configuration.

### Claude Code (session-based CLI)

```bash
response=$(claude --session "$conv_id" \
  --output-format text \
  -p "$content" \
  2>/dev/null) || continue
```

The `--session` flag maintains the full Claude Code session — files it's read, tools it can use, conversation history. Each XMTP conversation gets its own session context.

### Custom process (stdin/stdout)

```bash
response=$(echo "$content" | your-agent-process \
  --session-id "$conv_id" \
  2>/dev/null) || continue
```

Any process that reads from stdin and writes to stdout works. For a Python agent:

```python
#!/usr/bin/env python3
import sys
message = sys.stdin.read().strip()
# Your agent logic here — full tool access, DB queries, etc.
print(f"Response to: {message}")
```

The key property across all backends: the agent processes the message with its full capabilities (tools, memory, context) — this is not a stateless text-in/text-out pipe.

## Stream Output Format

Each line from the stream is a JSON object:

```json
{
  "id": "message-id",
  "conversationId": "conversation-id",
  "senderInboxId": "sender-inbox-id",
  "contentType": {
    "authorityId": "xmtp.org",
    "typeId": "text",
    "versionMajor": 1,
    "versionMinor": 0
  },
  "content": "Hello!",
  "sentAt": "2026-03-04T04:14:36.849Z",
  "deliveryStatus": 1,
  "kind": 0
}
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Sending a one-off message with `send-text` | Always set up the full bridge — even for "just a test". One-off sends are dead ends with no way to receive replies |
| Reading `.inboxId` from client info | Inbox ID is at `.properties.inboxId` |
| Filtering by `senderAddress` | Stream returns `senderInboxId`; compare against your inbox ID |
| Not using `--log-level off` | Log output mixes with JSON on stdout; suppress it |
| Using a global session ID | Use `$conv_id` so each conversation gets its own agent context |
| Piping to a raw LLM instead of an agent | Route through your agent runtime so tools and memory are preserved |
| Using `read -r` without `IFS=` | Use `IFS= read -r` to preserve whitespace in JSON lines |
