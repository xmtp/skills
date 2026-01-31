# XMTP Skills

Skills for building with [XMTP](https://xmtp.org), the open protocol for secure, decentralized messaging between people and agents.

Skills are folders of instructions and resources that AI coding agents load dynamically to improve performance on specialized tasks. They follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

| Skill | Description |
|-------|-------------|
| [xmtp-docs](./xmtp-docs) | Query XMTP documentation for current SDK patterns |
| [xmtp-agents](./xmtp-agents) | Build XMTP messaging agents with @xmtp/agent-sdk |

---

### xmtp-docs

Query current XMTP documentation to get accurate SDK patterns before writing code. The XMTP SDK evolves frequently—this skill ensures you're using current method names and signatures.

**Use when:**
- Looking up XMTP SDK methods or patterns
- Verifying current API signatures before coding
- Finding examples for streaming, consent, groups, or content types

**How it works:** Uses WebFetch to query specific documentation pages via `docs.xmtp.org/llms.txt` index

---

### xmtp-agents

Skills for building XMTP messaging agents using the `@xmtp/agent-sdk`. Contains 8 skills with 30+ rules covering core patterns.

**Use when:**
- Creating new XMTP agents
- Handling messages, reactions, attachments
- Implementing inline actions (buttons/menus)
- Managing group conversations
- Processing token transactions

**Skills included:**

| Skill | Description |
|-------|-------------|
| [building-agents](./xmtp-agents/building-agents) | Core setup, events, middleware |
| [handling-commands](./xmtp-agents/handling-commands) | Validators, filters, type guards |
| [creating-inline-actions](./xmtp-agents/creating-inline-actions) | Interactive buttons (XIP-67) |
| [handling-attachments](./xmtp-agents/handling-attachments) | Encrypted file handling |
| [handling-transactions](./xmtp-agents/handling-transactions) | USDC transfers, wallet calls |
| [managing-groups](./xmtp-agents/managing-groups) | Group management, permissions |
| [sending-reactions](./xmtp-agents/sending-reactions) | Emoji reactions, thinking indicator |
| [resolving-domains](./xmtp-agents/resolving-domains) | ENS, Farcaster resolution |

## Installation

### Claude Code

```bash
/install xmtp/skills
```

### Manual

Copy the skill folder to your agent's plugins directory.

## Resources

- [XMTP Documentation](https://docs.xmtp.org/)
- [Agent Skills Specification](https://agentskills.io/)
- [Join the XMTP Developer Community](https://forms.gle/hesZ55WGMjJnZ7sQA)

## License

MIT
