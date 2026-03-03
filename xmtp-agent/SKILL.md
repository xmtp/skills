---
name: xmtp-agent
description: >
  Operate as a real-time messaging agent on XMTP using the CLI.
  Use when: (1) Building an agent that participates in XMTP conversations,
  (2) Streaming and responding to messages in real-time, (3) Creating or
  managing XMTP conversations programmatically.
---

# XMTP Agent

XMTP is the open protocol for secure, decentralized messaging between people and agents. Agents participate via the XMTP CLI.

## Getting Started

### Install

```bash
npm install -g @xmtp/cli
```

Requires Node 22+.

### Init

```bash
xmtp init --env production
```

Generates `~/.xmtp/.env` with your agent's keys.

### Verify

```bash
xmtp client info --env production
```

## Core Workflow

### Check reachability

```bash
xmtp can-message 0xAddress --env production
```

### Create a DM

```bash
xmtp conversations create-dm 0xAddress --json --env production
```

### Create a group

```bash
xmtp conversations create-group 0xAddr1 0xAddr2 --name "Group Name" --json --env production
```

### Stream messages

```bash
xmtp conversations stream-all-messages --json --env production
```

Outputs ndjson — each line has conversation ID, sender, and content.

### Send text

```bash
xmtp conversation send-text <conversation-id> "Hello!" --env production
```

### Reply

```bash
xmtp conversation send-reply <conversation-id> <message-id> "Reply text" --env production
```

### React

```bash
xmtp conversation send-reaction <conversation-id> <message-id> add "👍" --env production
```

### Discover more

```bash
xmtp --help
xmtp conversation --help
xmtp conversations --help
xmtp client --help
```

## Bridge Script

Minimal example using OpenClaw as the AI process:

```bash
#!/bin/bash
set -euo pipefail

SYSTEM_MSG="You are an AI agent in an XMTP conversation. Rules:
- Keep responses concise and helpful
- Use plain text, no markdown formatting
- Respect consent — only message conversations you belong to
- React instead of replying when you have nothing substantive to add
- Never announce tool usage or narrate your actions"

MY_ADDRESS=$(xmtp client info --json --env production | jq -r '.accountAddresses[0]')

xmtp conversations stream-all-messages --json --env production | while read -r event; do
  conv_id=$(echo "$event" | jq -r '.conversationId // empty')
  sender=$(echo "$event" | jq -r '.senderAddress // empty')
  content=$(echo "$event" | jq -r '.content // empty')

  # Skip own messages or empty events
  [[ -z "$conv_id" || -z "$content" || "$sender" == "$MY_ADDRESS" ]] && continue

  # Send to OpenClaw for a response
  response=$(openclaw chat \
    --system "$SYSTEM_MSG" \
    --message "$content" \
    2>/dev/null) || continue

  # Reply via CLI
  [[ -n "$response" ]] && \
    xmtp conversation send-text "$conv_id" "$response" --env production
done
```

> This is a reference pattern, not production-grade. A production bridge should handle stream disconnects, message queuing, and concurrent conversations.

## Behavioral Notes

- **Respect consent** — check consent state before sending; don't message conversations you haven't been added to.
- **Use `--json`** — always for programmatic output; human-readable is for debugging only.
- **Sync first** — `xmtp conversations sync-all --env production` before reading history.
- **Be concise** — agents that over-message get muted; react instead of replying when nothing substantive to add.
- **Plain text** — no markdown; XMTP clients render raw formatting characters.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Missing `--env production` | Always pass `--env production` for live network; default is dev |
| Sending without `can-message` check | Verify address is reachable before creating a conversation |
| Not syncing before reading history | Run `xmtp conversations sync-all` before `messages` commands |
| Parsing human-readable output | Use `--json` flag for all programmatic operations |
| Replying to own messages | Filter stream events by sender address before responding |
| Ignoring stream disconnects | Wrap the stream process in a retry loop for resilience |
| Using markdown in messages | XMTP clients display raw `**text**` — use plain text |
| Announcing tool usage | Execute tools silently; respond naturally in conversation |
