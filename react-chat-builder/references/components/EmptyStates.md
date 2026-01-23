# EmptyStates Components

Consumer-friendly empty states with clear CTAs.

## Interface

```typescript
interface EmptyInboxProps {
  onNewChat?: () => void;
}

interface EmptyThreadProps {
  recipientName?: string;
}

interface EmptySearchResultsProps {
  query: string;
  onClear?: () => void;
}

interface ErrorStateProps {
  title?: string;
  message?: string;
  onRetry?: () => void;
}
```

## UX Rules

**MUST:**
- Use friendly language ("No conversations yet" not "Query returned 0 results")
- Include clear CTA when action is possible
- Match app's existing design tokens and patterns
- Use icons from app's icon library (or emoji fallback)

**NEVER:**
- Show technical jargon or error codes
- Leave user without guidance on next steps
- Use inconsistent styling from rest of app

**EMPTY STATES:**
| State | Icon | Title | Description | CTA |
|-------|------|-------|-------------|-----|
| Empty inbox | Message icon | No conversations yet | Start a new conversation... | New message |
| Empty thread | Message circle | - | Start your conversation with {name} | - |
| Empty search | Search icon | No results | No conversations match "{query}" | Clear search |
| Empty requests | Inbox icon | No message requests | When someone new messages you... | - |
| Error | Alert icon | Something went wrong | We couldn't load this... | Try again |

**ACCESSIBILITY:**
- Proper heading hierarchy (`h3` within region)
- Icons are decorative (`aria-hidden="true"`)
- CTAs are focusable buttons
- Color contrast meets WCAG AA

## Look Up

Before implementing, check user's codebase for:

1. **Icon library**: Heroicons, Lucide, custom icons, or emoji?
2. **Button component**: Existing button to reuse?
3. **Design tokens**: Colors, spacing, typography?
4. **Styling approach**: Tailwind, CSS modules, styled-components?
5. **Empty state patterns**: How does app handle other empty states?
