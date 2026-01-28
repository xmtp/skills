# Generation Matrix

This file is the **single source of truth** for what files are generated based on interview answers.

The spec generation phase (Phase 3) reads this matrix to determine which files to generate and which reference files to pull content from.

---

## Base Files (Always Generated)

These files are generated for every XMTP integration, regardless of interview answers.

| File | Reference | Purpose |
|------|-----------|---------|
| `XMTPProvider.tsx` | [XMTPProvider.md](XMTPProvider.md) | React context for client lifecycle |
| `useXMTP.ts` | [hooks/useXMTP.md](hooks/useXMTP.md) | Client initialization and connection state |
| `useConversations.ts` | [hooks/useConversations.md](hooks/useConversations.md) | List and stream conversations |
| `useMessages.ts` | [hooks/useMessages.md](hooks/useMessages.md) | Messages with send functionality |
| `inbox.ts` | [store.md](store.md) | Zustand store for state management |
| `xmtp-streaming.ts` | [xmtp-streaming.md](xmtp-streaming.md) | Stream management with reconnection |
| `xmtp.ts` | [types.md](types.md) | TypeScript type definitions |
| `.env.example` | — | Environment configuration template |

**Always Updated (merge with existing):**

| File | Reference | Purpose |
|------|-----------|---------|
| `next.config.ts` or `vite.config.ts` | [bundler-config.md](bundler-config.md) | WASM/worker configuration |

---

## Conditional Files by Question

### Q1: Chat Type

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `full-app` | `FullAppLayout.tsx` | [layouts/FullAppLayout.md](layouts/FullAppLayout.md) |
| `embedded-feature` | `ChatEmbed.tsx` | Self-contained component, no layout wrapper |
| `widget` | `WidgetLayout.tsx` | [layouts/WidgetLayout.md](layouts/WidgetLayout.md) |

**Note:** Layout files only generated when Q2 = `pre-built`.

### Q2: Components

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `pre-built` | All UI component files (see Component Files below) | [components/*.md](components/) |
| `hooks-only` | No UI components | — |

**When Q2 = `pre-built`**, generate these component files:

| File | Reference |
|------|-----------|
| `ChatContainer.tsx` | [components/ChatContainer.md](components/ChatContainer.md) |
| `ConversationList.tsx` | [components/ConversationList.md](components/ConversationList.md) |
| `MessageThread.tsx` | [components/MessageThread.md](components/MessageThread.md) |
| `NewChatDialog.tsx` | [components/NewChatDialog.md](components/NewChatDialog.md) |
| `StatusToast.tsx` | [components/StatusToast.md](components/StatusToast.md) |
| `LoadingSkeletons.tsx` | [components/LoadingSkeletons.md](components/LoadingSkeletons.md) |
| `EmptyStates.tsx` | [components/EmptyStates.md](components/EmptyStates.md) |
| `ErrorBoundary.tsx` | [components/ErrorBoundary.md](components/ErrorBoundary.md) |

### Q3: Styling (only when Q2 = `pre-built`)

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `match-app` | No new style files | Reuse detected design system |
| `default` / `unstyled` | `chat-theme.css` | [styling/ChatTheme.md](styling/ChatTheme.md) — token structure with placeholders |
| `styled` | `chat-theme.css` | [styling/ChatTheme.md](styling/ChatTheme.md) — populated based on user direction |

### Q4: Wallet Provider

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `rainbowkit` | Wallet setup files | [wallet-providers.md](wallet-providers.md) |
| `web3modal` | Wallet setup files | [wallet-providers.md](wallet-providers.md) |
| `own` | Signer adapter interface | [wallet-providers.md](wallet-providers.md) |
| Detected provider | No wallet files | Use existing |

### Q5: Conversation Types

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `dms-groups` | `useConversation.ts` | [hooks/useConversation.md](hooks/useConversation.md) |
| `dms-groups` + Q2=`pre-built` | `GroupManagement.tsx` | [components/GroupManagement.md](components/GroupManagement.md) |
| `dms-only` | No additional files | — |

### Q6: Message Features

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `attachments` | `FilePicker.tsx` (if Q2=`pre-built`) | [components/FilePicker.md](components/FilePicker.md) |
| `reactions` | `ReactionPicker.tsx` (if Q2=`pre-built`) | [components/ReactionPicker.md](components/ReactionPicker.md) |
| `replies` | `ReplyComposer.tsx` (if Q2=`pre-built`) | [components/ReplyComposer.md](components/ReplyComposer.md) |
| `all-features` | All three above | — |

**Note:** Text messages are always included.

### Q7: Request Filtering

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `yes` | `useConsent.ts` | [hooks/useConsent.md](hooks/useConsent.md) |
| `yes` + Q2=`pre-built` | `RequestsInbox.tsx` | [components/RequestsInbox.md](components/RequestsInbox.md) |
| `no` | No additional files | — |

### Q8: Identity Display

| Answer | Files Generated | Reference |
|--------|-----------------|-----------|
| `ens` | `useIdentity.ts` | [hooks/useIdentity.md](hooks/useIdentity.md) |
| `ens` + Q2=`pre-built` | `IdentityBadge.tsx` | [components/IdentityBadge.md](components/IdentityBadge.md) |
| `custom` | `useIdentity.ts` (with custom resolver interface) | [hooks/useIdentity.md](hooks/useIdentity.md) |
| `custom` + Q2=`pre-built` | `IdentityBadge.tsx` | [components/IdentityBadge.md](components/IdentityBadge.md) |
| `addresses` | No identity files | Truncated addresses only |

---

## Dependencies by Configuration

### Base Dependencies (Always)

| Package | Purpose |
|---------|---------|
| `@xmtp/browser-sdk` | Core XMTP SDK (look up current name) |
| `@xmtp/content-type-text` | Text messages (look up current name) |
| `zustand` | State management |
| `viem` | Ethereum utilities |

### Conditional Dependencies

| Condition | Packages |
|-----------|----------|
| Q3 = `unstyled` | `@base-ui-components/react` |
| Q4 = `rainbowkit` | `@rainbow-me/rainbowkit`, `wagmi`, `@tanstack/react-query` |
| Q4 = `web3modal` | `@web3modal/wagmi`, `wagmi`, `@tanstack/react-query` |
| Q6 includes `attachments` | `@xmtp/content-type-remote-attachment` (look up current name) |
| Q6 includes `reactions` | `@xmtp/content-type-reaction` (look up current name) |
| Q6 includes `replies` | `@xmtp/content-type-reply` (look up current name) |

---

---

## Supporting References (Always Used)

These references inform the spec but don't generate files directly:

| Reference | Purpose |
|-----------|---------|
| [error-handling.md](error-handling.md) | Error types, messages, recovery actions |
| [hook-coordination.md](hook-coordination.md) | Hook dependencies and data flow |
| [identity-resolution.md](identity-resolution.md) | InboxId → address → ENS chain |
| [consumer-ux-requirements.md](consumer-ux-requirements.md) | Loading, error, empty state patterns |
| [design-system-integration.md](design-system-integration.md) | Design system detection and matching |
| [security.md](security.md) | Security checklist and best practices |

---

## Spec Generation Instructions

During Phase 3, the spec is generated by:

1. **Reading this matrix** to determine which files to generate
2. **Reading each relevant reference file** to get behavioral contracts
3. **Pulling content from references** into the spec sections
4. **Resolving all conditionals** based on interview answers

The resulting spec is **self-contained** — Phase 4 code generation reads only the spec, not references directly.

See [spec-template.md](spec-template.md) for the spec structure.
