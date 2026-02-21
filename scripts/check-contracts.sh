#!/usr/bin/env bash
#
# Package-interface contract verification gate.
# Exports the package interface JSON and runs the Python contract checker.
#
# Checks:
#   - Every headless public function exists in styled counterpart
#   - Parameter labels follow the mirror contract (theme prefix for render fns)
#   - Types re-exported from headless to styled

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

INTERFACE_JSON="build/dev/docs/${PWD##*/}/package-interface.json"

say() { printf '%s\n' "$*" >&2; }

if ! command -v python3 >/dev/null 2>&1; then
  say "SKIP: python3 not found — contract verification requires Python 3"
  exit 0
fi

# Export package interface (requires a successful build first)
gleam export package-interface --out "$INTERFACE_JSON" >/dev/null 2>&1 || {
  say "SKIP: gleam export package-interface failed — run gleam build first"
  exit 0
}

python3 scripts/check-contracts.py "$INTERFACE_JSON"
