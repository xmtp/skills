# ConversationList Component

Scrollable sidebar showing conversations with search, tabs, and request handling.

## Interface

```typescript
interface ConversationListProps {
  onSelect: (conversationId: string) => void;
  selectedId?: string;
  showRequests?: boolean;
  className?: string;
  onNewChat?: () => void;
}

interface ConversationItemProps {
  conversation: Conversation;
  isSelected: boolean;
  onClick: () => void;
  isRequest?: boolean;
}
```

## UX Rules

**MUST:**
- Show skeleton loader during initial load (match final layout)
- Sort conversations by most recent message
- Sanitize group names (max 100 chars, strip `<>` for XSS prevention)
- Show Inbox/Requests tabs when requests exist
- Filter by peer address, group name, or member addresses
- Provide empty state with CTA for new chat

**NEVER:**
- Show raw error messages to users
- Leave empty states without guidance
- Skip keyboard navigation support

**ITEM DISPLAY:**
- Avatar (identicon or ENS avatar)
- Name: Group name or truncated address (with ENS if available)
- Preview: Last message text or "No messages"
- Timestamp: Relative time ("2m", "1h", "Yesterday")

**REQUESTS TAB:**
- Shows conversations with `Unknown` consent state
- Each item has Accept (✓) and Block (✕) buttons
- Brief explanation: "Messages from people you haven't chatted with"

**ACCESSIBILITY:**
- `role="listbox"` on list, `role="option"` on items
- `aria-selected` for current selection
- `role="tablist"` and `role="tab"` for tabs
- Arrow keys to navigate, Enter to select
- Focus visible styles

## Look Up

Before implementing, check user's codebase for:

1. **Existing list components**: Does the app have a list pattern?
2. **Avatar component**: How does the app display user avatars?
3. **Address display**: Is there an existing address truncation component?
4. **Relative time**: Does the app have a time formatting utility?
5. **Tab component**: Does the app have existing tab UI?
6. **Empty state pattern**: How does the app handle empty lists?
