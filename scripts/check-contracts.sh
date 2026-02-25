#!/usr/bin/env bash
#
# Package-interface contract verification gate.
# Exports the package interface JSON and runs the Python contract checker.
#
# Checks:
#   - Every headless public function exists in styled counterpart
#   - Parameter labels follow the mirror contract (theme prefix for render fns)
#   - Return types match between headless and styled functions
#   - Parameter types match (positionally aligned, skipping the theme param)
#   - Types re-exported from headless to styled

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

INTERFACE_JSON="build/dev/docs/${PWD##*/}/package-interface.json"
ALLOW_SKIP="${WEFT_LUSTRE_UI_ALLOW_CONTRACT_SKIP:-0}"

say() { printf '%s\n' "$*" >&2; }
fail() {
  say "FAIL: $*"
  exit 1
}

if ! command -v python3 >/dev/null 2>&1; then
  if [[ "$ALLOW_SKIP" == "1" ]]; then
    say "SKIP: python3 not found — contract verification requires Python 3"
    exit 0
  fi
  fail "python3 not found — set WEFT_LUSTRE_UI_ALLOW_CONTRACT_SKIP=1 to bypass locally"
fi

# Export package interface (requires a successful build first)
gleam export package-interface --out "$INTERFACE_JSON" >/dev/null 2>&1 || {
  if [[ "$ALLOW_SKIP" == "1" ]]; then
    say "SKIP: gleam export package-interface failed — run gleam build first"
    exit 0
  fi
  fail "gleam export package-interface failed — run gleam build first (or set WEFT_LUSTRE_UI_ALLOW_CONTRACT_SKIP=1 locally)"
}

python3 scripts/check-contracts.py "$INTERFACE_JSON"
