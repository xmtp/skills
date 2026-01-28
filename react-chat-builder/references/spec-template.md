# Spec Template

This template defines the **structure** for the functional specification document. The spec is **generated** by pulling content from reference files based on interview answers.

**Location:** `xmtp-chat-spec.md` in project root

---

## Generation Instructions

During Phase 3, generate the spec by:

1. **Read generation-matrix.md** to determine which files/references apply
2. **Read each relevant reference file** to get behavioral contracts
3. **Pull content from references** into the sections below
4. **Resolve all conditionals** based on interview answers

The resulting spec is **self-contained** — Phase 4 code generation reads the spec as the source of truth, not references directly.

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

[GENERATED from generation-matrix.md based on config]

### Base Files

| File | Purpose |
|------|---------|
| XMTPProvider.tsx | React context for client lifecycle |
| useXMTP.ts | Client initialization and connection state |
| useConversations.ts | List and stream conversations |
| useMessages.ts | Messages with send functionality |
| inbox.ts | Zustand store for state management |
| xmtp-streaming.ts | Stream management with reconnection |
| xmtp.ts | TypeScript type definitions |

### Conditional Files

[List only files that apply based on interview answers]

| File | Condition | Purpose |
|------|-----------|---------|
| [file] | [which Q answer] | [purpose] |

### Config Updates

| File | Changes |
|------|---------|
| [bundler config] | [XMTP-specific changes needed] |

---

## 3. User Experience

[GENERATED from component references based on Q2 answer]

[Only include this section if Q2 = pre-built]

### ConversationList

**Interface:**
[PULL from components/ConversationList.md]

**Behavior:**
[PULL behavior description from reference]

**States:**
[PULL states from reference]

**Rules:**
[PULL MUST/NEVER rules from reference]

### MessageThread

[Same structure as above]

### MessageComposer

[Same structure as above]

[Continue for each component that applies based on config]

---

## 4. Technical Contracts

[GENERATED from hook references]

### useXMTP

**Interface:**
```typescript
[PULL interface from hooks/useXMTP.md]
```

**Behavior:**
[PULL behavior description]

**Rules:**
[PULL MUST/NEVER rules]

**States:**
[PULL states]

### useConversations

[Same structure]

### useMessages

[Same structure]

[Continue for each hook that applies based on config]

---

## 5. State Management

[GENERATED from store.md]

### Store Interface

```typescript
[PULL interface from store.md]
```

**Rules:**
[PULL MUST/NEVER rules]

**Selector patterns:**
[PULL selector guidance]

---

## 6. Error Handling

[GENERATED from error-handling.md]

| Error Type | User Message | Recovery Action |
|------------|--------------|-----------------|
| [type] | [message] | [action] |

---

## 7. Identity Resolution

[Only include if Q8 = ENS or custom]

[GENERATED from identity-resolution.md]

**Resolution chain:**
[PULL from reference]

**Caching:**
[PULL caching behavior]

---

## 8. Dependencies

### XMTP Packages (from Phase 0 lookup)

| Package | Version | Purpose |
|---------|---------|---------|
| [name] | [version] | [purpose] |

### Supporting Packages

| Package | Purpose |
|---------|---------|
| zustand | State management |
| viem | Ethereum utilities |
[Additional based on config]

---

## 9. Verification Checklist

### Build & Runtime
- [ ] TypeScript compiles without errors
- [ ] Dev server starts without WASM/worker errors
- [ ] No console errors on initial load

### Connection Flow
- [ ] Connect wallet button visible when disconnected
- [ ] Wallet modal opens on click
- [ ] Client initializes after signature
- [ ] Connection state updates correctly

### Conversations
- [ ] Conversations load and display
- [ ] Empty state shown when no conversations
- [ ] Selection updates UI correctly
- [ ] Real-time updates work

### Messaging
- [ ] Messages load for selected conversation
- [ ] Send message works
- [ ] Optimistic update visible
- [ ] Real-time incoming messages appear

[Additional checks based on config]

---

## 10. Integration Notes

### Provider Placement

XMTPProvider wraps components using XMTP hooks:

```tsx
<WalletProvider>
  <XMTPProvider>
    {/* Chat components */}
  </XMTPProvider>
</WalletProvider>
```

### SSR Handling (Next.js)

[Include if framework is Next.js]

Components using XMTP wrapped with `dynamic()` and `{ ssr: false }`.

### Signer Integration

[Details based on Q4 answer]

---
```

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
