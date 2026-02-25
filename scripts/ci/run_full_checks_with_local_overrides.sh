#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

say() { printf '%s\n' "$*" >&2; }
fail() {
  say "FAIL: $*"
  exit 1
}

[[ -d "../weft" ]] || fail "required sibling repo missing: ../weft"
[[ -d "../weft_lustre" ]] || fail "required sibling repo missing: ../weft_lustre"

backup_file="$(mktemp)"
cp gleam.toml "$backup_file"
restore() {
  cp "$backup_file" gleam.toml
  rm -f "$backup_file"
}
trap restore EXIT

python3 - "gleam.toml" <<'PY'
import re
import sys
from pathlib import Path

file_path = Path(sys.argv[1])
text = file_path.read_text()

replacements = {
    "weft": 'weft = { path = "../weft" }',
    "weft_lustre": 'weft_lustre = { path = "../weft_lustre" }',
}

for dep_name, replacement in replacements.items():
    pattern = rf"^{dep_name}\s*=\s*.*$"
    if not re.search(pattern, text, flags=re.MULTILINE):
        raise SystemExit(f"missing dependency line for {dep_name}")
    text = re.sub(pattern, replacement, text, flags=re.MULTILINE)

file_path.write_text(text)
PY

say "CI mode: local dependency overrides (weft + weft_lustre paths)"
bash scripts/check.sh
