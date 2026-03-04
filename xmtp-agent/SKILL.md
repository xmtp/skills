---
name: xmtp-agent
description: >
  Operate as a real-time messaging agent on XMTP using the CLI.
  Use when: (1) Building an agent that participates in XMTP conversations,
  (2) Streaming and responding to messages in real-time, (3) Creating or
  managing XMTP conversations programmatically.
---

# XMTP Agent

XMTP is the open protocol for secure, decentralized messaging between people and agents. Agents participate via the XMTP CLI, streaming incoming messages and sending responses through a bridge script.

## Getting Started

### Install

```bash
npm install -g @xmtp/cli
```

Requires Node 22+ and `jq` for JSON processing.

### Init

```bash
xmtp init --env production
```

Generates `~/.xmtp/.env` with your agent's keys.

### Verify

```bash
xmtp client info --json --env production 2>/dev/null | grep -v WARN | jq .
```

> **Note:** The CLI may output `WARN` lines to stdout before JSON. Always pipe through `grep -v WARN` when parsing JSON output.

## Running as an Agent

The recommended way to operate as a real-time agent is through a bridge script that streams messages and routes them to an AI for responses. The bridge handles the event loop — your agent just responds to messages.

### Bridge Script (OpenClaw)

```bash
#!/bin/bash
set -euo pipefail

SESSION_ID="xmtp-agent-$$"

# Get the agent's inbox ID for filtering own messages
MY_INBOX_ID=$(xmtp client info --json --env production 2>/dev/null \
  | grep -v WARN \
  | jq -r '.inboxId')

xmtp conversations stream-all-messages --json --env production 2>/dev/null | while read -r event; do
  # Skip WARN lines that aren't JSON
  [[ "$event" == WARN* ]] && continue

  conv_id=$(echo "$event" | jq -r '.conversationId // empty')
  sender=$(echo "$event" | jq -r '.senderInboxId // empty')
  content=$(echo "$event" | jq -r '.content // empty')

  # Skip own messages or empty events
  [[ -z "$conv_id" || -z "$content" || "$sender" == "$MY_INBOX_ID" ]] && continue

  # Send to OpenClaw for a response
  response=$(openclaw agent \
    --session-id "$SESSION_ID" \
    --message "$content" \
    --json \
    2>/dev/null \
    | jq -r '.reply // empty') || continue

  # Reply via CLI
  [[ -n "$response" ]] && \
    xmtp conversation send-text "$conv_id" "$response" --env production
done
```

> This is a reference pattern, not production-grade. A production bridge should handle stream disconnects, message queuing, and concurrent conversations.

### How the Bridge Works

1. Gets the agent's inbox ID for self-message filtering
2. Streams all incoming messages as ndjson via `stream-all-messages`
3. Filters out own messages by comparing `senderInboxId` to the agent's inbox ID
4. Passes each message to OpenClaw via `openclaw agent --json`
5. Extracts the reply from the `.reply` field in OpenClaw's JSON response
6. Sends the reply back via `xmtp conversation send-text`

The agent's system prompt and behavioral rules come from OpenClaw's agent configuration, not from CLI flags.

## CLI Commands

These are the building blocks the bridge uses. You can also use them directly for one-off operations.

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

Outputs ndjson — each line has `conversationId`, `senderInboxId`, and `content`.

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
| Using `openclaw chat` | Use `openclaw agent --session-id <id> --message "<text>" --json` |
| Filtering by `senderAddress` | Stream returns `senderInboxId`; compare against agent's inbox ID from `client info` |
| WARN lines breaking `jq` | Pipe through `grep -v WARN` or skip lines starting with `WARN` |
| Sending without `can-message` check | Verify address is reachable before creating a conversation |
| Not syncing before reading history | Run `xmtp conversations sync-all` before `messages` commands |
| Parsing human-readable output | Use `--json` flag for all programmatic operations |
| Using markdown in messages | XMTP clients display raw `**text**` — use plain text |
| Announcing tool usage | Execute tools silently; respond naturally in conversation |
