# LoadingSkeletons Components

Skeleton loaders that mimic final UI structure for perceived performance.

## Interface

```typescript
interface SkeletonLineProps {
  width?: string;
  className?: string;
}

interface SkeletonAvatarProps {
  size?: 'sm' | 'md' | 'lg';
}

interface MessageSkeletonProps {
  isOwn?: boolean;
}
```

## UX Rules

**MUST:**
- Match final layout dimensions, spacing, and structure
- Use subtle pulse animation (1.5s ease-in-out)
- Vary message skeleton widths for realistic appearance
- Respect `prefers-reduced-motion` (disable animation)

**NEVER:**
- Show text like "Loading...", "Initializing...", "Please wait..."
- Use jarring or fast animations
- Mismatch skeleton structure from actual content

**SKELETON TYPES:**
| Type | Structure |
|------|-----------|
| ChatContainer | Sidebar + Main split |
| ConversationList | Search input + Tabs + 6 items |
| MessageThread | Header + 5 messages + Input |
| ConversationItem | Avatar + 2 lines + timestamp |
| MessageBubble | Avatar (other) + bubble with 1-2 lines |

**SPINNER:**
- Use for in-progress actions (send button, load more)
- 16px default, 24px for prominent indicators
- Track at 0.25 opacity, arc at full opacity

**ACCESSIBILITY:**
- Skeletons are decorative (no aria-label needed)
- Parent container: `aria-busy="true"` while loading
- Animation: `animation: none` for `prefers-reduced-motion`

## Look Up

Before implementing, check user's codebase for:

1. **Existing skeleton components**: Does app have skeleton loaders?
2. **Animation utilities**: Tailwind animate-pulse or custom keyframes?
3. **Color tokens**: What colors for skeleton backgrounds?
4. **Motion preferences**: Does app handle reduced motion?
