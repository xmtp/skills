---
name: xmtp-personal-agent
description: >
  Connect your agent to XMTP so it can message people on the open network.
  Use when: (1) Giving your agent its own XMTP identity,
  (2) Listening and responding to conversations via the XMTP CLI,
  (3) Managing conversations and groups programmatically.
---

# XMTP Personal Agent

Connect your agent to XMTP — the open protocol for secure, decentralized messaging. Your agent gets its own identity on the network and can message people, join groups, and respond to conversations using the XMTP CLI.

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

Generates `~/.xmtp/.env` with your wallet key, DB encryption key, and environment.

### Verify

```bash
xmtp client info --json --log-level off --env production
```

Returns:

```json
{
  "properties": {
    "address": "0x...",
    "inboxId": "...",
    "installationId": "...",
    "isRegistered": true
  }
}
```

## Running as an Agent

> **Do not send messages using individual CLI commands.** Set up the bridge script first. The bridge handles streaming, responding, and self-message filtering in one process. Start the bridge, then all messaging flows through it.

### Bridge Script

This bridge uses `openclaw agent` for reply generation. The OpenClaw runtime gives the sub-session full tool access and retains conversation history via `--session-id`. No extra priming needed — the agent's system prompt and behavioral rules come from OpenClaw's agent configuration.

**Other backends:** Replace the `openclaw agent` call with your AI process of choice.

```bash
#!/bin/bash
set -euo pipefail

SESSION_ID="xmtp-agent-$$"

# Get the agent's inbox ID for filtering own messages
# Inbox ID is at .properties.inboxId in the JSON output
MY_INBOX_ID=$(xmtp client info --json --log-level off --env production \
  | jq -r '.properties.inboxId')

[[ -z "$MY_INBOX_ID" ]] && echo "Failed to get inbox ID" >&2 && exit 1

# Stream messages as ndjson — one JSON object per line
xmtp conversations stream-all-messages --json --log-level off --env production \
  | while read -r event; do

  conv_id=$(echo "$event" | jq -r '.conversationId // empty')
  sender=$(echo "$event" | jq -r '.senderInboxId // empty')
  content=$(echo "$event" | jq -r '.content // empty')
  content_type=$(echo "$event" | jq -r '.contentType.typeId // empty')

  # Skip own messages, empty events, and non-text content types
  [[ -z "$conv_id" || -z "$content" || "$sender" == "$MY_INBOX_ID" ]] && continue
  [[ "$content_type" != "text" ]] && continue

  # Send to OpenClaw for a response
  response=$(openclaw agent \
    --session-id "$SESSION_ID" \
    --message "$content" \
    2>/dev/null) || continue

  # Reply via CLI
  [[ -n "$response" ]] && \
    xmtp conversation send-text "$conv_id" "$response" --env production
done
```

> This is a reference pattern, not production-grade. A production bridge should handle stream disconnects, message queuing, and concurrent conversations.

### Stream Output Format

Each line from `stream-all-messages --json` is a JSON object:

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

### How the Bridge Works

1. Gets the agent's inbox ID from `client info` at `.properties.inboxId`
2. Streams all incoming messages as ndjson via `stream-all-messages`
3. Filters out own messages by comparing `senderInboxId` to the agent's inbox ID
4. Skips non-text content types (reactions, group updates, etc.)
5. Passes each message to `openclaw agent`, which returns plaintext
6. Sends the reply back via `xmtp conversation send-text`

## CLI Reference

Individual commands used by the bridge. Use these directly only for setup tasks (checking reachability, creating conversations) — not for sending messages during a conversation.

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
xmtp conversations stream-all-messages --json --log-level off --env production
```

Outputs ndjson — each line has `conversationId`, `senderInboxId`, `contentType.typeId`, and `content`.

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
- **Use `--log-level off`** — suppresses log output that can interfere with JSON parsing.
- **Sync first** — `xmtp conversations sync-all --env production` before reading history.
- **Be concise** — agents that over-message get muted; react instead of replying when nothing substantive to add.
- **Plain text** — no markdown; XMTP clients render raw formatting characters.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Sending messages before starting bridge | Set up the bridge first; all messaging flows through it |
| Missing `--env production` | Always pass `--env production` for live network; default is dev |
| Reading `.inboxId` from client info | Inbox ID is at `.properties.inboxId` in the JSON output |
| Using `openclaw chat` | Use `openclaw agent --session-id <id> --message "<text>"`; returns plaintext |
| Filtering by `senderAddress` | Stream returns `senderInboxId`; compare against agent's inbox ID |
| Not using `--log-level off` | Log output can mix with JSON on stdout; suppress with `--log-level off` |
| Sending without `can-message` check | Verify address is reachable before creating a conversation |
| Not syncing before reading history | Run `xmtp conversations sync-all` before `messages` commands |
| Parsing human-readable output | Use `--json` flag for all programmatic operations |
| Using markdown in messages | XMTP clients display raw `**text**` — use plain text |
| Announcing tool usage | Execute tools silently; respond naturally in conversation |
