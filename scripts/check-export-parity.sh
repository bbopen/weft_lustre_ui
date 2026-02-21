#!/usr/bin/env bash
#
# Erlang shell gate: verify styled modules export all non-@internal
# headless function names. Uses compiled .beam module_info directly.
#
# Runs after `gleam build --target erlang` and before `gleam test`.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EBIN_DIR="$ROOT_DIR/build/dev/erlang/weft_lustre_ui/ebin"
SRC_DIR="$ROOT_DIR/src/weft_lustre_ui"

say() { printf '%s\n' "$*" >&2; }

if [[ ! -d "$EBIN_DIR" ]]; then
  say "SKIP: ebin not found — run gleam build first"
  exit 0
fi

fail=0

for headless_file in "$SRC_DIR"/headless/*.gleam; do
  [[ -f "$headless_file" ]] || continue
  component="$(basename "$headless_file" .gleam)"

  styled_file="$SRC_DIR/${component}.gleam"
  if [[ ! -f "$styled_file" ]]; then
    continue  # file parity gate handles missing files
  fi

  headless_beam="weft_lustre_ui@headless@${component}"
  styled_beam="weft_lustre_ui@${component}"

  if [[ ! -f "$EBIN_DIR/${headless_beam}.beam" ]] || [[ ! -f "$EBIN_DIR/${styled_beam}.beam" ]]; then
    continue  # not compiled yet
  fi

  # Collect @internal function names from headless source.
  # Pattern: @internal on its own line, followed by pub fn <name>
  internal_fns="$(awk '
    /^@internal[[:space:]]*$/ { want = 1; next }
    want && /^pub fn [a-z_]/ {
      sub(/^pub fn /, "")
      sub(/\(.*/, "")
      print
      want = 0
      next
    }
    { want = 0 }
  ' "$headless_file")"

  # Get exported function names from both beams
  headless_exports="$(erl -noshell -pa "$EBIN_DIR" -eval "
    Exports = ${headless_beam}:module_info(exports),
    [io:format(\"~s~n\", [atom_to_list(F)]) || {F,_} <- Exports, F =/= module_info],
    halt(0).
  " 2>/dev/null | sort -u)"

  styled_exports="$(erl -noshell -pa "$EBIN_DIR" -eval "
    Exports = ${styled_beam}:module_info(exports),
    [io:format(\"~s~n\", [atom_to_list(F)]) || {F,_} <- Exports, F =/= module_info],
    halt(0).
  " 2>/dev/null | sort -u)"

  while IFS= read -r fn; do
    [[ -z "$fn" ]] && continue

    # Skip @internal functions
    skip=0
    while IFS= read -r ifn; do
      [[ -z "$ifn" ]] && continue
      if [[ "$fn" == "$ifn" ]]; then
        skip=1
        break
      fi
    done <<< "$internal_fns"
    [[ "$skip" -eq 1 ]] && continue

    # Verify styled module exports this function
    if ! echo "$styled_exports" | grep -qx "$fn"; then
      say "EXPORT: weft_lustre_ui/$component missing '$fn' from headless/$component"
      fail=1
    fi
  done <<< "$headless_exports"
done

if [[ "$fail" -eq 1 ]]; then
  say ""
  say "FAIL: export parity gate failed"
  exit 1
fi

say "OK: export parity passed"
