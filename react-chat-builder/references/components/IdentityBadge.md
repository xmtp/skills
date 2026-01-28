# IdentityBadge Component

Displays a blockchain address with optional avatar, resolving to human-readable name when available.

## Interface

```typescript
interface IdentityBadgeProps {
  address: string;
  showAvatar?: boolean;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}
```

## Identity Resolution

This component receives an Ethereum address (not an inboxId). If the caller has an inboxId, they resolve it to an address first. See `identity-resolution.md` for the full chain.

The component uses `useIdentity(address)` internally to resolve:
- ENS name (if registered)
- ENS avatar (if set)

## UX Rules

**MUST:**
- Show truncated address immediately while loading
- Fade-transition to resolved name when available
- Use `--identity-avatar-size` CSS custom property for sizing

**NEVER:**
- Show spinner for identity loading—use skeleton or reduced opacity
- Block render on identity resolution
- Show "Loading..." text

## Avatar Fallback Chain

Avatars resolve through this fallback chain:

1. **ENS avatar** — If the address has an ENS name with an avatar record, display it
2. **Generated avatar** — If no ENS avatar, generate a deterministic avatar from the address using blockies or jazzicon
3. **Placeholder** — If generation unavailable, show a generic user icon

**Avatar loading behavior:**
- Generated avatar displays immediately (no network needed)
- ENS avatar replaces it when loaded (fade transition)
- If ENS avatar fails to load (404, network error), generated avatar remains

**Generated avatar consistency:**
The same address always generates the same visual pattern. This provides visual continuity even before ENS resolution completes.

## Display States

| State | Name Display | Avatar Display |
|-------|--------------|----------------|
| Initial | Truncated address (`0xd8dA...6045`) | Generated avatar |
| Resolving | Truncated address (reduced opacity) | Generated avatar |
| Resolved (has ENS) | ENS name (`vitalik.eth`) | ENS avatar (or generated if none) |
| Resolved (no ENS) | Truncated address | Generated avatar |
| Error | Truncated address | Generated avatar |

## Sizing

| Size | Avatar | Font |
|------|--------|------|
| `sm` | 24px | 12px |
| `md` | 32px | 14px |
| `lg` | 40px | 16px |

Sizes configurable via CSS custom properties:
- `--identity-avatar-size-sm`
- `--identity-avatar-size-md`
- `--identity-avatar-size-lg`

## Accessibility

- Avatar `img` has `alt` text: resolved name or full address
- Truncated addresses use `aria-label` with full address
- Generated avatars are decorative (`alt=""`) since the text label conveys identity

## Look Up

Before implementing, check user's codebase for:

1. **Existing Avatar component**: Reuse if available
2. **Blockies/jazzicon library**: For generated avatars—check if already installed
3. **Image loading patterns**: How does the app handle image load states?
4. **Skeleton patterns**: Prerequisite frontend-design skill
