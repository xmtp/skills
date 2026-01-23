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

**VIRTUALIZATION:**
- Use for conversations >100 messages
- Estimated row height ~60px
- Overscan 5 items

**ACCESSIBILITY:**
- `role="log"` on message container
- `aria-live="polite"` for new messages
- Focus management after sending
- Retry buttons have descriptive aria-label

## Look Up

Before implementing, check user's codebase for:

1. **Existing message/chat components**: Any chat UI patterns?
2. **Input component**: Does the app have a text input?
3. **Icon library**: What icons are available (send, check, error)?
4. **Virtualization library**: Does the app use @tanstack/react-virtual?
5. **Scroll component**: Existing scroll area implementation?
6. **Time formatting**: How does the app format timestamps?
