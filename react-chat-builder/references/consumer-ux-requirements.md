# Consumer UX Requirements

Requirements for all generated components when Q3 = Pre-built.

## Loading States

- Skeleton loaders for messages, conversations (never "Loading..." text)
- Subtle spinners for actions (sending, loading more)
- No visible "initializing", "connecting", or "loading" text

## Error Handling

- Error boundaries at conversation and message level
- Retry actions for failed sends
- Graceful degradation, never blank screens

## Empty States

- Friendly messaging for empty inbox
- Clear CTAs to start conversations
- Contextual help text

## Transitions

- Smooth list animations
- Message send/receive animations
- View transitions (mobile list ↔ thread)

## Accessibility

- Proper focus management
- Keyboard navigation
- Screen reader announcements for new messages

## Developer vs Consumer Patterns

| Developer Pattern | Consumer Pattern |
|-------------------|------------------|
| `<StatusIndicator status="connecting" />` | Loading skeleton |
| Text: "Sending..." | Subtle opacity change + spinner icon |
| Text: "Failed to send" | Red icon + tap-to-retry gesture |
| Console.log errors | Error boundary with friendly message |
| "Reconnecting to network..." | Silent reconnection, toast only on failure after 5s |

## Debug Mode

Use `NEXT_PUBLIC_XMTP_DEBUG=true` to enable console logging and connection status display.
