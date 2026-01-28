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

This skill follows a 6-phase execution focused on producing **consumer-grade** output:

0. **Documentation Lookup** - Query current XMTP docs (MANDATORY before any code)
1. **Detection** - Analyze project setup (framework, wallet, styling, **existing design system**)
2. **Interview** - Ask questions via AskUserQuestion including **integration context** and **styling preferences**
3. **Spec Generation** - Generate detailed spec document; optionally open for review
4. **Code Generation** - Create hooks, store, and components with **loading skeletons, empty states, transitions**
5. **Verification** - Test the integration in a real browser using agent-browser CLI

**Core Principle:** Generated output should be immediately usable in production without cleanup. No developer-oriented status indicators, no visible connection badges, no console.log statements in production code.

## Phase 0: Documentation Lookup (REQUIRED)

> **CRITICAL:** Never use training data for XMTP SDK methods. The SDK evolves
> frequently. All method names, signatures, and patterns MUST be looked up from
> current documentation before generating any code.

### How to Look Up

Use the `/xmtp-docs` skill to query current documentation. The skill uses a 2-step process:

1. **Find the page:** Query the docs index for the right URL
2. **Fetch the page:** Get complete code examples from that page

### Required Lookups (Phase 0 - Before Detection)

Look up **core patterns** that apply regardless of feature selection:

| Feature | What to find |
|---------|--------------|
| Client creation | How to create an XMTP client with a signer |
| Signer interface | Current signer shape for EOA wallets |
| Streaming basics | How to stream conversations and messages |
| Sync | How to sync conversation and message history |
| Package names | Current browser SDK and text content type packages |

### Feature-Specific Lookups (After Phase 2 Interview)

After interview determines which features are needed, look up those specific patterns:

| If Selected | What to find |
|-------------|--------------|
| Q5 = Groups | How to create and manage group chats |
| Q6 = Attachments | Attachment content type package and usage |
| Q6 = Reactions | Reaction content type package and usage |
| Q6 = Replies | Reply content type package and usage |
| Q7 = Requests | How to handle consent state and spam filtering |

### Look Up Each Purpose

Reference files describe **what** needs to happen (purposes), not **how** (method names). For each "Look Up" item in reference files, query docs to find the current implementation.

**Do not proceed to Phase 1 until core lookups are complete.**
**Do not proceed to Phase 4 until feature-specific lookups are complete.**

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

**Existing XMTP Detection:**
- Check package.json for XMTP packages
- Search for XMTP imports in source files
- Look for existing XMTP provider or hooks

If existing XMTP found, ask user how to proceed: replace entirely, upgrade/update existing code, or abort and let user handle manually.

See [references/detection.md](references/detection.md) for full detection logic.
See [references/design-system-integration.md](references/design-system-integration.md) for design system matching.

### Detection Summary

After detection completes, summarize findings and ask user to confirm. Include:
- Framework and router type
- Wallet provider (if detected)
- Styling approach and any design tokens found
- Key directories (source, components, hooks, etc.)
- Existing XMTP installation (if any)

Ask user to confirm the detection is correct before proceeding. If user provides corrections, update the detection state accordingly.

**If no project detected** (empty directory or no package.json):

Offer to scaffold a new project (Next.js or Vite) or let user set up their own. If scaffolding, ensure TypeScript is enabled and use current best practices. Look up current scaffolding commands before running. After scaffolding completes, re-run detection on the new project.

## Phase 2: Interview

Use AskUserQuestion to gather requirements. Do NOT use "(Recommended)" labels - let users make informed choices.

### Question Flow

| # | Header | Question | Options |
|---|--------|----------|---------|
| 1 | Chat Type | What type of chat experience are you building? | Full messaging app / Embedded feature / Chat widget |
| 2 | Components | Pre-built UI components or hooks only? | Pre-built components / Hooks only |
| 3 | Styling | How should the chat components be styled? | *(only if Q2 = Pre-built; see conditional options below)* |
| 4 | Wallet | Which wallet provider? | RainbowKit / ConnectKit / Web3Modal / I'll add my own / *[Detected provider]* (if detected) |
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
- **Styled**: Ask follow-up Q3b for design direction, then generate cohesive theme

**Q3b - Style direction** (only if Q3 = "Styled"):
| Question | Options |
|----------|---------|
| Describe the look you're going for: | *(user enters via "Other")* |

Include a few examples in the question to help the user understand what kind of direction is useful (aesthetic words, specific styles, brand colors, etc.).
- **Something else**: User describes their preferred approach (e.g., "Use Tailwind with my custom config")

### Question Batching (IMPORTANT)

AskUserQuestion supports **max 4 questions per call**. You MUST ask questions in multiple rounds:

**Round 1:** Q1 (Chat Type), Q2 (Components), Q4 (Wallet) — 3 questions

**Round 1b** (conditional, after Round 1 answers):
- If Q2 = "Pre-built": Ask Q3 (Styling)
- If Q2 = "Pre-built" AND component library detected: Ask Q2b (Use detected library?)
- If Q4 = RainbowKit/ConnectKit/Web3Modal: Ask Q4b (WalletConnect project ID)

You can combine these into one call if ≤4 questions total.

**Round 2:** Q5 (Conversations), Q6 (Features), Q7 (Requests), Q8 (Identity) — 4 questions

**Round 2b** (conditional, after Round 2 answers):
- If Q8 = "Custom resolver": Ask Q8b (Which identity system?)

Do NOT attempt to ask more than 4 questions at once—the tool will silently drop questions beyond the limit.

### Conditional Questions

**Q2b - Component library** (only if Q2="Pre-built" AND a component library detected):
| Question | Options |
|----------|---------|
| I detected {library}. Use it or generate Base UI? | Use {library} / Use Base UI |

**Q4 - Wallet provider** (when detected):
If a wallet provider was detected in Phase 1, include it as the first option with "(detected)" label:
| Question | Options |
|----------|---------|
| Which wallet provider? | RainbowKit (detected) / ConnectKit / Web3Modal / I'll add my own |

This confirms the detection rather than silently skipping the question.

**Q4b - WalletConnect project ID** (if Q4 = RainbowKit, ConnectKit, or Web3Modal):
| Question | Options |
|----------|---------|
| Do you have a WalletConnect project ID? | Yes, I have one / Skip for now / I need to get one |

- If "Yes" → ask follow-up Q4c
- If "Skip" → write placeholder to env file, continue
- If "I need to get one" → show link to cloud.walletconnect.com, write placeholder, continue

**Q4c - Get project ID** (only if Q4b = "Yes"):
| Question | Options |
|----------|---------|
| Paste your WalletConnect project ID: | *(user enters via "Other")* |

Write the provided ID to env file.

**Q8b - Custom identity** (only if Q8="Custom resolver"):
| Question | Options |
|----------|---------|
| What identity system? | Lens Protocol / Farcaster / (Other for custom) |

### Answer Effects

| Question | Answer | Generation Effect |
|----------|--------|-------------------|
| Q1 Chat Type | `full-app` | Generate FullAppLayout with routing, navigation, responsive design |
| | `embedded-feature` | Generate ChatEmbed component - self-contained, drops into any page, no layout wrapper |
| | `widget` | Generate WidgetLayout - floating overlay with toggle button, minimized state |
| Q2 Components | `pre-built` | Generate UI components in chat subdirectory (see File Path Resolution), ask Q3 (Styling) |
| | `hooks-only` | Only generate hooks and store, no UI, skip Q3 |
| Q3 Styling | `match-app` | Reuse existing components, tokens, patterns |
| | `default` / `unstyled` | Base UI primitives + chat-theme.css token structure |
| | `styled` | Ask open-ended follow-up, generate cohesive theme based on direction |
| | `something-else` | Follow user's described approach |
| Q4 Wallet | `rainbowkit/connectkit/web3modal` | Generate wallet provider setup + ask for project ID |
| | `own` | Generate signer adapter interface, user implements (see below) |

**Q4 = "I'll add my own" handling:**

Generate a signer adapter interface that the user must implement:
- Interface defines what XMTPProvider needs: `getSigner()` returning the signer shape
- Document the required signer shape (look up current shape in Phase 0)
- User connects their wallet solution to this interface
- XMTPProvider calls the adapter, doesn't care about underlying wallet provider
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

## Phase 3: Spec Generation

After the interview, generate a detailed specification document before writing any code.

### Generate the Spec

Create `xmtp-chat-spec.md` in the project root with:

1. **Configuration Summary** - All interview answers in a table
2. **Detected Project Structure** - Framework, styling, directories, existing patterns
3. **Files to Generate** - Exact file paths for every hook, component, and config change
4. **Dependencies** - Exact npm packages to install (from Phase 0 lookup)
5. **Interface Contracts** - TypeScript interfaces for all hooks
6. **Component Props** - Props interfaces for all components (if pre-built)
7. **Config Changes** - Exact bundler config additions as diffs
8. **Verification Checklist** - What will be tested after generation

See [references/spec-template.md](references/spec-template.md) for the full template.

### Offer Review Option

After generating the spec, ask if the user wants to review it in their editor or proceed directly to code generation.

**If "Open in editor":**

Open the spec file in the user's preferred editor. Try common editors in reasonable order, fall back to system default. The goal is to get the file open for review - the specific editor matters less than success.

Tell user: "Review the spec. Say 'continue' when ready to generate code, or describe any changes needed."

**Handling spec changes:** If user describes changes instead of saying "continue":
1. Parse the requested changes
2. Update `xmtp-chat-spec.md` with the changes
3. Show a summary: "Updated: [list of changes]. Say 'continue' to proceed or describe more changes."
4. Repeat until user says "continue"

Wait for user input before proceeding to Phase 4.

**If "Continue":**
Proceed directly to Phase 4 (Code Generation).

## Phase 4: Code Generation

Generate files based on interview answers. Match project's existing directory structure **and design system**.

### File Path Resolution

Use detected directories from Phase 1. Group related XMTP files together in a way that matches project conventions.

**Goals:**
- Keep XMTP files organized and discoverable
- Match existing project structure and naming conventions
- Don't scatter files across unrelated directories

**Guidelines:**
- If project groups by feature (e.g., `features/chat/`), put XMTP files there
- If project groups by type (e.g., `hooks/`, `components/`), create XMTP subdirectories within each
- Match existing naming style (kebab-case vs PascalCase directories)
- Never place files at project root unless no structure exists
- If multiple valid locations exist, prefer the more specific one

### Intent-Based Generation

Reference files use a 3-section structure:

1. **Interface** - Copy exactly. This is the stable API contract the user's app consumes.
2. **Rules** - Apply as invariants. These hold regardless of SDK version.
3. **Look Up** - Find current patterns from Phase 0 docs lookup. Never hardcode method names.

The interface is stable (we define it). The implementation adapts to current SDK patterns.

### Files to Generate

**Always Generate:**
- `XMTPProvider.tsx` - Context provider with client initialization - see [references/XMTPProvider.md](references/XMTPProvider.md)
- `useXMTP.ts` - Core hook for client state - see [references/hooks/useXMTP.md](references/hooks/useXMTP.md)
- `useConversations.ts` - List and stream conversations - see [references/hooks/useConversations.md](references/hooks/useConversations.md)
- `useMessages.ts` - Messages with send functionality - see [references/hooks/useMessages.md](references/hooks/useMessages.md)
- `inbox.ts` - Zustand store for state management - see [references/store.md](references/store.md)
- `xmtp-streaming.ts` - Stream management with reconnection - see [references/xmtp-streaming.md](references/xmtp-streaming.md)
- `xmtp.ts` - TypeScript types - see [references/types.md](references/types.md)
- `.env.example` - Environment configuration with:
  - XMTP environment setting (dev for testing, production for mainnet)
  - Debug flag for verbose logging
  - WalletConnect project ID placeholder (if Q4 requires it)
  - Any other secrets the wallet provider needs

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
- `ChatEmbed.tsx` (if Q2 = Pre-built AND Q1 = Embedded feature) - self-contained component with no layout wrapper, user places it where needed

**Conditional Styling:**
- `chat-theme.css` (if Q3 = Default/Unstyled OR Q3 = Styled) - see [references/styling/ChatTheme.md](references/styling/ChatTheme.md)
  - Default/Unstyled: token structure with minimal placeholder values
  - Styled: populated with Claude's recommended values based on user direction

**Conditional Wallet Setup:**
- Wallet provider setup (if not detected and selected) - see [references/wallet-providers.md](references/wallet-providers.md)

**Consumer UX Requirements (MANDATORY when Q2 = Pre-built):**
- Loading skeletons (never "Loading..." text) - see [references/components/LoadingSkeletons.md](references/components/LoadingSkeletons.md)
- Empty states with CTAs - see [references/components/EmptyStates.md](references/components/EmptyStates.md)
- Error boundaries with retry actions - see [references/components/ErrorBoundary.md](references/components/ErrorBoundary.md)
- Transitions and animations for polish
- No visible status indicators (silent reconnection, toast only on failure)
- No console.log in production code (use `NEXT_PUBLIC_XMTP_DEBUG` flag)

**Design System Integration:**
- Import and reuse existing components (Button, Input, Avatar) where they fit
- Apply existing utility classes/tokens, never hardcode colors or spacing
- Match file structure and naming conventions
- See [references/design-system-integration.md](references/design-system-integration.md)

### Install Dependencies

After all files are generated, install dependencies.

**Required packages** (look up current names in Phase 0):

| Purpose | Package (from lookup) |
|---------|----------------------|
| Core SDK | [browser SDK package] |
| Text messages | [text content type package] |
| Attachments | [attachment content type package] (if Q6 includes) |
| Reactions | [reaction content type package] (if Q6 includes) |
| Replies | [reply content type package] (if Q6 includes) |

**Supporting packages** (stable, no lookup needed):
- `zustand` - State management
- `viem` - Ethereum utilities

**Conditional packages:**
- If Q3 = unstyled: unstyled component library (Base UI or similar)
- If Q4 = wallet provider: that provider's packages + wagmi

**Before running install:**

Build the full package list from lookups and interview answers. Show user what will be installed and get confirmation before proceeding. After successful installation, move to Phase 5.

### Integration Instructions

After generating files, show user how to integrate into their app:

**Provider Setup:**

XMTPProvider needs to be:
- Inside the wallet provider (to access the signer)
- Outside any components that use XMTP hooks
- Excluded from SSR in Next.js (use `dynamic()` with `ssr: false`)

**Show user:**
- Which file to modify
- The import to add
- Where in the component tree to add the provider
- Scope based on Q1 answer (full-app wraps everything, embedded/widget wraps just the chat area)

## Bundler Configuration

XMTP uses WASM and Web Workers internally. Configure the bundler before running.

**Requirements by framework:**
- Next.js 16+: Add `--webpack` flags to scripts (Turbopack has limited WASM support)
- All Next.js: CORS headers, webpack experiments, worker paths
- Vite: Exclude XMTP packages from pre-bundling

**Merge strategy:**
1. Read existing bundler config file
2. Identify which XMTP requirements are missing
3. Add only what's missing - preserve all existing settings
4. For conflicts (e.g., existing webpack config), merge objects deeply
5. Show user the diff before applying changes
6. If merge is complex, ask user for confirmation

**Never:**
- Overwrite user's existing configuration
- Remove settings unrelated to XMTP
- Add redundant configuration

See [references/bundler-config.md](references/bundler-config.md) for:
- What configuration XMTP requires
- How to detect existing configuration
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
import { Client } from "[xmtp-browser-sdk]"; // ✅ Safe - component never runs on server
// Use package name from Phase 0 lookup
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

## Phase 5: Verification

After code generation, verify the integration works using the agent-browser CLI.

### Prerequisites

Check if agent-browser CLI is available.

**If NOT installed:**

Ask if user wants to install it (mention it requires downloading Chromium). If user declines or installation fails, fall back to code-only verification.

### Ask User

**If Q2 = Pre-built (has UI components):**

Ask if user wants to watch the browser tests (headed mode), run them in background (headless), or skip verification entirely.

**If Q2 = Hooks-only (no UI):**

Skip browser verification. Run code-only checks:

1. **TypeScript compilation** - Verify `tsc --noEmit` passes
2. **Export validation** - Create a temporary file that imports all generated hooks and the store, verify TypeScript resolves them
3. **Report results** - Show which exports work and which have issues

Then skip to the end of Phase 5 (no browser tests needed).

### Verification Steps

**1. Pre-flight checks:**

Verify TypeScript compilation passes. Dependencies were installed in Phase 4.

**2. Detect dev server port:**

Check package.json scripts for custom port flags. If not specified, use framework defaults. The goal is to know where the dev server will be accessible.

**3. Start dev server** (user must do this):

Tell user to start their dev server and confirm when ready. After user confirms, verify the server is accessible by making a request to the expected URL. If the port seems wrong, ask user to confirm the correct URL.

**4. Browser verification:**

Using agent-browser CLI:
- Open the app URL (headed mode if user wants to watch)
- Take snapshots to identify interactive elements
- Capture screenshots for the verification report

**5. Verify XMTP components:**

Check that the expected UI elements are present:
- Conversation list or chat container
- Message input area
- Connect wallet button (if not already connected)
- Loading states render correctly (skeletons, not "Loading..." text)
- Empty states show appropriate messaging

**6. Verify wallet connection:**

Find and click the wallet connection button. Look for common patterns like "Connect Wallet" or wallet provider branding. If the button isn't found, note this in the report - it may indicate conditional rendering or unexpected labeling.

After clicking, verify the wallet modal appears and capture a screenshot.

**7. Cleanup:**

Close the browser session.

### Verification Report

Present results to user with:
- Status of each check (TypeScript compilation, server start, rendering, component visibility, wallet connection)
- Screenshots captured during verification
- Overall pass/fail/partial status
- Clear indication of any issues found

See [references/verification.md](references/verification.md) for detailed verification procedures and failure handling.

### Handling Verification Failures

When checks fail, diagnose the issue and offer to fix it. Common failure patterns:

- **TypeScript errors**: Missing types or SDK version mismatch
- **Server won't start**: Bundler config issues (WASM, Turbopack)
- **Module not found**: Dependencies not installed
- **Components don't render**: SSR issues in Next.js
- **Blank page**: Provider not wrapping app correctly
- **Wallet issues**: Wallet provider misconfigured

Ask user how they want to proceed: fix automatically, explain issues for manual fix, or skip verification. If fixing automatically, apply fixes and re-run failed checks until everything passes or user chooses to stop.

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
