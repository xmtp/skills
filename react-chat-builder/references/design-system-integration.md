# Design System Integration

How to detect, analyze, and integrate with existing design systems.

## Table of Contents
- [Overview](#overview)
- [Detection Phase](#detection-phase)
- [Token Extraction](#token-extraction)
- [Component Pattern Matching](#component-pattern-matching)
- [Generation Strategies](#generation-strategies)
- [Greenfield Apps](#greenfield-apps)

## Overview

When generating chat components, we must respect the app's existing design language. This means:

1. **Never reinvent** - Use existing components, tokens, patterns
2. **Match conventions** - Follow naming, structure, file organization
3. **Blend seamlessly** - Generated code should look like the developer wrote it

## Detection Phase

### What to Detect

| Category | Detection Method | What to Extract |
|----------|------------------|-----------------|
| CSS Framework | `tailwind.config.js`, imports | Theme colors, spacing, fonts |
| CSS Methodology | File patterns, class naming | BEM, CSS Modules, utility-first |
| Component Library | `package.json`, imports | MUI, Chakra, Radix, shadcn, etc. |
| Design Tokens | Variable files, theme configs | Colors, spacing, typography, radii |
| Existing Components | Directory scan | Button, Input, Avatar, Card patterns |

### Detection Code

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
```

### Detecting Tailwind Config

```typescript
async function detectTailwindConfig(projectRoot: string): Promise<TailwindConfig | null> {
  const configPaths = [
    'tailwind.config.js',
    'tailwind.config.ts',
    'tailwind.config.mjs',
  ];

  for (const configPath of configPaths) {
    const fullPath = join(projectRoot, configPath);
    if (await exists(fullPath)) {
      const content = await readFile(fullPath);
      return parseTailwindConfig(content);
    }
  }

  return null;
}

interface TailwindConfig {
  theme: {
    colors?: Record<string, string | Record<string, string>>;
    spacing?: Record<string, string>;
    borderRadius?: Record<string, string>;
    fontFamily?: Record<string, string[]>;
  };
  extend?: {
    colors?: Record<string, string>;
  };
}
```

### Detecting Existing Components

```typescript
async function detectExistingComponents(projectRoot: string): Promise<ExistingComponents> {
  const componentDirs = [
    'src/components',
    'components',
    'src/ui',
    'app/components',
  ];

  const components: ExistingComponents = {};

  for (const dir of componentDirs) {
    const fullPath = join(projectRoot, dir);
    if (await exists(fullPath)) {
      // Look for Button
      const buttonPath = await findComponent(fullPath, ['Button', 'button', 'Btn']);
      if (buttonPath) {
        components.button = await analyzeComponent(buttonPath);
      }

      // Look for Input
      const inputPath = await findComponent(fullPath, ['Input', 'input', 'TextField', 'TextInput']);
      if (inputPath) {
        components.input = await analyzeComponent(inputPath);
      }

      // Look for Avatar
      const avatarPath = await findComponent(fullPath, ['Avatar', 'avatar', 'UserAvatar']);
      if (avatarPath) {
        components.avatar = await analyzeComponent(avatarPath);
      }
    }
  }

  return components;
}
```

## Token Extraction

### From Tailwind Config

```typescript
function extractTailwindTokens(config: TailwindConfig): DesignTokens {
  return {
    colors: {
      primary: config.theme.colors?.primary || config.extend?.colors?.primary,
      secondary: config.theme.colors?.secondary,
      error: config.theme.colors?.error || config.theme.colors?.red,
      success: config.theme.colors?.success || config.theme.colors?.green,
      muted: config.theme.colors?.gray?.[500],
      background: config.theme.colors?.background,
      foreground: config.theme.colors?.foreground,
    },
    spacing: config.theme.spacing || {
      '1': '0.25rem',
      '2': '0.5rem',
      '3': '0.75rem',
      '4': '1rem',
      '6': '1.5rem',
      '8': '2rem',
    },
    radii: config.theme.borderRadius || {
      sm: '0.125rem',
      md: '0.375rem',
      lg: '0.5rem',
      full: '9999px',
    },
  };
}
```

### From CSS Variables

```typescript
async function extractCSSVariables(projectRoot: string): Promise<Record<string, string>> {
  const globalsCss = await readFile(join(projectRoot, 'app/globals.css'));
  const variables: Record<string, string> = {};

  // Parse :root { --name: value; } blocks
  const rootMatch = globalsCss.match(/:root\s*\{([^}]+)\}/);
  if (rootMatch) {
    const declarations = rootMatch[1];
    const varRegex = /--([\w-]+):\s*([^;]+);/g;
    let match;
    while ((match = varRegex.exec(declarations)) !== null) {
      variables[`--${match[1]}`] = match[2].trim();
    }
  }

  return variables;
}
```

## Component Pattern Matching

### Analyzing Existing Button

```typescript
interface ComponentPattern {
  path: string;
  imports: string[];
  props: string[];
  className: string;
  variants?: string[];
  styling: 'tailwind' | 'css-modules' | 'styled' | 'inline';
}

async function analyzeComponent(path: string): Promise<ComponentPattern> {
  const content = await readFile(path);

  return {
    path,
    imports: extractImports(content),
    props: extractProps(content),
    className: extractClassName(content),
    variants: extractVariants(content),
    styling: detectStyling(content),
  };
}

// Example analysis result:
{
  path: 'src/components/ui/Button.tsx',
  imports: ['react', 'clsx'],
  props: ['variant', 'size', 'children', 'onClick', 'disabled'],
  className: 'btn',
  variants: ['primary', 'secondary', 'ghost'],
  styling: 'tailwind'
}
```

### Generating Matching Components

Based on the detected Button pattern:

```typescript
function generateSendButton(buttonPattern: ComponentPattern): string {
  if (buttonPattern.variants?.includes('primary')) {
    // Use existing Button with variant
    return `
import { Button } from '${relativePath(buttonPattern.path)}';

export function SendButton({ onClick, disabled, isSending }: SendButtonProps) {
  return (
    <Button
      variant="primary"
      onClick={onClick}
      disabled={disabled || isSending}
      aria-label="Send message"
    >
      {isSending ? <SpinnerIcon /> : <SendIcon />}
    </Button>
  );
}
`;
  } else {
    // Use Button without variant, add classes
    return `
import { Button } from '${relativePath(buttonPattern.path)}';

export function SendButton({ onClick, disabled, isSending }: SendButtonProps) {
  return (
    <Button
      onClick={onClick}
      disabled={disabled || isSending}
      className="send-button"
      aria-label="Send message"
    >
      {isSending ? <SpinnerIcon /> : <SendIcon />}
    </Button>
  );
}
`;
  }
}
```

## Generation Strategies

### Strategy 1: Match Existing (Recommended)

When existing components are detected:

```typescript
// BEFORE: Generic generation
<button className="bg-blue-500 text-white px-4 py-2 rounded">
  Send
</button>

// AFTER: Using detected Button
import { Button } from '@/components/ui/Button';

<Button variant="primary">Send</Button>
```

### Strategy 2: Use Detected Tokens

When no Button exists, but tokens are detected:

```typescript
// Use Tailwind classes matching the theme
<button className="bg-primary text-primary-foreground px-4 py-2 rounded-md">
  Send
</button>
```

### Strategy 3: CSS Variables

When CSS variables are detected:

```typescript
// Use CSS variables for theming
<button className="send-button">Send</button>

// CSS
.send-button {
  background: var(--color-primary);
  color: var(--color-primary-foreground);
  padding: var(--spacing-2) var(--spacing-4);
  border-radius: var(--radius-md);
}
```

## Greenfield Apps

When no design system is detected, generate a minimal, themeable foundation:

### 1. Base UI Components

Use unstyled Base UI primitives:

```typescript
import { Button } from '@base-ui-components/react/button';

export function SendButton({ onClick, disabled }: Props) {
  return (
    <Button.Root onClick={onClick} disabled={disabled} className="send-button">
      Send
    </Button.Root>
  );
}
```

### 2. CSS Custom Properties

Provide a `chat-theme.css` with sensible defaults:

```css
/* chat-theme.css */
:root {
  /* Colors */
  --chat-bg: #ffffff;
  --chat-bg-secondary: #f9fafb;
  --chat-text: #1f2937;
  --chat-text-muted: #6b7280;
  --chat-primary: #3b82f6;
  --chat-primary-hover: #2563eb;
  --chat-error: #dc2626;
  --chat-success: #16a34a;

  /* Own message bubble */
  --chat-bubble-own-bg: #3b82f6;
  --chat-bubble-own-text: #ffffff;

  /* Other message bubble */
  --chat-bubble-other-bg: #f3f4f6;
  --chat-bubble-other-text: #1f2937;

  /* Spacing */
  --chat-spacing-1: 0.25rem;
  --chat-spacing-2: 0.5rem;
  --chat-spacing-3: 0.75rem;
  --chat-spacing-4: 1rem;
  --chat-spacing-6: 1.5rem;
  --chat-spacing-8: 2rem;

  /* Border radius */
  --chat-radius-sm: 0.25rem;
  --chat-radius-md: 0.375rem;
  --chat-radius-lg: 0.5rem;
  --chat-radius-xl: 0.75rem;
  --chat-radius-full: 9999px;

  /* Typography */
  --chat-font-sans: system-ui, -apple-system, sans-serif;
  --chat-font-size-sm: 0.875rem;
  --chat-font-size-base: 1rem;
  --chat-font-size-lg: 1.125rem;

  /* Shadows */
  --chat-shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.05);
  --chat-shadow-md: 0 4px 6px rgba(0, 0, 0, 0.1);
}

/* Dark mode defaults */
@media (prefers-color-scheme: dark) {
  :root {
    --chat-bg: #111827;
    --chat-bg-secondary: #1f2937;
    --chat-text: #f9fafb;
    --chat-text-muted: #9ca3af;
    --chat-bubble-other-bg: #374151;
    --chat-bubble-other-text: #f9fafb;
  }
}
```

### 3. Documentation

Include comments explaining customization:

```css
/*
 * XMTP Chat Theme
 *
 * To customize:
 * 1. Override variables in your app's global CSS
 * 2. Or import this file and modify values
 *
 * Example:
 * :root {
 *   --chat-primary: #8b5cf6;  // Change to purple
 * }
 */
```

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

```typescript
// If app uses @/ alias
import { Button } from '@/components/ui/Button';

// If app uses relative imports
import { Button } from '../ui/Button';

// If app uses barrel exports
import { Button } from '@/components/ui';
```
