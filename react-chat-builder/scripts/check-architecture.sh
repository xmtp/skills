#!/bin/bash
# Architecture validation for react-chat-builder skill
# Run from skill root: ./scripts/check-architecture.sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "Checking react-chat-builder skill architecture..."
echo ""

# Check 1: No conditional logic in reference files (except generation-matrix.md)
echo "Checking for conditional logic in references..."
for file in references/*.md references/**/*.md; do
    if [[ "$file" == *"generation-matrix.md"* ]] || [[ "$file" == *"spec-template.md"* ]]; then
        continue
    fi
    if [ -f "$file" ]; then
        if grep -qiE "(if Q[0-9]|when .* enabled|if .* selected|when groups)" "$file" 2>/dev/null; then
            echo -e "${RED}ERROR:${NC} Conditional logic found in $file"
            echo "       Move to generation-matrix.md"
            ERRORS=$((ERRORS + 1))
        fi
    fi
done

# Check 2: No implementation code blocks in reference files
echo "Checking for implementation code in references..."
for file in references/hooks/*.md references/store.md references/xmtp-streaming.md references/XMTPProvider.md; do
    if [ -f "$file" ]; then
        # Look for actual implementation patterns inside code blocks
        # Check for function bodies with React hooks or async patterns
        if awk '/^```(typescript|tsx|ts)/,/^```/' "$file" 2>/dev/null | grep -qE "(useState\(|useEffect\(|useCallback\(|= await |\.then\(|try \{)" 2>/dev/null; then
            echo -e "${YELLOW}WARNING:${NC} Possible implementation code in $file"
            echo "         Reference files should have interfaces only"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Check 3: SKILL.md should not have "Answer Effects" table
echo "Checking SKILL.md for generation logic..."
if grep -q "Answer Effects" SKILL.md 2>/dev/null; then
    echo -e "${RED}ERROR:${NC} 'Answer Effects' found in SKILL.md"
    echo "       This belongs in generation-matrix.md"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: Check that generation-matrix.md exists and has content
echo "Checking generation-matrix.md exists..."
if [ ! -f "references/generation-matrix.md" ]; then
    echo -e "${RED}ERROR:${NC} references/generation-matrix.md not found"
    ERRORS=$((ERRORS + 1))
elif ! grep -q "Base Files" "references/generation-matrix.md" 2>/dev/null; then
    echo -e "${RED}ERROR:${NC} generation-matrix.md missing expected sections"
    ERRORS=$((ERRORS + 1))
fi

# Check 5: Reference files should have standard sections
echo "Checking reference file format..."

# Check hooks - need Interface, Rules, Look Up
for file in references/hooks/*.md; do
    if [ -f "$file" ]; then
        missing=""
        grep -q "## Interface" "$file" || missing="$missing Interface"
        grep -q "## Rules" "$file" || missing="$missing Rules"
        grep -q "## Look Up" "$file" || missing="$missing 'Look Up'"

        if [ -n "$missing" ]; then
            echo -e "${YELLOW}WARNING:${NC} $file missing sections:$missing"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Check components - need Interface and Rules (Look Up optional)
for file in references/components/*.md; do
    if [ -f "$file" ]; then
        missing=""
        grep -q "## Interface" "$file" || missing="$missing Interface"
        grep -qE "## (Rules|UX Rules)" "$file" || missing="$missing Rules"

        if [ -n "$missing" ]; then
            echo -e "${YELLOW}WARNING:${NC} $file missing sections:$missing"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Check 6: No file paths in reference files (except generation-matrix.md)
echo "Checking for file paths in references..."
for file in references/hooks/*.md references/components/*.md; do
    if [ -f "$file" ]; then
        # Look for patterns like "src/hooks/" or "components/chat/"
        if grep -qE "(src/|components/|hooks/|stores/|lib/)[a-zA-Z]+\.(ts|tsx)" "$file" 2>/dev/null; then
            echo -e "${YELLOW}WARNING:${NC} File paths found in $file"
            echo "         File paths belong in generation-matrix.md or spec"
            WARNINGS=$((WARNINGS + 1))
        fi
    fi
done

# Check 7: Bridge documents exist
echo "Checking bridge documents exist..."
for doc in "references/error-handling.md" "references/hook-coordination.md" "references/identity-resolution.md"; do
    if [ ! -f "$doc" ]; then
        echo -e "${RED}ERROR:${NC} Missing bridge document: $doc"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check 8: SKILL.md should not have generation tables (file generation logic)
echo "Checking SKILL.md for inline generation tables..."
# Look for patterns that indicate file generation logic (not doc lookups)
# Generation tables typically have: "Generate", "Create", ".tsx", ".ts", "component"
if grep -E "^\| Q[0-9]" SKILL.md 2>/dev/null | grep -qiE "(generate|create.*file|\.tsx|\.ts[^a-z]|component)" 2>/dev/null; then
    echo -e "${YELLOW}WARNING:${NC} SKILL.md may contain file generation tables"
    echo "         Generation logic belongs in generation-matrix.md"
    WARNINGS=$((WARNINGS + 1))
fi

# Summary
echo ""
echo "================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
else
    if [ $ERRORS -gt 0 ]; then
        echo -e "${RED}Errors: $ERRORS${NC}"
    fi
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
    fi
fi
echo "================================"

exit $ERRORS
