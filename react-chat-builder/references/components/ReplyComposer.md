# ReplyComposer Component

Quote preview and input for replying to specific messages in a thread.

## Interface

```typescript
import type { Message } from '../types/xmtp';

interface ReplyComposerProps {
  replyingTo: Message;
  onCancel: () => void;
  onSend: (text: string) => void;
  className?: string;
}
```

## UX Rules

**MUST:**
- Show quoted preview of original message (max 100 chars)
- Clear reply state after successful send
- X button to cancel reply

**NEVER:**
- Show full original message in quote preview

**ACCESSIBILITY:**
- Quote preview has `aria-label`: "Replying to: [preview text]"
- Focus moves to input after selecting reply

## Look Up

Before implementing, check:

1. **Quote/blockquote patterns**: Existing styling for quoted content?
2. **Message input focus handling**: How does current input manage focus?
3. **types/xmtp.ts**: Verify Message type definition
