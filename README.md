# XMTP Skills

Skills for building with [XMTP](https://xmtp.org), the open protocol for secure, decentralized messaging between people and agents.

Skills are folders of instructions and resources that AI coding agents load dynamically to improve performance on specialized tasks. They follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

| Skill | Description |
|-------|-------------|
| [xmtp-docs](./xmtp-docs) | Query XMTP documentation for current SDK patterns and methods |
| [xmtp-agent](./xmtp-agent) | Connect your agent to XMTP so it can message agents and people on the open network |
| [skill-crypt](./skill-crypt) | Encrypted skill storage and agent-to-agent skill transfer over XMTP |

---

### xmtp-docs

Query current XMTP documentation to get accurate SDK patterns before writing code. The XMTP SDK evolves frequently—this skill ensures you're using current method names and signatures.

**Use when:**
- Looking up XMTP SDK methods or patterns
- Verifying current API signatures before coding
- Finding examples for streaming, consent, groups, or content types

**How it works:** Uses WebFetch to query specific documentation pages via `docs.xmtp.org/llms.txt` index

### xmtp-agent

Connect your agent to XMTP so it can message people on the open network. Your agent gets its own identity and can join groups, respond to conversations, and manage messages using the XMTP CLI.

**Use when:**
- Giving your agent its own XMTP identity
- Listening and responding to conversations via the XMTP CLI
- Managing conversations and groups programmatically

**How it works:** Provides CLI setup, a bridge script for listening and responding (with OpenClaw), and a command reference for managing conversations

### skill-crypt

Encrypted skill storage backed by XMTP. Skills are encrypted at rest with AES-256-GCM using a wallet-derived key and transferred between agents over XMTP's MLS end-to-end encryption.

**Use when:**
- Encrypting plaintext skills so they are not readable from the filesystem
- Sharing skills between agents over XMTP
- Rotating vault encryption keys
- Treating agent skills as transferable encrypted assets

**How it works:** Wallet key derives an AES-256-GCM encryption key via HKDF. Skills are stored as `.enc` files in a local vault. Transfers use a five-message protocol over XMTP DMs (catalog request, catalog, skill request, skill transfer, ack).

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
