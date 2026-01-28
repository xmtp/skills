# Contributing to React Chat Builder Skill

This skill uses a strict 3-layer architecture. **All changes must follow these patterns.**

## Setup

After cloning, enable the pre-commit hook:

```bash
./scripts/setup-hooks.sh
```

This runs architecture validation before every commit.

## Architecture Overview

```
SKILL.md          → Orchestrator (WHEN/WHERE)
references/       → Contracts (WHAT)
spec (generated)  → Instance (THIS integration)
```

## Layer Rules

### SKILL.md - The Orchestrator

**Owns:**
- Workflow phases (0-5)
- Interview questions (structure only)
- Phase transitions and gates
- Pointers to references

**Does NOT own:**
- Generation logic (belongs in generation-matrix.md)
- Implementation details (belongs in references)
- Code examples (belongs nowhere - look up from docs)

**Before editing SKILL.md, ask:**
- [ ] Am I adding workflow logic? ✅ OK
- [ ] Am I adding "if Q5 = X, generate Y"? ❌ Put in generation-matrix.md
- [ ] Am I adding code examples? ❌ References should have interfaces only
- [ ] Am I duplicating content from a reference? ❌ Point to it instead

### references/ - The Contracts

**Owns:**
- TypeScript interfaces (stable API contracts)
- MUST/NEVER rules (behavioral invariants)
- States (loading, error, empty)
- Look Up sections (what to query from docs)

**Does NOT own:**
- Code implementations (look up from docs at runtime)
- Conditional logic ("if Q5 = Groups...")
- File paths or generation order
- Workflow instructions

**Before editing a reference file, ask:**
- [ ] Am I defining an interface? ✅ OK
- [ ] Am I adding a MUST/NEVER rule? ✅ OK
- [ ] Am I adding code implementation? ❌ Remove it, add to "Look Up" instead
- [ ] Am I adding "if feature X enabled..."? ❌ Put condition in generation-matrix.md

### generation-matrix.md - The Decision Matrix

**Owns:**
- Interview answer → files mapping
- Conditional file generation
- Which references apply to which config
- Dependency lists per configuration

**Does NOT own:**
- How to implement anything (references own that)
- Workflow phases (SKILL.md owns that)

### spec-template.md - The Instance Template

**Owns:**
- Structure for generated specs
- Section headings and organization
- Instructions for pulling from references

**Does NOT own:**
- Actual content (pulled from references at generation time)
- Conditional logic (resolved during generation)

## Reference File Format

Every reference file MUST follow this structure:

```markdown
# [Name]

[One-sentence purpose]

## Interface

```typescript
// TypeScript interface only - NO implementation
```

## Behavior

[Declarative description of WHAT this does]

## Rules

**MUST:**
- [Required behaviors]

**NEVER:**
- [Prohibited behaviors]

## States

[If applicable: state descriptions]

## Look Up

[What to query from docs before implementing]
```

## Common Violations

### ❌ Code examples in references

```markdown
// BAD - implementation code in reference
## Implementation
```typescript
const messages = useSyncExternalStore(
  store.subscribe,
  () => store.getState().messages
);
```
```

```markdown
// GOOD - interface + look up instruction
## Interface
```typescript
interface UseMessagesReturn {
  messages: Message[];
}
```

## Look Up
- How to use useSyncExternalStore with Zustand
```

### ❌ Conditional logic in references

```markdown
// BAD - conditional in reference file
**If Q5 = Groups:**
- Generate GroupManagement.tsx
- Add member management to useConversation
```

```markdown
// GOOD - condition in generation-matrix.md only
| Q5 = dms-groups | GroupManagement.tsx | components/GroupManagement.md |
```

### ❌ Duplicating generation logic in SKILL.md

```markdown
// BAD - SKILL.md duplicating generation-matrix.md
## Answer Effects
| Q5 | dms-groups | Generate useConversation hook |
```

```markdown
// GOOD - SKILL.md points to matrix
## Generation Effects
See references/generation-matrix.md for the complete mapping.
```

### ❌ Implementation details in SKILL.md

```markdown
// BAD - implementation in SKILL.md
Use `useShallow` from zustand to prevent infinite re-renders
```

```markdown
// GOOD - behavior rule in reference, look up for implementation
// In store.md:
**MUST:** Use shallow comparison for derived selectors

## Look Up
- Zustand selector patterns for stable references
```

## Adding New Features

When adding a new feature (e.g., new message content type):

1. **Update generation-matrix.md** - Add conditional file entry
2. **Create/update reference file** - Interface + rules only
3. **Update spec-template.md** - Add section if needed
4. **Do NOT** add implementation code anywhere

## Changing Existing Features

1. **Find the single source of truth** for that information
2. **Change it in ONE place only**
3. **Verify no duplication** exists elsewhere

## Validation

Run the architecture checker manually:

```bash
./scripts/check-architecture.sh
```

This checks for:
- Conditional logic in reference files
- Implementation code in reference files
- Generation logic in SKILL.md
- Missing standard sections in reference files
- File paths in reference files

The pre-commit hook runs this automatically (if you ran `setup-hooks.sh`).

## Self-Check Before Committing

Run through this checklist:

- [ ] No code implementations in reference files (interfaces only)
- [ ] No conditional "if Q = X" logic in reference files
- [ ] No generation logic in SKILL.md (only in generation-matrix.md)
- [ ] No duplicated information across files
- [ ] Every piece of info has exactly ONE home
- [ ] Reference files follow standard format (Interface, Behavior, Rules, States, Look Up)

## Why This Matters

This architecture ensures **deterministic AI execution**. When an AI agent follows this skill:

1. It reads SKILL.md for workflow
2. It reads generation-matrix.md for what to generate
3. It reads relevant references for contracts
4. It generates spec by pulling from references
5. It codes from spec (single source of truth)

If information is scattered or duplicated, the AI must reconcile conflicts, leading to non-deterministic output.
