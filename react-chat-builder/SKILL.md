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

**Before ANY code generation, you MUST query current XMTP documentation.**

This is non-negotiable. XMTP SDK APIs change frequently. Never rely on training data for SDK method names.

### Step 1: Query XMTP Docs

Use XMTP docs MCP if available:
```
search_xmtp_docs("browser SDK client create conversations messages streaming")
get_xmtp_doc_chunk(chunk_id)
```

Fallback to llms.txt:
```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract current browser SDK patterns for client creation and streaming"
})
```

### Step 2: Look Up Each Purpose

For each "Look Up" item in the reference files you're implementing, find the current way to do it. The reference files describe **what** needs to happen (purposes), not **how** (method names).

Example: If reference says "Look Up: How to create a DM conversation", query docs to find the current method signature.

### Step 3: Never Use Training Data for SDK Methods

Do NOT assume method names from training data. Always verify:
- Client creation patterns
- Streaming method signatures
- Conversation creation methods
- Message sending patterns

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
| 2 | Styling | How should the chat components be styled? | Match my app's design / Unstyled Base UI / Default chat styles |
| 3 | Components | Pre-built UI components or hooks only? | Pre-built components / Hooks only |
| 4 | Wallet | Which wallet provider? (skip if detected) | RainbowKit / ConnectKit / Web3Modal / I'll add my own |
| 5 | Conversations | What types of conversations? | DMs + Groups / DMs only |
| 6 | Features | Which message features? (multiSelect) | All features / Attachments / Reactions / Replies |
| 7 | Requests | Separate inbox for unknown senders? | Yes, separate inbox / No, show all together |
| 8 | Identity | How should user identities be displayed? | ENS names / Addresses only / Custom resolver |

**Note on Q6:** Text messages are always included. "All features" selects attachments + reactions + replies.

### Question Batching (IMPORTANT)

AskUserQuestion supports **max 4 questions per call**. You MUST ask questions in multiple rounds:

**Round 1:** Q1 (Chat Type), Q2 (Styling), Q3 (Components), Q4 (Wallet)
- After answers: Ask Q3b if Q3="Pre-built" AND component library detected
- After answers: Ask Q4b if Q4 = RainbowKit, ConnectKit, or Web3Modal

**Round 2:** Q5 (Conversations), Q6 (Features), Q7 (Requests), Q8 (Identity)
- After answers: Ask Q8b if Q8="Custom resolver"

Do NOT attempt to ask more than 4 questions at once—the tool will silently drop questions beyond the limit.

### Conditional Questions

**Q3b - Component library** (only if Q3="Pre-built" AND a component library detected):
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
| Q2 Styling | `match-app` | Reuse existing components, tokens, patterns |
| | `unstyled` | Base UI primitives + CSS custom properties |
| | `default` | Include standalone `chat-theme.css` |
| Q3 Components | `pre-built` | Generate UI components in `chat/` directory |
| | `hooks-only` | Only generate hooks and store, no UI |
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
- `ChatContainer.tsx` (if Q3 = Pre-built) - see [references/components/ChatContainer.md](references/components/ChatContainer.md)
- `ConversationList.tsx` (if Q3 = Pre-built) - see [references/components/ConversationList.md](references/components/ConversationList.md)
- `MessageThread.tsx` (if Q3 = Pre-built) - see [references/components/MessageThread.md](references/components/MessageThread.md)
- `NewChatDialog.tsx` (if Q3 = Pre-built) - see [references/components/NewChatDialog.md](references/components/NewChatDialog.md)
- `StatusToast.tsx` (if Q3 = Pre-built) - see [references/components/StatusToast.md](references/components/StatusToast.md)
- `IdentityBadge.tsx` (if Q3 = Pre-built AND Q8 = ENS or Custom) - see [references/components/IdentityBadge.md](references/components/IdentityBadge.md)
- `RequestsInbox.tsx` (if Q3 = Pre-built AND Q7 = Yes) - see [references/components/RequestsInbox.md](references/components/RequestsInbox.md)
- `GroupManagement.tsx` (if Q3 = Pre-built AND Q5 = DMs + Groups) - see [references/components/GroupManagement.md](references/components/GroupManagement.md)
- `FilePicker.tsx` (if Q3 = Pre-built AND Q6 includes Attachments) - see [references/components/FilePicker.md](references/components/FilePicker.md)
- `ReactionPicker.tsx` (if Q3 = Pre-built AND Q6 includes Reactions) - see [references/components/ReactionPicker.md](references/components/ReactionPicker.md)
- `ReplyComposer.tsx` (if Q3 = Pre-built AND Q6 includes Replies) - see [references/components/ReplyComposer.md](references/components/ReplyComposer.md)

**Conditional Layouts:**
- `FullAppLayout.tsx` (if Q3 = Pre-built AND Q1 = Full messaging app) - see [references/layouts/FullAppLayout.md](references/layouts/FullAppLayout.md)
- `WidgetLayout.tsx` (if Q3 = Pre-built AND Q1 = Chat widget) - see [references/layouts/WidgetLayout.md](references/layouts/WidgetLayout.md)

**Conditional Styling:**
- `chat-theme.css` (if Q2 = Default OR Q2 = Unstyled) - see [references/styling/ChatTheme.md](references/styling/ChatTheme.md)

**Conditional Wallet Setup:**
- Wallet provider setup (if not detected and selected) - see [references/wallet-providers.md](references/wallet-providers.md)

**Consumer UX Requirements (MANDATORY when Q3 = Pre-built):**
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

**Reference File Structure:**
Each reference file contains three sections:
1. **Interface** - TypeScript types to copy exactly (stable API contract)
2. **Rules** - MUST/NEVER invariants to follow
3. **Look Up** - What to query from XMTP docs before implementing

## XMTP Documentation (MANDATORY)

**CRITICAL: Never make assumptions about XMTP SDK patterns based on training data. The XMTP SDK evolves frequently. You MUST query current documentation before generating ANY code.**

### Documentation Sources (in order of preference)

**1. XMTP Docs MCP (Primary)**

Use the XMTP docs MCP tools to query current documentation:

```
# Search for relevant documentation
search_xmtp_docs("browser SDK client create initialize")

# Fetch full content of a specific chunk by ID
get_xmtp_doc_chunk(chunk_id)
```

**Required queries before code generation:**

| Feature | Query |
|---------|-------|
| Client creation | `search_xmtp_docs("browser SDK client create initialize signer")` |
| Streaming | `search_xmtp_docs("stream conversations messages real-time callbacks")` |
| Content types | `search_xmtp_docs("content types attachments reactions replies")` |
| Groups | `search_xmtp_docs("group chat create permissions members admin")` |
| Consent | `search_xmtp_docs("consent state allow block spam filter")` |
| Sync | `search_xmtp_docs("sync conversations messages history")` |

After searching, use `get_xmtp_doc_chunk(id)` to read the full content of relevant results.

**2. XMTP llms.txt (Fallback)**

If the XMTP docs MCP is unavailable, fetch the llms.txt directly:

```
WebFetch({
  url: "https://docs.xmtp.org/llms-full.txt",
  prompt: "Extract code examples for [specific feature]"
})
```

Available endpoints:
- `https://docs.xmtp.org/llms.txt` - Index and overview
- `https://docs.xmtp.org/llms-full.txt` - Complete documentation with code

### What to Look Up

Before writing any XMTP code, query docs for current patterns:

| Purpose | What to Find |
|---------|--------------|
| Client creation | Current method signature and required parameters |
| Streaming | How to subscribe to conversations and messages |
| Creating DMs | How to start a 1:1 conversation (address resolution steps) |
| Creating groups | How to create multi-party conversations |
| Consent | How to check/set consent state for spam filtering |
| Content types | How to register and use content type codecs |
| Sync | How to sync conversation/message history |

**Never assume method names from training data.** The SDK evolves frequently. Always look up the current way to do each operation.

## Bundler Configuration

XMTP uses WASM and Web Workers internally. Configure the bundler before running:

**Next.js 16+:** Add `--webpack` flags to scripts (Turbopack has limited WASM support)
**All Next.js:** Add CORS headers, webpack experiments, and worker paths
**Vite:** Exclude XMTP packages from pre-bundling

See [references/bundler-config.md](references/bundler-config.md) for:
- Full configuration examples
- Merging with existing configs
- Troubleshooting common errors

## Dynamic Imports (CRITICAL)

XMTP SDK uses WASM and **must** be dynamically imported to avoid SSR bundling issues.

**Rule:** Never use static imports for XMTP packages. Always use dynamic `await import()` inside async functions.

```typescript
// ❌ Static import - causes build failures
import { Client } from "@xmtp/...";

// ✅ Dynamic import - works with SSR
const initialize = async () => {
  const { Client } = await import("@xmtp/...");
};
```

This applies to the core SDK and all content type packages.

**Type definitions:** Define local types to avoid importing SDK types at build time. See `references/hooks/useXMTP.md` for the pattern.

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

**IMPORTANT: Always query XMTP docs for current package names before installing.**

```
search_xmtp_docs("browser SDK npm package install dependencies")
```

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

**Applies when:** Q3 = Pre-built AND Q2 = Match my app's design (or inferred from context)

### 1. Token Detection
- CSS custom properties (`--color-*`, `--spacing-*`, etc.)
- Tailwind theme config (colors, spacing, borderRadius, fonts)
- Sass/Less variables if present

### 2. Pattern Matching
- Find existing Button component → match its structure
- Find existing Input component → use same field patterns
- Find existing Card/Container patterns → apply to chat containers
- Find existing Avatar/List patterns → reuse for conversations
- Analyze spacing rhythm (4px, 8px grids, etc.)
- Match typography scale

### 3. Component Generation
Generate chat components that:
- Import and use existing components where they fit
- Apply existing utility classes/tokens to new elements
- Follow the app's naming conventions
- Match file structure patterns

### Example
If app has:
```tsx
// components/ui/Button.tsx
<button className="btn btn-primary px-4 py-2 rounded-lg">
```

Then generate:
```tsx
// components/chat/SendButton.tsx
<Button variant="primary">Send</Button>  // Reuse existing
```

NOT:
```tsx
<button className="bg-blue-500 text-white px-4 py-2 rounded">  // Don't reinvent
```

### For New/Greenfield Apps
When no design system is detected:
1. Use unstyled Base UI components as foundation
2. Generate minimal, semantic CSS (not Tailwind classes)
3. Provide CSS custom properties for easy theming
4. Include a `chat-theme.css` with sensible defaults

See [references/design-system-integration.md](references/design-system-integration.md) for full patterns.

## Consumer UX Requirements

**Applies when:** Q3 = Pre-built

All generated components MUST include:

### Loading States
- Skeleton loaders for messages, conversations
- Subtle spinners for actions (sending, loading more)
- No visible "initializing", "connecting", or "loading" text

### Error Handling
- Error boundaries at conversation and message level
- Retry actions for failed sends
- Graceful degradation, never blank screens

### Empty States
- Friendly messaging for empty inbox
- Clear CTAs to start conversations
- Contextual help text

### Transitions
- Smooth list animations
- Message send/receive animations
- View transitions (mobile list ↔ thread)

### Accessibility
- Proper focus management
- Keyboard navigation
- Screen reader announcements for new messages

### Developer-Focused Elements → Silent by Default

| Developer Pattern | Consumer Pattern |
|-------------------|------------------|
| `<StatusIndicator status="connecting" />` | Loading skeleton |
| Text: "Sending..." | Subtle opacity change + spinner icon |
| Text: "Failed to send" | Red icon + tap-to-retry gesture |
| Console.log errors | Error boundary with friendly message |
| "Reconnecting to network..." | Silent reconnection, toast only on failure after 5s |

**Debug mode (optional):** Use `NEXT_PUBLIC_XMTP_DEBUG=true` to enable console logging and connection status display.
