# XMTP Skills

Skills for building with [XMTP](https://xmtp.org), the open protocol for secure, decentralized messaging between people and agents.

Skills are folders of instructions and resources that AI coding agents load dynamically to improve performance on specialized tasks. They follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

| Skill | Description |
|-------|-------------|
| [xmtp-docs](./xmtp-docs) | Query XMTP documentation for current SDK patterns and methods |
| [xmtp-agent](./xmtp-agent) | Operate as a real-time messaging agent using the XMTP CLI |

---

### xmtp-docs

Query current XMTP documentation to get accurate SDK patterns before writing code. The XMTP SDK evolves frequently—this skill ensures you're using current method names and signatures.

**Use when:**
- Looking up XMTP SDK methods or patterns
- Verifying current API signatures before coding
- Finding examples for streaming, consent, groups, or content types

**How it works:** Uses WebFetch to query specific documentation pages via `docs.xmtp.org/llms.txt` index

### xmtp-agent

Operate as a real-time messaging agent on the XMTP network. Teaches agents to stream messages, respond in conversations, and manage groups using the XMTP CLI.

**Use when:**
- Building an agent that participates in XMTP conversations
- Streaming and responding to messages in real-time
- Creating or managing conversations programmatically

**How it works:** Provides CLI commands for streaming, sending, and managing conversations, plus a minimal OpenClaw bridge example

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
