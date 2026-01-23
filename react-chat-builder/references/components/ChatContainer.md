# ChatContainer Component

Root layout wrapper combining sidebar and main chat area.

## Interface

```typescript
interface ChatContainerProps {
  children?: React.ReactNode;
  sidebar?: React.ReactNode;
  className?: string;
  isLoading?: boolean;
}
```

## UX Rules

**MUST:**
- Use semantic HTML (`<aside>` for sidebar, `<main>` for content)
- Show skeleton loaders during initial load (match final layout structure)
- Wrap content in error boundary for graceful degradation
- Support responsive layout (sidebar hidden on mobile)
- Implement mobile view switching (list view ↔ chat view)

**NEVER:**
- Show text like "Loading..." or "Initializing..." - use skeleton loaders
- Leave error states without retry option
- Break layout on viewport resize

**LAYOUT:**
```
┌─────────────────────────────────────────────────────┐
│                   ChatContainer                      │
├───────────────┬─────────────────────────────────────┤
│   Sidebar     │           Main Content              │
│   (~280px)    │           (flex-1)                  │
│   - Search    │   - Header                          │
│   - ConvoList │   - MessageThread                   │
│               │   - Input                           │
└───────────────┴─────────────────────────────────────┘

Mobile: Full-screen views, toggle between list and chat
```

**ACCESSIBILITY:**
- `role="complementary"` on sidebar
- `role="main"` on content area
- Focus management between sidebar and main
- Skip link support for keyboard navigation

## Look Up

Before implementing, check user's codebase for:

1. **Existing layout components**: Does the app have a sidebar/main layout pattern?
2. **Styling approach**: Tailwind, CSS modules, styled-components?
3. **Error boundary pattern**: Does the app have existing error boundaries?
4. **Responsive breakpoints**: What breakpoint is used for mobile?
5. **Scroll component**: Does the app use a scroll area component?
