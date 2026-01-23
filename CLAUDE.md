# Working on Skills

Guidelines for developing and maintaining Claude Code skills in this repository.

## Skill Architecture

Skills follow a two-layer structure:

```
skill-name/
├── SKILL.md          # Workflow document (lean, step-by-step)
└── references/       # Lookup documents (detailed, intent-based)
    ├── hooks/
    ├── components/
    ├── layouts/
    └── styling/
```

**SKILL.md** is a workflow document (how-to guide). Keep it under 500 lines. It tells Claude *when* and *in what order* to do things.

**references/** are lookup documents. They tell Claude *what* to generate and *why*, but never hardcode *how* (SDK methods change).

## The Intent-Based Reference Structure

Every reference file uses a 3-section structure:

### 1. Interface

The stable API contract that generated code exposes to the user's app. Copy this exactly.

```markdown
## Interface

```typescript
interface UseXMTPReturn {
  client: XMTPClient | null;
  initialize: (signer: Signer) => Promise<void>;
  // ...
}
```
```

### 2. Rules

Invariants that hold regardless of SDK version. Format as MUST/NEVER constraints.

```markdown
## Rules

**MUST:**
- Use dynamic import for SDK packages
- Track connection with a token to handle race conditions

**NEVER:**
- Import SDK types at the top level
- Leave stale clients open
```

### 3. Look Up

What to find from current documentation before implementing. Describe *purposes*, not method names.

```markdown
## Look Up

Before implementing, query XMTP docs for current patterns:

1. **Client creation**: How to create an XMTP client with a signer
2. **Environment config**: How to specify dev vs production network
```

**Why this structure?** The interface is stable (we define it). The rules are invariants (always true). The implementation adapts to current SDK patterns (looked up fresh each time).

## No Duplication

Information lives in exactly one place.

| Wrong | Right |
|-------|-------|
| Query instructions in Phase 0 AND a standalone section | Query instructions in Phase 0 only, remove standalone section |
| "Never use training data" repeated 4 times | Single prominent callout in Phase 0 |
| Detailed design system section in SKILL.md + reference file | Brief pointer in SKILL.md → reference file has details |

**Test:** grep for key phrases. If they appear in multiple places, consolidate.

## SKILL.md Structure

Follow the phased workflow pattern:

1. **Phase 0: Documentation Lookup** - Query current docs (mandatory before code)
2. **Phase 1: Detection** - Analyze project setup
3. **Phase 2: Interview** - Gather requirements via AskUserQuestion
4. **Phase 3: Generation** - Create files based on answers

Each phase should:
- State what happens in that phase
- Link to reference files for details (don't duplicate)
- List trigger conditions for conditional generation

## Q&A Guidelines

### Question Design

- Use AskUserQuestion with max 4 questions per call (tool silently drops extras)
- Batch questions into logical rounds
- Don't use "(Recommended)" labels - let users make informed choices
- Options should be mutually exclusive unless `multiSelect: true`

### Conditional Questions

Define trigger conditions clearly:

```markdown
**Q3b - Component library** (only if Q3="Pre-built" AND component library detected):
```

### Answer Effects

Document what each answer triggers in generation:

```markdown
| Question | Answer | Generation Effect |
|----------|--------|-------------------|
| Q1 Chat Type | `full-app` | Generate routing, navigation, responsive layouts |
| | `embedded-feature` | Self-contained components, no routing |
```

## Reference File Guidelines

### Naming

- `hooks/useXMTP.md` - Hook references (one per hook)
- `components/ChatContainer.md` - Component references
- `layouts/FullAppLayout.md` - Layout references
- `detection.md` - Detection logic (at root of references/)

### Content

- Start with a brief description of purpose
- Include the 3-section structure (Interface, Rules, Look Up)
- Keep Look Up items as purposes, not implementations
- Reference other files when needed (avoid duplication)

### Conditional References

Link from SKILL.md with trigger conditions:

```markdown
- `GroupManagement.tsx` (if Q3 = Pre-built AND Q5 = DMs + Groups) - see [references/components/GroupManagement.md]
```

## Writing Plans

Plan files in this folder follow the format: `{type}-{slug}.md`

- `feat-*` - New features
- `fix-*` - Bug fixes
- `refactor-*` - Refactoring without behavior change

### Plan Structure

```markdown
# {Type}: {Title}

## Overview
Brief description of the change.

## Problem Statement
What's wrong or missing.

## Proposed Solution
High-level approach.

## Acceptance Criteria
- [ ] Checkboxes for verification

## Technical Approach
Detailed implementation steps.

## Files to Create/Modify
Explicit list of files.

## Verification
How to test the changes work.

## Risks and Mitigations
Potential issues and how to handle them.
```

## Common Mistakes to Avoid

1. **Hardcoding XMTP SDK methods** - Reference files should say "How to create a client" not `Client.create()`. XMTP SDK methods change frequently.

   **Exception:** Domain constants (like `identifierKind: "Ethereum"`) and external library patterns (wagmi, viem) are more stable and can be included when they're the source of developer confusion.

2. **Duplicating content** - If you write the same information twice, it will diverge. Pick one location.

3. **Mixing workflow and reference** - SKILL.md says *when* and *what order*. Reference files say *what* and *why*. Keep them separate.

4. **Too many questions at once** - AskUserQuestion has a 4-question limit. Split into rounds.

5. **Missing Look Up items** - Every SDK interaction needs a Look Up item. Don't assume method names from training data.

6. **Overly detailed SKILL.md** - If a section exceeds 20 lines, extract it to a reference file and link to it.

## Testing Skills

After changes, verify:

1. **Doc lookup executes** - Phase 0 runs and finds current patterns
2. **Detection works** - Framework, wallet, styling correctly identified
3. **Questions batch correctly** - No questions silently dropped
4. **Generation matches answers** - Conditional files only generated when triggered
5. **No duplication introduced** - grep for key phrases
