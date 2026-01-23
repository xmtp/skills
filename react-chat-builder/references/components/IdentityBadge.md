# IdentityBadge Component

Displays a blockchain address with optional avatar, resolving to human-readable name when available.

## Interface

```typescript
interface IdentityBadgeProps {
  address: string;
  showAvatar?: boolean;
  className?: string;
}
```

## UX Rules

**MUST:**
- Show truncated address immediately while loading
- Fade-transition to resolved name when available
- Use `--identity-avatar-size` CSS custom property for sizing

**NEVER:**
- Show spinner for identity loading—use skeleton or opacity
- Block render on identity resolution

**ACCESSIBILITY:**
- Avatar has `alt` text with address or resolved name
- Truncated addresses use `aria-label` with full address

## Look Up

Before implementing, check user's codebase for:

1. **Existing Avatar component**: Reuse if available
2. **MessageThread sender display**: Match existing patterns for consistency
3. **Skeleton patterns**: Prerequisite frontend-design skill
4. **Blockies/jazzicon library**: For fallback avatars when none available
