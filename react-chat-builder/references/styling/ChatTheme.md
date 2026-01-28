# ChatTheme Styling

CSS custom property tokens for consistent chat UI theming.

## Interface

Token names (AI generates appropriate values based on user's design system):

```
Colors:
  --chat-bg-primary, --chat-bg-secondary, --chat-bg-accent
  --chat-text-primary, --chat-text-secondary, --chat-text-muted, --chat-text-on-accent
  --chat-border, --chat-error

Spacing (4px grid):
  --chat-spacing-xs, --chat-spacing-sm, --chat-spacing-md, --chat-spacing-lg, --chat-spacing-xl

Radii:
  --chat-radius-sm, --chat-radius-md, --chat-radius-lg, --chat-radius-full

Sizing:
  --chat-avatar-size, --chat-widget-z-index

Transitions:
  --chat-transition-fast, --chat-transition-normal
```

## Rules

**MUST:**
- All values use CSS custom properties (no hardcoded colors/sizes)
- Use 4px spacing grid for consistency

**Base UI Integration (when selected):**
- Import from `@base-ui-components/react`
- Style via `data-*` attribute selectors

**NEVER:**
- Use Tailwind classes in reference files (user may not have Tailwind)
- Hardcode colors, spacing, or sizes

## Look Up

Before implementing, check:

1. **Base UI docs**: Check Base UI documentation for component patterns and data attributes
2. **Existing CSS custom properties**: Avoid naming conflicts with user's tokens
3. **Design system**: Prerequisite web-design-guidelines skill
