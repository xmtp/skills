# WidgetLayout Component

Floating chat widget overlay for embedding messaging in existing applications.

## Interface

```typescript
interface ChatWidgetProps {
  defaultOpen?: boolean;
  onToggle?: (open: boolean) => void;
  className?: string;
}
```

## UX Rules

**MUST:**
- Floating button to toggle open/closed (bottom-right)
- Overlay panel, doesn't affect page layout
- Escape key closes widget

**NEVER:**
- Push page content when opening

**ACCESSIBILITY:**
- Toggle button has `aria-expanded` state
- Panel has `role="dialog"` and `aria-label`
- Focus moves to panel on open, returns to button on close

## Look Up

Before implementing, check:

1. **Modal/overlay patterns**: Existing overlay components?
2. **Floating action button**: Does app have FAB styling?
3. **Overlay accessibility**: Prerequisite frontend-design skill
