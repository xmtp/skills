#!/bin/bash
# Setup git hooks for react-chat-builder skill
# Run once after cloning the repository

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Setting up git hooks for react-chat-builder..."

# Configure git to use .githooks directory
git config core.hooksPath .githooks

# Make hooks executable
chmod +x "$REPO_ROOT/.githooks/"*
chmod +x "$REPO_ROOT/scripts/"*.sh

echo "Done! Git hooks are now active."
echo ""
echo "The pre-commit hook will run ./scripts/check-architecture.sh"
echo "before each commit to validate architecture rules."
echo ""
echo "To disable hooks temporarily:"
echo "  git commit --no-verify"
echo ""
echo "To disable hooks permanently:"
echo "  git config --unset core.hooksPath"
