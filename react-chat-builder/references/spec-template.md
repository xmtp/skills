# Spec Template

This template defines the **structure** for the functional specification document. The spec is **generated** by COPYING content from reference files based on interview answers.

**Location:** `xmtp-chat-spec.md` in project root

---

## CRITICAL: What "Generate from References" Means

**DO NOT SUMMARIZE. COPY THE ACTUAL CONTENT.**

The spec must be **self-contained** — an AI generating code in Phase 4 reads ONLY the spec, not the reference files. If the spec lacks detail, code generation will be inconsistent.

For each section marked `[COPY FROM reference.md]`:
1. Open the reference file
2. Copy the relevant sections **verbatim** (Interface, Rules, States, etc.)
3. Paste into the spec
4. Resolve any conditionals based on interview answers

**The spec should be 3-5x longer than the example below because it contains the full content from references.**

---

## Template Structure

```markdown
# XMTP Chat Integration — Functional Specification

Generated: [timestamp]
Project: [project name from package.json]

---

## 1. Configuration

### 1.1 Interview Answers

| Question | Answer |
|----------|--------|
| Q1: Chat Type | [value] |
| Q2: Components | [pre-built / hooks-only] |
| Q3: Styling | [value] |
| Q4: Wallet Provider | [value] |
| Q5: Conversation Types | [DMs only / DMs + Groups] |
| Q6: Message Features | [list] |
| Q7: Request Filtering | [yes / no] |
| Q8: Identity Display | [ENS / addresses / custom] |

### 1.2 Project Context

| Aspect | Details |
|--------|---------|
| Framework | [detected framework and router] |
| Styling System | [detected styling approach] |
| Design System | [detected components/tokens or "none"] |
| Wallet Integration | [detected provider or "to be added"] |
| Source Structure | [directory organization] |

---

## 2. Files to Generate

[Read generation-matrix.md, list ALL files that apply based on config]

### Base Files

| File | Path | Purpose |
|------|------|---------|
| XMTPProvider.tsx | src/xmtp/XMTPProvider.tsx | React context for client lifecycle |
| useXMTP.ts | src/xmtp/hooks/useXMTP.ts | Client initialization and connection |
| useConversations.ts | src/xmtp/hooks/useConversations.ts | List and stream conversations |
| useMessages.ts | src/xmtp/hooks/useMessages.ts | Messages with send functionality |
| inbox.ts | src/xmtp/store/inbox.ts | Zustand store |
| xmtp-streaming.ts | src/xmtp/lib/xmtp-streaming.ts | Stream management |
| xmtp.ts | src/xmtp/types/xmtp.ts | TypeScript definitions |

### Conditional Files

[List EVERY file from generation-matrix.md that applies]

| File | Path | Condition |
|------|------|-----------|
| useConversation.ts | ... | Q5 = DMs + Groups |
| useConsent.ts | ... | Q7 = Yes |
| ... | ... | ... |

---

## 3. Hook Contracts

[For EACH hook, COPY the full content from the reference file]

### useXMTP

[COPY FROM hooks/useXMTP.md - Include ALL of these sections:]

**Interface:**
```typescript
[COPY the full TypeScript interface from the reference]
```

**Behavior:**
[COPY the Behavior section from the reference]

**Rules:**

MUST:
[COPY all MUST rules from the reference]

NEVER:
[COPY all NEVER rules from the reference]

**States:**

| State | Description |
|-------|-------------|
[COPY the states table from the reference]

---

### useConversations

[COPY FROM hooks/useConversations.md - same structure as above]

**Interface:**
```typescript
[COPY full interface]
```

**Behavior:**
[COPY behavior section]

**Rules:**

MUST:
[COPY all MUST rules]

NEVER:
[COPY all NEVER rules]

**States:**
[COPY states]

---

### useMessages

[COPY FROM hooks/useMessages.md - same structure]

---

### useConversation (if Q5 = Groups)

[COPY FROM hooks/useConversation.md]

---

### useConsent (if Q7 = Yes)

[COPY FROM hooks/useConsent.md]

---

### useIdentity (if Q8 = ENS or custom)

[COPY FROM hooks/useIdentity.md]

---

## 4. State Management

[COPY FROM store.md]

### Store Interface

```typescript
[COPY the full InboxState and InboxActions interfaces]
```

### Rules

MUST:
[COPY all MUST rules from store.md]

NEVER:
[COPY all NEVER rules from store.md]

### Selector Patterns

[COPY the selector guidance from store.md - the table of access patterns]

---

## 5. Streaming

[COPY FROM xmtp-streaming.md]

### Interface

```typescript
[COPY the StreamManager interface]
```

### Behavior

[COPY behavior section]

### Rules

MUST:
[COPY MUST rules]

NEVER:
[COPY NEVER rules]

### Reconnection

[COPY reconnection thresholds table]

---

## 6. Component Contracts (if Q2 = pre-built)

[For EACH component that applies, COPY from its reference file]

### ChatContainer

[COPY FROM components/ChatContainer.md]

**Interface:**
```typescript
[COPY props interface]
```

**Rules:**
[COPY UX rules - MUST and NEVER]

---

### ConversationList

[COPY FROM components/ConversationList.md]

**Interface:**
```typescript
[COPY props interface]
```

**Rules:**
[COPY UX rules]

**States:**
[COPY states if present]

---

### MessageThread

[COPY FROM components/MessageThread.md]

---

### [Continue for EVERY component from generation-matrix.md]

---

## 7. Error Handling

[COPY FROM error-handling.md - Include ALL tables]

### Connection Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
[COPY the full connection errors table]

### Sending Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
[COPY the full sending errors table]

### Streaming Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
[COPY the full streaming errors table]

### Identity Resolution Errors

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
[COPY the full identity errors table]

### Error Boundaries

[COPY the error boundaries table]

### Toast Notifications

[COPY the toast notifications table]

---

## 8. Identity Resolution (if Q8 = ENS or custom)

[COPY FROM identity-resolution.md]

### Resolution Chain

[COPY the resolution chain section - the full flow from inboxId → address → ENS]

### Caching Behavior

[COPY caching section]

### Display States

| Resolution State | Display |
|------------------|---------|
[COPY the states table]

### Component Usage

[COPY the component usage table]

---

## 9. Consumer UX Requirements

[COPY FROM consumer-ux-requirements.md]

### Loading States

MUST:
[COPY loading MUST rules]

NEVER:
[COPY loading NEVER rules]

### Error Handling

MUST:
[COPY error MUST rules]

NEVER:
[COPY error NEVER rules]

### Empty States

MUST:
[COPY empty state MUST rules]

### Transitions

MUST:
[COPY transition MUST rules]

### Accessibility

MUST:
[COPY accessibility MUST rules]

### Developer vs Consumer Patterns

| Developer Pattern | Consumer Pattern |
|-------------------|------------------|
[COPY the full table]

---

## 10. Dependencies

### XMTP Packages (from Phase 0 lookup)

| Package | Version | Purpose |
|---------|---------|---------|
| [exact package name from docs] | [version] | [purpose] |

### Supporting Packages

| Package | Purpose |
|---------|---------|
| zustand | State management |
| viem | Ethereum utilities |

### Conditional Packages (from generation-matrix.md)

[List packages based on config - wallet provider, content types, etc.]

---

## 11. Bundler Configuration

[COPY FROM bundler-config.md - the section matching detected framework]

### [Next.js / Vite] Configuration

```typescript
[COPY the exact config code for the framework]
```

### Troubleshooting

[COPY relevant troubleshooting items]

---

## 12. Verification Checklist

### Build & Runtime
- [ ] TypeScript compiles without errors
- [ ] Dev server starts without WASM/worker errors
- [ ] No console errors on initial load

### Connection Flow
- [ ] Connect wallet button visible when disconnected
- [ ] Wallet modal opens on click
- [ ] XMTP signature request appears
- [ ] Client initializes after signature
- [ ] Connection state updates correctly

### Conversations
- [ ] Conversations load and display
- [ ] Empty state shown when no conversations
- [ ] Skeleton loaders during load
- [ ] Selection updates UI correctly
- [ ] Real-time updates when new conversations arrive

### Messaging
- [ ] Messages load for selected conversation
- [ ] Skeleton loaders during load
- [ ] Send message works
- [ ] Optimistic update visible immediately
- [ ] Real-time incoming messages appear
- [ ] Failed messages show retry button

[Add checks for each enabled feature: groups, attachments, reactions, replies, consent, ENS]

---

## 13. Integration Notes

### Provider Hierarchy

```tsx
[Show exact provider nesting based on wallet provider selection]
```

### Signer Integration

[Details based on Q4 answer - how to get signer from wallet provider]

### SSR Handling (if Next.js)

[Dynamic import pattern for XMTP components]

---
```

---

## Spec Length Guideline

A complete spec for a full-featured integration (all options enabled) should be approximately **800-1200 lines** because it contains:

- Full TypeScript interfaces for 6+ hooks
- MUST/NEVER rules for each hook (typically 5-10 rules each)
- Full error handling tables (30+ error types)
- Component contracts for 10+ components
- Consumer UX requirements
- Complete bundler configuration

**If your spec is under 300 lines, you summarized instead of copying.**

---

## Spec Review Flow

After generating the spec:

1. **Save to `xmtp-chat-spec.md`** in project root
2. **Ask user** whether to review:
   - "Open in editor" → Open file, wait for "continue"
   - "Continue" → Proceed to Phase 4

If user requests changes:
1. Update the spec file
2. Summarize changes
3. Wait for "continue"
