# Design System Integration

How to detect, analyze, and integrate with existing design systems.

## Overview

When generating chat components, respect the app's existing design language:

1. **Never reinvent** - Use existing components, tokens, patterns
2. **Match conventions** - Follow naming, structure, file organization
3. **Blend seamlessly** - Generated code should look like the developer wrote it

## Detection Interface

```typescript
interface DesignSystemDetection {
  // Styling approach
  styling: 'tailwind' | 'css-modules' | 'styled-components' | 'emotion' | 'css' | 'unknown';
  tailwindConfig?: TailwindConfig;

  // Component library
  componentLibrary?: 'mui' | 'chakra' | 'radix' | 'shadcn' | 'base-ui' | 'none';

  // Existing components
  existingComponents: {
    button?: ComponentPattern;
    input?: ComponentPattern;
    avatar?: ComponentPattern;
    card?: ComponentPattern;
    dialog?: ComponentPattern;
  };

  // Design tokens
  tokens?: {
    colors: Record<string, string>;
    spacing: Record<string, string>;
    radii: Record<string, string>;
    fonts: Record<string, string>;
  };

  // Conventions
  conventions: {
    naming: 'kebab-case' | 'PascalCase' | 'camelCase';
    fileStructure: 'flat' | 'nested' | 'feature-based';
    cssNaming: 'BEM' | 'utility' | 'component-scoped' | 'unknown';
  };
}

interface ComponentPattern {
  path: string;
  imports: string[];
  props: string[];
  className: string;
  variants?: string[];
  styling: 'tailwind' | 'css-modules' | 'styled' | 'inline';
}
```

## Rules

**MUST:**
- Detect before generating any components
- Reuse existing Button, Input, Avatar components
- Match detected naming conventions (file names, CSS classes)
- Use detected design tokens (colors, spacing, radii)
- Follow detected import path style (@/ alias vs relative)

**NEVER:**
- Hardcode colors or spacing values
- Generate components that clash with existing patterns
- Use different styling approach than the app

## Detection Targets

| Category | Detection Method | What to Extract |
|----------|------------------|-----------------|
| CSS Framework | `tailwind.config.js`, imports | Theme colors, spacing, fonts |
| CSS Methodology | File patterns, class naming | BEM, CSS Modules, utility-first |
| Component Library | `package.json`, imports | MUI, Chakra, Radix, shadcn, etc. |
| Design Tokens | Variable files, theme configs | Colors, spacing, typography, radii |
| Existing Components | Directory scan | Button, Input, Avatar, Card patterns |

## Generation Strategies

| Scenario | Strategy |
|----------|----------|
| Existing Button detected | Import and use with matching variant |
| Tokens detected, no Button | Generate using detected tokens |
| CSS variables detected | Generate using CSS variables |
| Nothing detected (greenfield) | Use Base UI + chat-theme.css |

## File Naming Conventions

Match the app's existing conventions:

| Detected Convention | Generated Files |
|--------------------|-----------------|
| `kebab-case` dirs | `components/chat/message-thread.tsx` |
| `PascalCase` files | `components/chat/MessageThread.tsx` |
| `index.ts` exports | `components/chat/MessageThread/index.tsx` |
| Flat structure | `components/ChatContainer.tsx` |
| Feature-based | `features/chat/components/MessageThread.tsx` |

## Import Path Conventions

Match the app's import style:

| Pattern | Example |
|---------|---------|
| @/ alias | `import { Button } from '@/components/ui/Button'` |
| Relative | `import { Button } from '../ui/Button'` |
| Barrel exports | `import { Button } from '@/components/ui'` |

## Greenfield Apps

When no design system is detected:

1. **Use Base UI primitives** - Unstyled components for accessibility
2. **Generate chat-theme.css** - CSS custom properties with sensible defaults
3. **Include customization docs** - Comments explaining how to override

See [styling/ChatTheme.md](styling/ChatTheme.md) for the theme file structure.

## Look Up

Before implementing, check user's codebase for:

1. **Config files**: tailwind.config.js, tsconfig paths
2. **Component directories**: src/components, app/components, ui/
3. **Existing primitives**: Button, Input, Avatar, Card
4. **Import patterns**: @/ alias usage, barrel exports
5. **CSS approach**: Tailwind classes, CSS modules, styled-components
