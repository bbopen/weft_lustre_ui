#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

bash scripts/grep-gates.sh
gleam format --check src test
gleam build --target erlang --warnings-as-errors
gleam build --target javascript --warnings-as-errors
bash scripts/check-export-parity.sh
bash scripts/check-contracts.sh
gleam test
gleam docs build

# Auto-skip parity/visual when _refs/ is not present (e.g. CI)
if [ ! -d "$ROOT_DIR/_refs/shadcn-ui" ]; then
  WEFT_LUSTRE_UI_SKIP_PARITY="${WEFT_LUSTRE_UI_SKIP_PARITY:-1}"
  WEFT_LUSTRE_UI_SKIP_VISUAL="${WEFT_LUSTRE_UI_SKIP_VISUAL:-1}"
fi

if [ "${WEFT_LUSTRE_UI_SKIP_PARITY:-0}" != "1" ]; then
  bash scripts/dev/start-parity-servers.sh
  trap 'bash scripts/dev/stop-parity-servers.sh >/dev/null 2>&1 || true' EXIT

  bash scripts/dev/check-reference-signature.sh
  npx --yes --package=playwright@1.54.1 node scripts/dev/check-parity.mjs
fi

if [ "${WEFT_LUSTRE_UI_SKIP_VISUAL:-0}" != "1" ]; then
  if [ "${WEFT_LUSTRE_UI_SKIP_PARITY:-0}" = "1" ]; then
    bash scripts/dev/start-parity-servers.sh
    trap 'bash scripts/dev/stop-parity-servers.sh >/dev/null 2>&1 || true' EXIT
  fi

  if [ "${WEFT_LUSTRE_UI_REQUIRE_VISUAL:-0}" = "1" ]; then
    bash scripts/dev/check-visual.sh
  else
    if ! bash scripts/dev/check-visual.sh; then
      echo "WARN: reference visual check is advisory by default. Set WEFT_LUSTRE_UI_REQUIRE_VISUAL=1 to fail hard." >&2
    fi
  fi
fi

if [ "${WEFT_LUSTRE_UI_SKIP_PARITY:-0}" != "1" ] || [ "${WEFT_LUSTRE_UI_SKIP_VISUAL:-0}" != "1" ]; then
  bash scripts/dev/stop-parity-servers.sh >/dev/null 2>&1 || true
  trap - EXIT
fi
