# Claude Instructions for Modifying This Skill

**Read [CONTRIBUTING.md](CONTRIBUTING.md) before making changes.**

## Quick Reference

```
SKILL.md           → Workflow phases only
generation-matrix  → Interview answers → files mapping
references/        → Interfaces + MUST/NEVER rules only
```

## Before Every Edit

1. **Where does this belong?** (See layer rules in CONTRIBUTING.md)
2. **Am I duplicating something?** (Search first, update ONE place)
3. **Am I adding code?** (Don't - add "Look Up" instructions instead)

## Self-Check

- [ ] No implementation code in reference files
- [ ] No conditional logic in reference files
- [ ] No generation logic in SKILL.md
- [ ] Reference files have: Interface, Rules, Look Up sections

## Validation

```bash
./scripts/check-architecture.sh
```
