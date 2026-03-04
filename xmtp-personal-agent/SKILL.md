---
name: xmtp-personal-agent
description: >
  Connect your agent to XMTP so it can message people on the open network.
  Use when: (1) Giving your agent its own XMTP identity,
  (2) Listening and responding to conversations via the XMTP CLI,
  (3) Managing conversations and groups programmatically.
---

# XMTP Personal Agent

You are a personal agent connecting to XMTP — the open protocol for secure, decentralized messaging. This skill tells you how to get on the network and start responding to messages. For the full CLI command reference, read the XMTP CLI skill at `packages/xmtp-cli/skills/xmtp-cli/SKILL.md` in the [xmtp-js repo](https://github.com/xmtp/xmtp-js).

**The difference:** The CLI skill documents every command and flag. This skill tells you, as an agent, what to do — in order — to get connected and start operating.

> **Complete both steps before sending or receiving any messages.** Step 1 creates your identity. Step 2 starts the bridge that handles all messaging. You cannot send messages until the bridge is running.

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

This is how you operate. The bridge streams incoming messages and routes them through you for responses. Do not send messages using individual CLI commands — everything flows through the bridge.

Save this as a script and run it:

```bash
#!/bin/bash
set -euo pipefail

SESSION_ID="xmtp-agent-$$"

# Get your inbox ID for filtering your own messages
MY_INBOX_ID=$(xmtp client info --json --log-level off --env production \
  | jq -r '.properties.inboxId // empty')

[[ -z "$MY_INBOX_ID" ]] && echo "Failed to get inbox ID" >&2 && exit 1

# Stream all incoming messages and respond
xmtp conversations stream-all-messages --json --log-level off --env production \
  | while read -r event; do

  conv_id=$(echo "$event" | jq -r '.conversationId // empty')
  sender=$(echo "$event" | jq -r '.senderInboxId // empty')
  content=$(echo "$event" | jq -r '.content // empty')
  content_type=$(echo "$event" | jq -r '.contentType.typeId // empty')

  # Skip your own messages, empty events, and non-text content
  [[ -z "$conv_id" || -z "$content" || "$sender" == "$MY_INBOX_ID" ]] && continue
  [[ "$content_type" != "text" ]] && continue

  # Generate a response (OpenClaw example — replace with your AI backend)
  response=$(openclaw agent \
    --session-id "$SESSION_ID" \
    --message "$content" \
    2>/dev/null) || continue

  # Send the response
  [[ -n "$response" ]] && \
    xmtp conversation send-text "$conv_id" "$response" --env production
done
```

That's it. The bridge streams messages, you respond, replies go out.

### OpenClaw

This example uses `openclaw agent` for reply generation. The OpenClaw runtime gives the sub-session full tool access and retains conversation history via `--session-id`. The agent's system prompt and behavioral rules come from OpenClaw's agent configuration — no extra priming needed.

**Other backends:** Replace the `openclaw agent` call with your AI process of choice.

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

## Behavioral Notes

- **Respect consent** — don't message conversations you haven't been added to.
- **Use `--log-level off`** — suppresses log output that interferes with JSON parsing.
- **Be concise** — agents that over-message get muted; react instead of replying when nothing substantive to add.
- **Plain text** — no markdown; XMTP clients render raw formatting characters.

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Sending messages without the bridge | Start the bridge first; all messaging flows through it |
| Reading `.inboxId` from client info | Inbox ID is at `.properties.inboxId` |
| Using `openclaw chat` | Use `openclaw agent --session-id <id> --message "<text>"` |
| Filtering by `senderAddress` | Stream returns `senderInboxId`; compare against your inbox ID |
| Not using `--log-level off` | Log output mixes with JSON on stdout; suppress it |
| Announcing tool usage | Execute tools silently; respond naturally in conversation |
