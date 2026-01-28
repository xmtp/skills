# MessageThread Component

Message list and input combined into a single thread view.

## Interface

```typescript
interface MessageThreadProps {
  conversationId: string;
  onBack?: () => void;
  className?: string;
}

interface MessageBubbleProps {
  message: Message;
  showSender?: boolean;
  showTimestamp?: boolean;
  onRetry?: () => void;
}
```

## UX Rules

**MUST:**
- Show skeleton during initial load (header + message bubbles + input)
- Auto-scroll to bottom on new messages
- Preserve scroll position when loading history (infinite scroll at top)
- Use icon-based status indicators (spinner, checkmark, error icon)
- Provide retry button on failed messages
- Sanitize group names (max 100 chars, strip `<>`)
- Validate attachment URLs before rendering (block javascript:, data:)

**NEVER:**
- Show text status like "Sending..." - use spinner icon
- Auto-scroll when user is reading history
- Show raw error messages

**MESSAGE BUBBLE:**
- Own messages: Right-aligned, colored background
- Other messages: Left-aligned, neutral background
- Status icons: Spinner (sending), Check (sent), Error icon + tap to retry (failed)
- Groups: Show sender name on first message in sequence

**INPUT AREA:**
- Placeholder: "Type a message..."
- Enter to send, Shift+Enter for newline
- Send button: Icon, disabled when empty or sending
- Optional: Attachment button

## System Messages

System messages are metadata events (not user-sent content) displayed inline in the message thread. They indicate group membership changes, settings updates, and other conversation events.

**Examples:**
- "Alice added Bob to the group"
- "Carol left the group"
- "Group name changed to 'Project Team'"
- "Alice removed Bob from the group"

**Visual treatment:**
- Centered horizontally (not left/right aligned like chat bubbles)
- No avatar displayed
- Muted text color (`--chat-text-muted`)
- Smaller font size than regular messages
- No background bubble (or subtle divider line)
- Timestamp optional (can be shown on hover or omitted)

**Structure:**

```typescript
interface SystemMessageProps {
  event: 'member_added' | 'member_removed' | 'member_left' | 'group_renamed' | 'group_created';
  actor?: string;      // inboxId of who performed the action
  target?: string;     // inboxId of who was affected (for add/remove)
  metadata?: string;   // Additional info (new group name, etc.)
  timestamp: Date;
}
```

**Display logic:**
- `actor` and `target` resolve through identity resolution chain (inboxId → address → ENS)
- If actor is current user, display "You" instead of resolved name
- System messages interspersed chronologically with regular messages

**Rendering pattern:**

```tsx
{messages.map((msg) =>
  msg.type === 'system' ? (
    <SystemMessage key={msg.id} event={msg.event} ... />
  ) : (
    <MessageBubble key={msg.id} message={msg} ... />
  )
)}
```

## Message Type Discrimination

Messages have different types that determine rendering:

| Type | Rendering | Examples |
|------|-----------|----------|
| `text` | Chat bubble (left/right aligned) | Regular messages |
| `system` | Centered, muted, no avatar | Member added, group renamed |
| `attachment` | Chat bubble with media preview | Images, files |
| `reaction` | Not rendered as standalone message | Applied to parent message |
| `reply` | Chat bubble with quoted parent | Threaded replies |

The component checks `message.type` (or content type) to determine which renderer to use.

## Sender Identity Display

For non-system messages from other participants:

1. Extract `senderInboxId` from message
2. Resolve to address via SDK (see `identity-resolution.md`)
3. Pass address to `useIdentity` hook
4. Display resolved name + avatar (or truncated address while loading)

Avatar fallback chain: ENS avatar → generated avatar from address (blockies/jazzicon)

**VIRTUALIZATION:**
- Use for conversations >100 messages
- Estimated row height ~60px
- Overscan 5 items

**ACCESSIBILITY:**
- `role="log"` on message container
- `aria-live="polite"` for new messages
- Focus management after sending
- Retry buttons have descriptive aria-label
- System messages have `role="status"`

## Look Up

Before implementing, check:

1. **XMTP message types**: Query `/xmtp-docs` for how to distinguish system messages from regular messages
2. **Group event types**: What events does the SDK expose for membership changes?
3. **Existing message/chat components**: Any chat UI patterns in user's codebase?
4. **Input component**: Does the app have a text input?
5. **Icon library**: What icons are available (send, check, error)?
6. **Virtualization library**: Does the app use @tanstack/react-virtual?
7. **Scroll component**: Existing scroll area implementation?
8. **Time formatting**: How does the app format timestamps?
