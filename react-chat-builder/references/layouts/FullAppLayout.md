# FullAppLayout Component

Page-level layout for full messaging applications with sidebar navigation.

## Interface

```typescript
interface FullAppLayoutProps {
  children: React.ReactNode;
  sidebar?: React.ReactNode;
  header?: React.ReactNode;
  className?: string;
}
```

## UX Rules

**MUST:**
- Responsive: sidebar + main on desktop (breakpoint: 768px)
- Mobile: stack layout with back button navigation
- Preserve scroll position when navigating back

**NEVER:**
- Show both list and thread on mobile (one at a time)

**ACCESSIBILITY:**
- Skip link to main content
- Landmark roles: `nav` for sidebar, `main` for content

## Look Up

Before implementing, check:

1. **Routing library**: react-router, next/navigation, or other?
2. **Responsive layout patterns**: Existing breakpoint utilities?
3. **Sidebar component**: Does app have one to reuse?
