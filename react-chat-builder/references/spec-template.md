# Spec Template

This template is used to generate a detailed implementation spec after the interview phase. The spec documents exactly what will be generated before any code is written.

## Template Structure

Generate the spec as a markdown file in the project root: `xmtp-chat-spec.md`

```markdown
# XMTP Chat Integration Spec

Generated: [timestamp]

## Configuration Summary

| Setting | Value |
|---------|-------|
| Chat Type | [full-app / embedded / widget] |
| Components | [pre-built / hooks-only] |
| Styling | [match-app / unstyled / styled / custom] |
| Wallet Provider | [detected or selected] |
| Conversations | [dms-groups / dms-only] |
| Features | [list selected: text, attachments, reactions, replies] |
| Requests Inbox | [yes / no] |
| Identity | [ens / addresses / custom] |

## Detected Project Structure

| Detection | Result |
|-----------|--------|
| Framework | [Next.js (app router) / Next.js (pages) / Vite / CRA] |
| Next.js Version | [version if applicable, note if 16+ for --webpack flag] |
| Styling System | [Tailwind / CSS Modules / styled-components / emotion] |
| Design System | [detected components and tokens, or "none detected"] |
| Wallet Provider | [existing provider or "none detected"] |
| Source Directory | [src/ or root] |
| Components Directory | [path] |
| Hooks Directory | [path] |

## Files to Generate

### Core Files (Always Generated)

| File | Path | Purpose |
|------|------|---------|
| XMTPProvider.tsx | [detected path]/providers/XMTPProvider.tsx | Context provider with client initialization |
| useXMTP.ts | [detected path]/hooks/useXMTP.ts | Core hook for client state |
| useConversations.ts | [detected path]/hooks/useConversations.ts | List and stream conversations |
| useMessages.ts | [detected path]/hooks/useMessages.ts | Messages with send functionality |
| inbox.ts | [detected path]/stores/inbox.ts | Zustand store for state management |
| xmtp-streaming.ts | [detected path]/lib/xmtp-streaming.ts | Stream management with reconnection |
| xmtp.ts | [detected path]/types/xmtp.ts | TypeScript types |
| .env.example | .env.example | Environment configuration |

### Conditional Hooks

[Only list if applicable based on interview answers]

| File | Path | Condition |
|------|------|-----------|
| useConversation.ts | [path] | Groups enabled (Q5 = DMs + Groups) |
| useIdentity.ts | [path] | ENS or custom identity (Q8) |
| useConsent.ts | [path] | Requests inbox enabled (Q7 = Yes) |

### Conditional Components

[Only list if Q2 = Pre-built]

| File | Path | Condition |
|------|------|-----------|
| ChatContainer.tsx | [path] | Always (when pre-built) |
| ConversationList.tsx | [path] | Always (when pre-built) |
| MessageThread.tsx | [path] | Always (when pre-built) |
| NewChatDialog.tsx | [path] | Always (when pre-built) |
| StatusToast.tsx | [path] | Always (when pre-built) |
| LoadingSkeletons.tsx | [path] | Always (when pre-built) |
| EmptyStates.tsx | [path] | Always (when pre-built) |
| IdentityBadge.tsx | [path] | ENS or custom identity |
| RequestsInbox.tsx | [path] | Requests inbox enabled |
| GroupManagement.tsx | [path] | Groups enabled |
| FilePicker.tsx | [path] | Attachments enabled |
| ReactionPicker.tsx | [path] | Reactions enabled |
| ReplyComposer.tsx | [path] | Replies enabled |

### Layouts

[Only list if Q2 = Pre-built]

| File | Path | Condition |
|------|------|-----------|
| FullAppLayout.tsx | [path] | Q1 = Full messaging app |
| WidgetLayout.tsx | [path] | Q1 = Chat widget |

### Styling

| File | Path | Condition |
|------|------|-----------|
| chat-theme.css | [path] | Q3 = unstyled or styled |

## Config Changes

### Bundler Configuration

**File:** [next.config.ts / vite.config.ts]

**Changes Required:**
- [ ] WASM experiments enabled
- [ ] Worker configuration
- [ ] CORS headers (Next.js)
- [ ] External packages (Next.js)

[Show exact diff/additions needed]

### Package.json Scripts

[Only for Next.js 16+]

**Changes Required:**
- [ ] Add `--webpack` to dev script
- [ ] Add `--webpack` to build script

```diff
- "dev": "next dev",
+ "dev": "next dev --webpack",
- "build": "next build",
+ "build": "next build --webpack",
```

## Dependencies to Install

### XMTP Packages

[List exact package names from /xmtp-docs lookup]

```bash
npm install [packages]
```

### Additional Packages

```bash
npm install zustand viem
```

[Add wallet provider packages if selected]
[Add @base-ui-components/react if unstyled selected]

## Interface Contracts

### useXMTP Hook

```typescript
interface UseXMTPReturn {
  client: Client | null;
  isConnecting: boolean;
  isConnected: boolean;
  error: Error | null;
  connect: () => Promise<void>;
  disconnect: () => Promise<void>;
}
```

### useConversations Hook

```typescript
interface UseConversationsReturn {
  conversations: Conversation[];
  isLoading: boolean;
  error: Error | null;
  refresh: () => Promise<void>;
}
```

### useMessages Hook

```typescript
interface UseMessagesReturn {
  messages: Message[];
  isLoading: boolean;
  isSending: boolean;
  error: Error | null;
  sendMessage: (content: string) => Promise<void>;
  loadMore: () => Promise<void>;
  hasMore: boolean;
}
```

[Include additional hook interfaces based on selections]

## Component Props

[Only if Q2 = Pre-built]

### ChatContainer

```typescript
interface ChatContainerProps {
  className?: string;
  children?: React.ReactNode;
}
```

### ConversationList

```typescript
interface ConversationListProps {
  onSelect: (conversationId: string) => void;
  selectedId?: string;
}
```

[Include additional component props based on selections]

## Verification Checklist

After generation, these will be verified:

- [ ] `npm install` completes without errors
- [ ] `npm run dev` starts without WASM/worker errors
- [ ] TypeScript compiles without errors
- [ ] App renders in browser without console errors
- [ ] XMTP components are visible
- [ ] Wallet connection button works
- [ ] XMTP client connects successfully
- [ ] Conversations load (if existing messages)
- [ ] New message can be sent

## Notes

[Any additional context, warnings, or considerations]
```

## Usage in SKILL.md

After the interview phase completes:

1. Generate the spec using detected values and interview answers
2. Save to `xmtp-chat-spec.md` in project root
3. Ask user if they want to review it:

```
AskUserQuestion:
- Question: "I've generated a detailed spec. Want to review it before I start coding?"
- Header: "Spec"
- Options:
  1. "Open in editor" - Opens xmtp-chat-spec.md for review
  2. "Continue" - Proceed directly to code generation
```

If "Open in editor":
- Run: `code xmtp-chat-spec.md` (or detected editor)
- Tell user: "Review the spec. When ready, say 'continue' to start generation."
- Wait for user to say "continue" before proceeding

If "Continue":
- Proceed directly to Phase 3 (Generation)
