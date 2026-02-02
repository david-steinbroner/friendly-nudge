#!/bin/bash
# fn_pr.sh - Helper script for PR-based Linear workflow
# Usage: ./scripts/fn_pr.sh SKU-123 "short-slug" "PR title here"
#
# This script is SAFE by default:
# - It creates a branch but does NOT auto-commit or auto-push
# - It prints commands for you to run manually

set -e

if [ $# -lt 3 ]; then
    echo "Usage: $0 ISSUE_KEY SLUG \"PR title\""
    echo "Example: $0 SKU-123 add-people-crud \"SKU-123 Add people list CRUD\""
    exit 1
fi

ISSUE_KEY="$1"
SLUG="$2"
PR_TITLE="$3"
BRANCH_NAME="${ISSUE_KEY}-${SLUG}"

echo "=== Friendly Nudge PR Workflow Helper ==="
echo ""
echo "Issue:  $ISSUE_KEY"
echo "Branch: $BRANCH_NAME"
echo "Title:  $PR_TITLE"
echo ""

# Step 1: Checkout main and pull
echo ">>> Checking out main and pulling latest..."
git checkout main
git pull

# Step 2: Create branch
echo ""
echo ">>> Creating branch: $BRANCH_NAME"
git checkout -b "$BRANCH_NAME"

echo ""
echo "============================================"
echo "Branch created. Next steps (run manually):"
echo "============================================"
echo ""
echo "1. Make your changes"
echo ""
echo "2. Stage and commit:"
echo "   git add ."
echo "   git commit -m 'feat: your description ($ISSUE_KEY)"
echo ""
echo "   Fixes $ISSUE_KEY"
echo "   '"
echo ""
echo "3. Push the branch:"
echo "   git push -u origin $BRANCH_NAME"
echo ""
echo "4. Create PR with GitHub CLI:"
echo ""
cat << EOF
   gh pr create \\
     --title "$PR_TITLE" \\
     --body "Fixes $ISSUE_KEY

## What changed
<!-- Describe changes -->

## Testing
<!-- How tested -->

## Notes
<!-- Additional context -->" \\
     --base main
EOF

echo ""
echo "============================================"
echo "Done. Branch is ready for your changes."
echo "============================================"
