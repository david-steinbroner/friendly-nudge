#!/bin/bash
# format.sh - Apply SwiftFormat to all Swift files
# Usage: ./scripts/format.sh
# Safe and idempotent - can be run multiple times

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

echo "=== Friendly Nudge Format ==="
echo ""

# Check for SwiftFormat
if ! command -v swiftformat &> /dev/null; then
    echo "✗ SwiftFormat not found."
    echo ""
    echo "Install with:"
    echo "  brew install swiftformat"
    echo ""
    exit 1
fi

echo ">>> Running SwiftFormat..."
swiftformat FriendlyNudge --config .swiftformat

echo ""
echo "✓ Formatting complete."
echo ""
echo "Next steps:"
echo "  1. Review changes: git diff"
echo "  2. Stage changes: git add -p"
echo "  3. Run lint to verify: ./scripts/lint.sh"
