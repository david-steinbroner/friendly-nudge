#!/bin/bash
# linear_pr.sh - Helper script for PR-based Linear workflow
# Usage: ./scripts/linear_pr.sh ISSUE_KEY SLUG
# Example: ./scripts/linear_pr.sh SKU-123 add-people-crud

set -e

if [ $# -lt 2 ]; then
    echo "Usage: $0 ISSUE_KEY SLUG"
    echo "Example: $0 SKU-123 add-people-crud"
    exit 1
fi

ISSUE_KEY="$1"
SLUG="$2"
BRANCH_NAME="${ISSUE_KEY}-${SLUG}"

echo "=== Linear PR Workflow Helper ==="
echo ""
echo "Issue:  $ISSUE_KEY"
echo "Branch: $BRANCH_NAME"
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
echo "=== Branch created successfully ==="
echo ""
echo "Next steps:"
echo ""
echo "1. Make your changes"
echo ""
echo "2. Commit with:"
echo "   git add ."
echo "   git commit -m \"feat: your description ($ISSUE_KEY)"
echo ""
echo "   Fixes $ISSUE_KEY"
echo "   \""
echo ""
echo "3. Push the branch:"
echo "   git push -u origin $BRANCH_NAME"
echo ""

# Check if gh CLI is available
if command -v gh &> /dev/null; then
    echo "4. Create PR with GitHub CLI:"
    echo "   gh pr create --title \"$ISSUE_KEY Your PR title\" --body \"Fixes $ISSUE_KEY"
    echo ""
    echo "## What changed"
    echo "<!-- Describe changes -->"
    echo ""
    echo "## Testing"
    echo "<!-- How tested -->"
    echo ""
    echo "## Notes"
    echo "<!-- Additional context -->\""
else
    echo "4. Open GitHub and create a PR from this branch into main."
    echo "   - Title: $ISSUE_KEY Your PR title"
    echo "   - Description must start with: Fixes $ISSUE_KEY"
fi

echo ""
echo "=== Done ==="
