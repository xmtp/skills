# Consumer UX Requirements

Requirements for all generated UI components. These apply whenever pre-built components are generated.

## Loading States

**MUST:**
- Use skeleton loaders for messages and conversations
- Use subtle spinners for actions (sending, loading more)

**NEVER:**
- Show text like "Loading...", "Initializing...", "Connecting..."

## Error Handling

**MUST:**
- Error boundaries at conversation and message level
- Retry actions for failed sends
- Graceful degradation (never blank screens)

**NEVER:**
- Show raw error messages to users

## Empty States

**MUST:**
- Friendly messaging for empty inbox
- Clear CTAs to start conversations
- Contextual help text

**NEVER:**
- Leave empty states without guidance

## Transitions

**MUST:**
- Smooth list animations for conversation/message updates
- Message send/receive animations
- View transitions (mobile list ↔ thread)

**NEVER:**
- Jarring UI updates without transitions

## Accessibility

**MUST:**
- Proper focus management
- Keyboard navigation
- Screen reader announcements for new messages
- ARIA roles and labels

**NEVER:**
- Skip keyboard support
- Omit focus visible styles

## Developer vs Consumer Patterns

| Developer Pattern | Consumer Pattern |
|-------------------|------------------|
| `<StatusIndicator status="connecting" />` | Loading skeleton |
| Text: "Sending..." | Subtle opacity change + spinner icon |
| Text: "Failed to send" | Red icon + tap-to-retry gesture |
| Console.log errors | Error boundary with friendly message |
| "Reconnecting to network..." | Silent reconnection, toast only on failure after 5s |

## Debug Mode

Use `NEXT_PUBLIC_XMTP_DEBUG=true` to enable:
- Console logging
- Connection status display
- Verbose error messages
