# StatusToast Component

Consumer-friendly notifications. Silent by default - only shows when user attention is needed.

## Interface

```typescript
interface ToastData {
  id: string;
  title: string;
  description?: string;
  type: 'success' | 'error';
  action?: {
    label: string;
    onClick: () => void;
  };
}

interface ToastStore {
  toasts: ToastData[];
  show: (toast: Omit<ToastData, 'id'>) => void;
  dismiss: (id: string) => void;
}
```

## UX Rules

**MUST:**
- Be silent by default (no routine status notifications)
- Delay connection error toasts by 5 seconds (allow silent reconnect)
- Map technical errors to user-friendly messages
- Provide retry button for recoverable errors
- Auto-dismiss success toasts after 3 seconds
- Persist error toasts until dismissed or action taken

**NEVER:**
- Show "Connecting...", "Reconnecting...", "Connected" toasts
- Expose raw error messages to users
- Show toasts for routine sync operations

**WHEN TO TOAST:**
| Show | Don't Show |
|------|------------|
| Send failed + Retry | Initial connecting (use skeleton) |
| Connection lost 5s+ + Retry | Reconnecting < 5s (silent retry) |
| Action succeeded (optional) | "Connected" (expected behavior) |

**ERROR MESSAGE MAPPING:**
| Technical Error | User-Friendly |
|-----------------|---------------|
| network/fetch error | Check your internet connection |
| rejected/denied | Message was rejected |
| timeout | Request timed out. Please try again. |
| other | Something went wrong. Please try again. |

**ACCESSIBILITY:**
- `role="alert"` for error toasts
- Close button with accessible label
- Swipe to dismiss on touch
- Keyboard: Escape to dismiss
- Focus not trapped in toast

## Look Up

Before implementing, check user's codebase for:

1. **Existing toast system**: Does app have a toast/notification component?
2. **State management**: Zustand, Redux, or Context for toast store?
3. **Toast library**: sonner, react-hot-toast, or custom?
4. **Position preference**: Bottom-right, top-center, etc.?
5. **Animation library**: framer-motion or CSS transitions?
