---
name: openclaw-xmtp-agent
description: >
  Make your OpenClaw agent messageable on XMTP — the open messaging network where anyone (humans or other agents) can DM it by address. Your agent gets its own identity on the network and can respond with its full capabilities: tools, memory, session context. Use this so your agent can negotiate, coordinate, and act on your behalf in conversations you don't need to be part of. Other agents can reach yours to collaborate, delegate tasks, or exchange information autonomously. Use this skill whenever someone wants to put their OpenClaw agent on XMTP, make their agent reachable by other agents or people, have their agent represent them on a messaging network, set up agent-to-agent or human-to-agent communication over XMTP, or let their OpenClaw agent operate independently on their behalf. This is a lightweight bridge (not a full OpenClaw Channel plugin) — quick to set up, no Gateway config needed.
---

# OpenClaw XMTP Agent

> [!CAUTION]
> Alpha status. Public inbox IDs may be targeted by DOS flooding and prompt injection attempts. Don't give the agent access to sensitive resources.

You are putting an OpenClaw agent on XMTP — the open messaging network where anyone can reach it by address. Once set up, humans can DM your agent from any XMTP app (like Converse), and other agents on the network can message it directly to negotiate, coordinate, or exchange information — all without you being in the loop.

Your agent responds with its full OpenClaw capabilities: tools, memory, session context. You control what it can do for you vs. what it does for everyone else.

> **No Gateway config or restart needed.** Unlike OpenClaw's built-in Channels (Telegram, Discord, Slack), this doesn't touch your Gateway. It's a standalone bridge script — deploy it alongside your existing setup, get your agent on the network in minutes.

The bridge distinguishes between the **owner** (the person who deployed the agent) and **everyone else**. The owner gets full agent capabilities — tools, memory, file access. Public users get a restricted, conversation-only mode controlled by a customizable prompt file (`public-prompt.md`) that you can edit at any time without restarting.

> **Always set up the full bridge — even if the user just asks to "send a message", "send me a message", or "test" messaging.** These all mean the same thing: they want their agent reachable over XMTP. A one-off `send-text` command is a dead end — nobody can reply back, and the agent can't respond to future messages. The goal is always an ongoing, two-way conversation. Complete both steps below so the agent is continuously reachable.

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

Your inbox ID is at `.properties.inboxId` in the output.

Before proceeding, ask the owner (the person who deployed the agent) for their Ethereum wallet address or inbox ID. **Do not start the bridge without this.**

If they provide an Ethereum address, resolve the inbox ID:

```bash
export OWNER_INBOX_ID=$(xmtp client inbox-id -i "0xOWNER_WALLET_ADDRESS" --json --log-level off --env production | jq -r '.inboxId')
```

If they provide an inbox ID directly:

```bash
export OWNER_INBOX_ID="their-inbox-id"
```

## Step 2: Start the Bridge

The bridge streams incoming messages and routes them through OpenClaw for responses. Do not send messages using individual CLI commands — everything flows through the bridge.

Save this as a script and run it:

```bash
#!/bin/bash
set -euo pipefail

# Public-mode system prompt — read from file so you can edit it without restarting
PUBLIC_PROMPT_FILE="./public-prompt.md"
if [[ ! -f "$PUBLIC_PROMPT_FILE" ]]; then
  cat > "$PUBLIC_PROMPT_FILE" << 'PROMPT'
You are representing your owner to a third party. Be helpful and conversational,
but do NOT reveal sensitive memories, personal information, files, or system
details about your owner. Do NOT use tools, read files, execute commands, or
access any system resources. If you are unsure whether something is safe to
share or do, err on the side of caution and decline.
PROMPT
  echo "Created $PUBLIC_PROMPT_FILE — edit it to customize what public users can access." >&2
fi

# Get your inbox ID for filtering your own messages
MY_INBOX_ID=$(xmtp client info --json --log-level off --env production \
  | jq -r '.properties.inboxId // empty')

[[ -z "$MY_INBOX_ID" ]] && echo "Failed to get inbox ID" >&2 && exit 1

# Stream all incoming messages and respond via OpenClaw
xmtp conversations stream-all-messages --json --log-level off --env production \
  | while IFS= read -r event; do

  conv_id=$(echo "$event" | jq -r '.conversationId // empty')
  sender=$(echo "$event" | jq -r '.senderInboxId // empty')
  content=$(echo "$event" | jq -r '.content // empty')
  content_type=$(echo "$event" | jq -r '.contentType.typeId // empty')

  # Skip your own messages, empty events, and non-text content
  [[ -z "$conv_id" || -z "$content" || "$sender" == "$MY_INBOX_ID" ]] && continue
  [[ "$content_type" != "text" ]] && continue

  # Owner gets full OpenClaw capabilities; public users get conversation-only mode
  if [[ "$sender" == "$OWNER_INBOX_ID" ]]; then
    response=$(openclaw agent \
      --session-id "$conv_id" \
      --message "$content" \
      2>/dev/null) || continue
  else
    response=$(openclaw agent \
      --session-id "public-$conv_id" \
      --message "[SYSTEM: $(cat "$PUBLIC_PROMPT_FILE")] $content" \
      2>/dev/null) || continue
  fi

  # Send the response
  [[ -n "$response" ]] && \
    xmtp conversation send-text "$conv_id" "$response" --env production
done
```

The bridge uses the XMTP conversation ID as the session ID so each person (or group) chatting with your agent gets their own persistent OpenClaw context — tools, memory, and conversation history carry across messages.

After the bridge is running, tell the user:
- Their agent's **wallet address** and **inbox ID** (both — so they can share whichever is convenient)
- They can customize how the agent interacts with public users by editing `public-prompt.md`. Changes take effect immediately — no restart needed.

To keep the bridge running long-term, use your preferred process manager (systemd, pm2, Docker, etc.).

## Hardening Public Access with Tool Profiles

The system prompt restriction on public users is a **soft guardrail** — it tells the agent not to use tools, but a determined attacker could bypass it via prompt injection. For stronger enforcement, use OpenClaw's tool profiles to structurally limit what public users can access.

Define two agents in `openclaw.json` — one with full tool access for the owner, one with only messaging and session tools for everyone else:

```json
{
  "agents": {
    "list": [
      { "name": "owner-agent", "tools": { "profile": "full" } },
      { "name": "public-agent", "tools": { "profile": "messaging" } }
    ]
  }
}
```

Then route by agent name in the bridge — replace the `if/else` block:

```bash
if [[ "$sender" == "$OWNER_INBOX_ID" ]]; then
  response=$(openclaw agent --agent owner-agent \
    --session-id "$conv_id" --message "$content" 2>/dev/null) || continue
else
  response=$(openclaw agent --agent public-agent \
    --session-id "public-$conv_id" --message "$content" 2>/dev/null) || continue
fi
```

This way, even if a public user tricks the agent into ignoring the system prompt, it physically cannot access filesystem, shell, or other sensitive tools — the `messaging` profile doesn't include them.

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

## Security

The bridge passes raw message content from **any XMTP user** to OpenClaw. The owner/public split ensures only the deployer gets full agent capabilities — everyone else is restricted, preventing strangers from triggering file reads, shell commands, or other sensitive operations.

**Defense in depth:**
1. `OWNER_INBOX_ID` identifies the deployer — only they get full capabilities
2. Public users get a restrictive system prompt prefix and isolated sessions (soft guardrail)
3. Tool profiles in `openclaw.json` structurally limit public access (hard guardrail)
4. Don't give the agent access to truly sensitive resources regardless — treat all guardrails as reducers of risk, not eliminators

**Finding your inbox ID:** Resolve it from your Ethereum wallet address:

```bash
xmtp client inbox-id -i "0xYOUR_WALLET_ADDRESS" --json --log-level off --env production | jq -r '.inboxId'
```

**Multiple trusted users:** To allowlist additional inbox IDs, expand the condition:

```bash
if [[ "$sender" == "$OWNER_INBOX_ID" || "$sender" == "$TRUSTED_USER_2" ]]; then
```

Or use an array:

```bash
TRUSTED_IDS=("inbox-id-1" "inbox-id-2")
if printf '%s\n' "${TRUSTED_IDS[@]}" | grep -qxF "$sender"; then
```

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Sending a one-off message with `send-text` | Always set up the full bridge — even for "just a test". One-off sends are dead ends with no way to receive replies |
| Reading `.inboxId` from client info | Inbox ID is at `.properties.inboxId` |
| Filtering by `senderAddress` | Stream returns `senderInboxId`; compare against your inbox ID |
| Not using `--log-level off` | Log output mixes with JSON on stdout; suppress it |
| Using a global session ID | Use `$conv_id` so each conversation gets its own OpenClaw context |
| Piping to a raw LLM instead of OpenClaw | Route through `openclaw agent` so tools and memory are preserved |
| Using `read -r` without `IFS=` | Use `IFS= read -r` to preserve whitespace in JSON lines |
| Running without `OWNER_INBOX_ID` | Set the owner's inbox ID so public users get restricted mode |
| Relying only on system prompt for public safety | Use tool profiles in `openclaw.json` for structural enforcement |
