#!/bin/bash
# lint.sh - Run SwiftFormat (check mode) + SwiftLint
# Usage: ./scripts/lint.sh
# Exit codes: 0 = pass, non-zero = issues found

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

echo "=== Friendly Nudge Lint Check ==="
echo ""

# Check for SwiftFormat
if command -v swiftformat &> /dev/null; then
    echo ">>> Running SwiftFormat (check mode)..."
    if swiftformat --lint FriendlyNudge --config .swiftformat; then
        echo "✓ SwiftFormat: OK"
    else
        echo "✗ SwiftFormat: Issues found. Run ./scripts/format.sh to fix."
        exit 1
    fi
else
    echo "⚠ SwiftFormat not found. Install with: brew install swiftformat"
    echo "  Skipping SwiftFormat check."
fi

echo ""

# Check for SwiftLint
if command -v swiftlint &> /dev/null; then
    echo ">>> Running SwiftLint..."
    if swiftlint lint --config .swiftlint.yml --strict; then
        echo "✓ SwiftLint: OK"
    else
        echo "✗ SwiftLint: Issues found."
        exit 1
    fi
else
    echo "⚠ SwiftLint not found. Install with: brew install swiftlint"
    echo "  Skipping SwiftLint check."
fi

echo ""
echo "=== Lint Check Complete ==="
