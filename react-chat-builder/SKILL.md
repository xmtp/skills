---
name: react-chat-builder
description: >
  Build a complete, consumer-grade encrypted chat experience using XMTP. Integrates
  seamlessly with your existing app's design system—whether that's Tailwind, CSS modules,
  styled-components, or unstyled Base UI. Generates hooks (useXMTP, useConversations,
  useMessages), Zustand store, and optional UI components with loading skeletons,
  empty states, error boundaries, and polished micro-interactions.
  Use when: (1) User wants to add XMTP to React/Next.js/Vite, (2) User asks
  about encrypted messaging or web3 chat, (3) User mentions XMTP SDK integration,
  (4) User needs DM or group chat with wallets.
---

# XMTP React Chat Integration

Build consumer-grade encrypted messaging for any React application through an interactive workflow.

## Workflow Overview

This skill follows a 4-phase execution focused on producing **consumer-grade** output:

0. **Documentation Lookup** - Query current XMTP docs (MANDATORY before any code)
1. **Detection** - Analyze project setup (framework, wallet, styling, **existing design system**)
2. **Interview** - Ask questions via AskUserQuestion including **integration context** and **styling preferences**
3. **Generation** - Create hooks, store, and components with **loading skeletons, empty states, transitions**

**Core Principle:** Generated output should be immediately usable in production without cleanup. No developer-oriented status indicators, no visible connection badges, no console.log statements in production code.

## Phase 0: Documentation Lookup (REQUIRED)

> **CRITICAL:** Never use training data for XMTP SDK methods. The SDK evolves
> frequently. All method names, signatures, and patterns MUST be looked up from
> current documentation before generating any code.

### How to Look Up

Use the `/xmtp-docs` skill to query current documentation. The skill uses a 2-step process:

1. **Find the page:** Query the docs index for the right URL
2. **Fetch the page:** Get complete code examples from that page

### Required Lookups Before Code Generation

| Feature | What to find |
|---------|--------------|
| Client creation | How to create an XMTP client with a signer |
| Streaming | How to stream conversations and messages in real-time |
| Content types | How to use attachments, reactions, and replies |
| Groups | How to create and manage group chats |
| Consent | How to handle consent state and spam filtering |
| Sync | How to sync conversation and message history |

### Look Up Each Purpose

For each "Look Up" item in reference files, find the current way to do it. Reference files describe **what** needs to happen (purposes), not **how** (method names).

**Do not proceed to Phase 1 until you have looked up all SDK patterns you'll need.**

## Phase 1: Detection

Before asking questions, detect the project configuration **and existing design patterns**:

**Framework Detection:**
- Check for `next.config.js/ts` → Next.js (check for `app/` vs `pages/` router)
- Check for `vite.config.js/ts` → Vite
- Check `package.json` for framework dependencies

**Wallet Provider Detection:**
- Search for `wagmi`, `@rainbow-me/rainbowkit`, `@web3modal`, `connectkit` imports
- Check `providers/` directory for existing wallet context

**Styling Detection:**
- Check for `tailwind.config.js` → Tailwind (extract theme colors, spacing, borderRadius)
- Check for `*.module.css` files → CSS Modules
- Check for `styled-components` or `@emotion` imports
- Look for CSS custom properties in global styles (`--color-*`, `--spacing-*`)

**Design System Detection:**
- Find existing `Button`, `Input`, `Avatar`, `Card` components
- Analyze their patterns: class names, props structure, styling approach
- Check for design token files (`tokens.css`, `theme.ts`, `variables.scss`)
- Note spacing rhythm (4px, 8px grids), typography scale, color palette

**Directory Structure:**
- Identify `src/` vs root-level components
- Find existing `hooks/`, `components/`, `providers/`, `lib/` directories
- Note component naming conventions (PascalCase, kebab-case directories)

See [references/detection.md](references/detection.md) for full detection logic.
See [references/design-system-integration.md](references/design-system-integration.md) for design system matching.

## Phase 2: Interview

Use AskUserQuestion to gather requirements. Do NOT use "(Recommended)" labels - let users make informed choices.

### Question Flow

| # | Header | Question | Options |
|---|--------|----------|---------|
| 1 | Chat Type | What type of chat experience are you building? | Full messaging app / Embedded feature / Chat widget |
| 2 | Components | Pre-built UI components or hooks only? | Pre-built components / Hooks only |
| 3 | Styling | How should the chat components be styled? | *(only if Q2 = Pre-built; see conditional options below)* |
| 4 | Wallet | Which wallet provider? (skip if detected) | RainbowKit / ConnectKit / Web3Modal / I'll add my own |
| 5 | Conversations | What types of conversations? | DMs + Groups / DMs only |
| 6 | Features | Which message features? (multiSelect) | All features / Attachments / Reactions / Replies |
| 7 | Requests | Separate inbox for unknown senders? | Yes, separate inbox / No, show all together |
| 8 | Identity | How should user identities be displayed? | ENS names / Addresses only / Custom resolver |

**Note on Q6:** Text messages are always included. "All features" selects attachments + reactions + replies.

**Q3 Options (only if Q2 = Pre-built, conditional on detection):**

| Detection Result | Options |
|------------------|---------|
| Design system detected | Match my app's design / Unstyled Base UI / Something else |
| Empty/greenfield project | Default / Styled / Something else |

- **Match my app's design**: Reuse detected tokens, components, and patterns
- **Default** / **Unstyled Base UI**: Base UI primitives + chat-theme.css with token structure. User fills in values. (Same behavior, different label based on context.)
- **Styled**: Claude asks open-ended follow-up (e.g., "Describe the look you're going for") and generates a cohesive theme based on user's direction
- **Something else**: User describes their preferred approach (e.g., "Use Tailwind with my custom config")

### Question Batching (IMPORTANT)

AskUserQuestion supports **max 4 questions per call**. You MUST ask questions in multiple rounds:

**Round 1:** Q1 (Chat Type), Q2 (Components), Q4 (Wallet)
- If Q2 = "Pre-built": include Q3 (Styling) in Round 1 (4 questions total)
- After answers: Ask Q2b if Q2="Pre-built" AND component library detected
- After answers: Ask Q4b if Q4 = RainbowKit, ConnectKit, or Web3Modal

**Round 2:** Q5 (Conversations), Q6 (Features), Q7 (Requests), Q8 (Identity)
- After answers: Ask Q8b if Q8="Custom resolver"

Do NOT attempt to ask more than 4 questions at once—the tool will silently drop questions beyond the limit.

### Conditional Questions

**Q2b - Component library** (only if Q2="Pre-built" AND a component library detected):
| Question | Options |
|----------|---------|
| I detected {library}. Use it or generate Base UI? | Use {library} / Use Base UI |

**Q4b - WalletConnect project ID** (if Q4 answered OR detected as RainbowKit, ConnectKit, or Web3Modal):
| Question | Options |
|----------|---------|
| Do you have a WalletConnect project ID? | Yes, I have one / Skip for now / I need to get one |

- If "Yes" → user provides ID via "Other" option → write to `.env.local`
- If "Skip" → write placeholder to `.env.local`
- If "I need to get one" → write placeholder + show link to cloud.walletconnect.com

**Q8b - Custom identity** (only if Q8="Custom resolver"):
| Question | Options |
|----------|---------|
| What identity system? | Lens Protocol / Farcaster / (Other for custom) |

### Answer Effects

| Question | Answer | Generation Effect |
|----------|--------|-------------------|
| Q1 Chat Type | `full-app` | Generate routing, navigation, responsive layouts |
| | `embedded-feature` | Self-contained components, no routing |
| | `widget` | Minimal overlay UI, toggle mechanism |
| Q2 Components | `pre-built` | Generate UI components in `chat/` directory, ask Q3 (Styling) |
| | `hooks-only` | Only generate hooks and store, no UI, skip Q3 |
| Q3 Styling | `match-app` | Reuse existing components, tokens, patterns |
| | `default` / `unstyled` | Base UI primitives + chat-theme.css token structure |
| | `styled` | Ask open-ended follow-up, generate cohesive theme based on direction |
| | `something-else` | Follow user's described approach |
| Q4 Wallet | `rainbowkit/connectkit/web3modal` | Generate wallet provider setup + ask for project ID |
| | `own` | Skip wallet setup, user handles it |
| Q5 Conversations | `dms-groups` | Generate group management features (useConversation hook) |
| | `dms-only` | Skip group features, simpler implementation |
| Q6 Features | `attachments` | Install attachment content type, add file picker |
| | `reactions` | Install reaction content type, add reaction UI |
| | `replies` | Install reply content type, add reply threading |
| Q7 Requests | `yes` | Generate tabbed inbox (Conversations / Requests) |
| | `no` | Single conversation list, no consent filtering UI |
| Q8 Identity | `ens` | Add ENS resolution with viem |
| | `addresses` | Display truncated addresses only |
| | `custom` | Generate identity resolver interface for user to implement |

## Phase 3: Generation

Generate files based on interview answers. Match project's existing directory structure **and design system**.

### Intent-Based Generation

Reference files use a 3-section structure:

1. **Interface** - Copy exactly. This is the stable API contract the user's app consumes.
2. **Rules** - Apply as invariants. These hold regardless of SDK version.
3. **Look Up** - Find current patterns from Phase 0 docs lookup. Never hardcode method names.

The interface is stable (we define it). The implementation adapts to current SDK patterns.

### Files to Generate

**Always Generate:**
- `XMTPProvider.tsx` - Context provider with client initialization
- `useXMTP.ts` - Core hook for client state - see [references/hooks/useXMTP.md](references/hooks/useXMTP.md)
- `useConversations.ts` - List and stream conversations - see [references/hooks/useConversations.md](references/hooks/useConversations.md)
- `useMessages.ts` - Messages with send functionality - see [references/hooks/useMessages.md](references/hooks/useMessages.md)
- `inbox.ts` - Zustand store for state management - see [references/store.md](references/store.md)
- `xmtp-streaming.ts` - Stream management with reconnection
- `xmtp.ts` - TypeScript types
- `.env.example` - Environment configuration

**Always Update:**
- `next.config.ts` or `vite.config.ts` - Bundler configuration for WASM/workers (merge with existing)
- `package.json` - Add `--webpack` flags for Next.js 16+ (if applicable)

**Conditional Hooks:**
- `useConversation.ts` (if Q5 = DMs + Groups) - see [references/hooks/useConversation.md](references/hooks/useConversation.md)
- `useIdentity.ts` (if Q8 = ENS or Custom) - see [references/hooks/useIdentity.md](references/hooks/useIdentity.md)
- `useConsent.ts` (if Q7 = Yes) - see [references/hooks/useConsent.md](references/hooks/useConsent.md)

**Conditional Components:**
- `ChatContainer.tsx` (if Q2 = Pre-built) - see [references/components/ChatContainer.md](references/components/ChatContainer.md)
- `ConversationList.tsx` (if Q2 = Pre-built) - see [references/components/ConversationList.md](references/components/ConversationList.md)
- `MessageThread.tsx` (if Q2 = Pre-built) - see [references/components/MessageThread.md](references/components/MessageThread.md)
- `NewChatDialog.tsx` (if Q2 = Pre-built) - see [references/components/NewChatDialog.md](references/components/NewChatDialog.md)
- `StatusToast.tsx` (if Q2 = Pre-built) - see [references/components/StatusToast.md](references/components/StatusToast.md)
- `IdentityBadge.tsx` (if Q2 = Pre-built AND Q8 = ENS or Custom) - see [references/components/IdentityBadge.md](references/components/IdentityBadge.md)
- `RequestsInbox.tsx` (if Q2 = Pre-built AND Q7 = Yes) - see [references/components/RequestsInbox.md](references/components/RequestsInbox.md)
- `GroupManagement.tsx` (if Q2 = Pre-built AND Q5 = DMs + Groups) - see [references/components/GroupManagement.md](references/components/GroupManagement.md)
- `FilePicker.tsx` (if Q2 = Pre-built AND Q6 includes Attachments) - see [references/components/FilePicker.md](references/components/FilePicker.md)
- `ReactionPicker.tsx` (if Q2 = Pre-built AND Q6 includes Reactions) - see [references/components/ReactionPicker.md](references/components/ReactionPicker.md)
- `ReplyComposer.tsx` (if Q2 = Pre-built AND Q6 includes Replies) - see [references/components/ReplyComposer.md](references/components/ReplyComposer.md)

**Conditional Layouts:**
- `FullAppLayout.tsx` (if Q2 = Pre-built AND Q1 = Full messaging app) - see [references/layouts/FullAppLayout.md](references/layouts/FullAppLayout.md)
- `WidgetLayout.tsx` (if Q2 = Pre-built AND Q1 = Chat widget) - see [references/layouts/WidgetLayout.md](references/layouts/WidgetLayout.md)

**Conditional Styling:**
- `chat-theme.css` (if Q3 = Default/Unstyled OR Q3 = Styled) - see [references/styling/ChatTheme.md](references/styling/ChatTheme.md)
  - Default/Unstyled: token structure with minimal placeholder values
  - Styled: populated with Claude's recommended values based on user direction

**Conditional Wallet Setup:**
- Wallet provider setup (if not detected and selected) - see [references/wallet-providers.md](references/wallet-providers.md)

**Consumer UX Requirements (MANDATORY when Q2 = Pre-built):**
- Loading skeletons (never "Loading..." text) - see [references/components/LoadingSkeletons.md](references/components/LoadingSkeletons.md)
- Empty states with CTAs - see [references/components/EmptyStates.md](references/components/EmptyStates.md)
- Error boundaries with retry actions
- Transitions and animations for polish
- No visible status indicators (silent reconnection, toast only on failure)
- No console.log in production code (use `NEXT_PUBLIC_XMTP_DEBUG` flag)

**Design System Integration:**
- Import and reuse existing components (Button, Input, Avatar) where they fit
- Apply existing utility classes/tokens, never hardcode colors or spacing
- Match file structure and naming conventions
- See [references/design-system-integration.md](references/design-system-integration.md)

## Bundler Configuration

XMTP uses WASM and Web Workers internally. Configure the bundler before running:

**Next.js 16+:** Add `--webpack` flags to scripts (Turbopack has limited WASM support)
**All Next.js:** Add CORS headers, webpack experiments, and worker paths
**Vite:** Exclude XMTP packages from pre-bundling

See [references/bundler-config.md](references/bundler-config.md) for:
- Full configuration examples
- Merging with existing configs
- Troubleshooting common errors

## SSR Compatibility (Next.js)

The XMTP browser SDK requires browser APIs and **cannot run in server environments**. In Next.js, even `"use client"` components are server-rendered for initial HTML—the directive only marks where interactivity begins, not where code runs.

**Rule:** Wrap XMTP components with `next/dynamic` and `{ ssr: false }` to exclude them from server rendering entirely.

```typescript
// app/page.tsx
import dynamic from "next/dynamic";

const Chat = dynamic(() => import("@/components/Chat"), { ssr: false });

export default function Page() {
  return <Chat />;
}
```

Inside the dynamically imported component, use normal static imports:

```typescript
// components/Chat.tsx
"use client";
import { Client } from "@xmtp/browser-sdk"; // ✅ Safe - component never runs on server
```

**Vite/CRA:** No special handling needed—these frameworks don't use SSR by default.

## Security Requirements

Follow security checklist in [references/security.md](references/security.md):
- Never log or expose private keys
- Sanitize all message content (XSS prevention)
- Validate attachment types and sizes
- Proper OPFS cleanup on logout

## Prerequisite Skills

- https://skills.sh/vercel-labs/agent-skills/vercel-react-best-practices
- https://skills.sh/vercel-labs/agent-skills/web-design-guidelines
- https://skills.sh/anthropics/skills/frontend-design

## Dependencies

**IMPORTANT: Always use `/xmtp-docs` to look up current package names before installing.**

### What to Look Up

| Purpose | What to Find |
|---------|--------------|
| Core SDK | Current browser SDK package name |
| Text messages | Text content type package |
| Attachments | Attachment/remote-attachment content type package |
| Reactions | Reaction content type package |
| Replies | Reply content type package |

### Non-XMTP Dependencies

These are stable and don't require lookup:
- `zustand` - State management
- `viem` - Ethereum utilities (ENS resolution, address validation)
- `@base-ui-components/react` - Unstyled components (if selected)
- Wallet provider packages (RainbowKit, ConnectKit, etc. if selected)

## Verification

After generation, verify installation works:
- Bundler config includes WASM experiments and CORS headers
- `npm run dev` starts without WASM/worker errors
- TypeScript compiles without errors
- XMTP client connects successfully
- Messages send and receive correctly

## Design System Integration

**Applies when:** Q2 = Pre-built AND Q3 = Match my app's design

See [references/design-system-integration.md](references/design-system-integration.md) for:
- Token detection (CSS custom properties, Tailwind config)
- Pattern matching (Button, Input, Card patterns)
- Component generation strategies
- Greenfield app defaults

## Consumer UX Requirements

**Applies when:** Q2 = Pre-built

See [references/consumer-ux-requirements.md](references/consumer-ux-requirements.md) for:
- Loading states (skeletons, spinners)
- Error handling (boundaries, retry actions)
- Empty states (friendly messaging, CTAs)
- Transitions (list animations, view transitions)
- Accessibility (focus management, keyboard navigation)
