# XMTP Skills

Skills for building with [XMTP](https://xmtp.org), the open protocol for secure, decentralized messaging between people and agents.

Skills are folders of instructions, scripts, and resources that AI coding agents load dynamically to improve performance on specialized tasks. They follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

| Skill | Description |
|-------|-------------|
| [react-chat-builder](./react-chat-builder) | Build consumer-grade encrypted messaging for React applications |

---

### react-chat-builder

Build a complete, consumer-grade encrypted chat experience for React/Next.js/Vite applications. Generates hooks, Zustand store, and optional UI components that integrate with your existing design system.

**Use when:**
- Adding encrypted messaging to a React application
- Building secure chat or wallet-to-wallet messaging
- Integrating XMTP SDK for DMs or group chat

**What it generates:**
- Hooks: `useXMTP`, `useConversations`, `useMessages`, `useConversation`, `useConsent`, `useIdentity`
- Zustand store for state management
- Optional pre-built UI components with loading skeletons, empty states, and transitions
- Bundler configuration for WASM/workers
- Wallet provider setup (RainbowKit, ConnectKit, Web3Modal)

**Workflow:**
1. Query current XMTP docs (mandatory)
2. Detect project setup (framework, wallet, styling, design system)
3. Interview for requirements
4. Generate code matched to your project

## Installation

### Claude Code

```bash
/plugin marketplace add xmtp/skills
```

Then install a skill:

```bash
/plugin install react-chat-builder@xmtp-skills
```

### Manual

Copy the skill folder to your Claude Code plugins directory.

## Usage

Once installed, skills activate automatically when relevant. Just describe what you want:

```
Add encrypted messaging to my React app
```
```
Build a chat feature with XMTP
```
```
I need wallet-to-wallet messaging in my Next.js project
```

## Skill Structure

```
skill-name/
├── SKILL.md          # Instructions and metadata (YAML frontmatter + markdown)
└── references/       # Supporting documentation
```

## Resources

- [XMTP Documentation](https://docs.xmtp.org/)
- [Agent Skills Specification](https://agentskills.io/)
- [XMTP Discord](https://discord.gg/xmtp)

## License

MIT
