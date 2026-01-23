# ReactionPicker Component

Emoji picker for adding reactions to messages.

## Interface

```typescript
interface ReactionPickerProps {
  onSelect: (emoji: string) => void;
  onClose: () => void;
  className?: string;
}
```

## UX Rules

**MUST:**
- Show frequently used emoji first (max 6 quick reactions)
- Dismiss on outside click or Escape key
- Position relative to trigger element

**NEVER:**
- Leave picker open after selection

**ACCESSIBILITY:**
- Focus trap within picker
- Arrow key navigation between emoji
- Escape returns focus to trigger element

## Look Up

Before implementing, check:

1. **Existing emoji picker**: Does app already have one?
2. **Popover/dropdown patterns**: Reuse existing positioning logic
3. **Accessible popover patterns**: Prerequisite frontend-design skill
