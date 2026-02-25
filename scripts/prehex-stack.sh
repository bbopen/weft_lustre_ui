#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_ROOT="$(cd "$ROOT_DIR/.." && pwd)"
MANIFEST_PATH="$ROOT_DIR/scripts/stack-manifest.toml"
HEX_GATE_SCRIPT="$ROOT_DIR/scripts/ci/check_hex_constraints.py"

say() { printf '%s\n' "$*" >&2; }
fail() {
  say "FAIL: $*"
  exit 1
}

manifest_query() {
  local command="$1"
  shift
  python3 - "$MANIFEST_PATH" "$command" "$@" <<'PY'
import sys
from pathlib import Path

if len(sys.argv) < 3:
    raise SystemExit("manifest_query: missing command")

manifest_path = Path(sys.argv[1])
command = sys.argv[2]
args = sys.argv[3:]

if not manifest_path.exists():
    raise SystemExit(f"manifest missing: {manifest_path}")

try:
    import tomllib
except ModuleNotFoundError as error:
    raise SystemExit(f"python tomllib unavailable: {error}") from error

with manifest_path.open("rb") as manifest_file:
    manifest = tomllib.load(manifest_file)

stack = manifest.get("stack", {})
packages = manifest.get("packages", {})

if command == "list_ids":
    for package_id in stack.get("publish_order", []):
        print(package_id)
    raise SystemExit(0)

if command == "field":
    if len(args) != 2:
        raise SystemExit("field command requires <id> <field>")
    package_id, field = args
    package = packages.get(package_id)
    if package is None:
        raise SystemExit(f"unknown package id: {package_id}")
    if field not in package:
        raise SystemExit(f"missing field {field!r} for package id: {package_id}")
    print(package[field])
    raise SystemExit(0)

if command == "required_hex":
    if len(args) != 1:
        raise SystemExit("required_hex command requires <id>")
    package_id = args[0]
    package = packages.get(package_id)
    if package is None:
        raise SystemExit(f"unknown package id: {package_id}")
    for requirement in package.get("required_hex", []):
        print(requirement)
    raise SystemExit(0)

raise SystemExit(f"unsupported manifest_query command: {command}")
PY
}

list_package_ids() {
  manifest_query list_ids
}

package_field() {
  local package_id="$1"
  local field="$2"
  manifest_query field "$package_id" "$field"
}

package_required_hex() {
  local package_id="$1"
  manifest_query required_hex "$package_id"
}

read_local_package_name() {
  local gleam_toml_path="$1"
  python3 - "$gleam_toml_path" <<'PY'
import sys
from pathlib import Path

try:
    import tomllib
except ModuleNotFoundError as error:
    raise SystemExit(f"python tomllib unavailable: {error}") from error

path = Path(sys.argv[1])
if not path.exists():
    raise SystemExit("")

with path.open("rb") as file:
    manifest = tomllib.load(file)

name = manifest.get("name", "")
print(name if isinstance(name, str) else "")
PY
}

run_manifest_consistency_gate() {
  [[ -f "$MANIFEST_PATH" ]] || fail "missing manifest: $MANIFEST_PATH"
  [[ -x "$HEX_GATE_SCRIPT" ]] || fail "missing semver gate script: $HEX_GATE_SCRIPT"

  say "== manifest consistency gate =="

  local package_ids
  mapfile -t package_ids < <(list_package_ids)
  [[ "${#package_ids[@]}" -gt 0 ]] || fail "manifest publish_order is empty"

  local package_id
  for package_id in "${package_ids[@]}"; do
    local local_dir
    local_dir="$(package_field "$package_id" "local_dir")"
    local repo_name
    repo_name="$(package_field "$package_id" "repo_name")"
    local package_name
    package_name="$(package_field "$package_id" "package_name")"
    local git_url
    git_url="$(package_field "$package_id" "git_url")"

    local repo_dir="$STACK_ROOT/$local_dir"
    [[ -d "$repo_dir" ]] || fail "manifest package '$package_id' local dir missing: $repo_dir"
    [[ -f "$repo_dir/gleam.toml" ]] || fail "manifest package '$package_id' missing gleam.toml in: $repo_dir"

    local manifest_repo_suffix="${git_url##*/}"
    [[ "$manifest_repo_suffix" == "$repo_name" ]] || fail "manifest package '$package_id' git_url/repo_name mismatch: $git_url vs $repo_name"

    if ! git ls-remote --heads "$git_url" >/dev/null 2>&1; then
      fail "manifest package '$package_id' git_url is unreachable: $git_url"
    fi

    local local_package_name
    local_package_name="$(read_local_package_name "$repo_dir/gleam.toml" | head -n 1)"
    [[ -n "$local_package_name" ]] || fail "manifest package '$package_id' could not read name from $repo_dir/gleam.toml"
    [[ "$local_package_name" == "$package_name" ]] || fail "manifest package '$package_id' name mismatch: manifest=$package_name local=$local_package_name"
  done
}

run_hex_dependency_gate() {
  local package_id="$1"

  local requirements
  mapfile -t requirements < <(package_required_hex "$package_id")
  [[ "${#requirements[@]}" -gt 0 ]] || return 0

  say "== hex semver dependency gate: $package_id =="

  local cmd=(
    python3 "$HEX_GATE_SCRIPT"
  )

  local requirement
  for requirement in "${requirements[@]}"; do
    cmd+=(--require "$requirement")
  done

  local output
  local status=0
  set +e
  output="$("${cmd[@]}" 2>&1)"
  status=$?
  set -e
  say "$output"

  case "$status" in
    0) ;;
    10) fail "$package_id has missing/unsatisfied Hex dependency constraints" ;;
    20) fail "$package_id could not verify Hex dependencies due to network errors" ;;
    *) fail "$package_id semver dependency gate failed unexpectedly (status: $status)" ;;
  esac
}

run_repo_checks() {
  local package_id="$1"
  local local_dir
  local_dir="$(package_field "$package_id" "local_dir")"
  local repo_dir="$STACK_ROOT/$local_dir"

  [[ -d "$repo_dir" ]] || fail "missing repo directory: $repo_dir"
  say "== checks: $package_id ($local_dir) =="
  (cd "$repo_dir" && bash scripts/check.sh)
}

run_publish_preflight() {
  local package_id="$1"
  local local_dir
  local_dir="$(package_field "$package_id" "local_dir")"
  local repo_dir="$STACK_ROOT/$local_dir"

  [[ -d "$repo_dir" ]] || fail "missing repo directory: $repo_dir"
  say "== publish preflight: $package_id ($local_dir) =="

  local output
  local status=0
  set +e
  output="$(cd "$repo_dir" && printf 'I am not using semantic versioning\n' | env -u HEXPM_API_KEY gleam publish -y 2>&1)"
  status=$?
  set -e

  if grep -q "Unpublished dependencies" <<< "$output"; then
    say "$output"
    fail "$package_id has unpublished dependencies"
  fi

  if grep -q "https://hex.pm username" <<< "$output"; then
    say "OK: $package_id publish preflight reached Hex auth prompt"
    return
  fi

  if grep -q "HEXPM_API_KEY" <<< "$output"; then
    say "OK: $package_id publish preflight reached auth requirement"
    return
  fi

  if [[ "$status" -eq 0 ]]; then
    say "OK: $package_id publish preflight returned success"
    return
  fi

  if grep -q "Standard IO failure" <<< "$output"; then
    say "OK: $package_id publish preflight passed dependency checks (stdio in non-interactive shell)"
    return
  fi

  say "$output"
  fail "$package_id publish preflight failed"
}

run_consumer_smoke() {
  local package_id="$1"
  local mode="$2"
  local package_name
  package_name="$(package_field "$package_id" "package_name")"

  local tmp_dir
  tmp_dir="$(mktemp -d)"
  cleanup_smoke_tmp() { rm -rf "$tmp_dir"; }
  trap cleanup_smoke_tmp RETURN

  pushd "$tmp_dir" >/dev/null
  gleam new smoke_app >/dev/null 2>&1
  cd smoke_app

  local dep_line
  case "$mode" in
    git)
      local git_url
      git_url="$(package_field "$package_id" "git_url")"
      dep_line="$package_name = { git = \"$git_url\", ref = \"main\" }"
      ;;
    hex)
      local version
      version="$(package_field "$package_id" "version")"
      dep_line="$package_name = \"$version\""
      ;;
    *)
      popd >/dev/null
      fail "unknown smoke mode: $mode"
      ;;
  esac

  cat > gleam.toml <<EOF
name = "smoke_app"
version = "1.0.0"

[dependencies]
$dep_line

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"
EOF

  say "== smoke ($mode): $package_name =="
  gleam deps download
  # JavaScript-only smoke is intentional for release-speed checks.
  gleam build --target javascript

  popd >/dev/null
}

main() {
  run_manifest_consistency_gate

  local package_ids
  mapfile -t package_ids < <(list_package_ids)

  local package_id
  for package_id in "${package_ids[@]}"; do
    run_hex_dependency_gate "$package_id"
  done

  for package_id in "${package_ids[@]}"; do
    run_repo_checks "$package_id"
  done

  for package_id in "${package_ids[@]}"; do
    run_publish_preflight "$package_id"
  done

  for package_id in "${package_ids[@]}"; do
    run_consumer_smoke "$package_id" git
  done

  for package_id in "${package_ids[@]}"; do
    run_consumer_smoke "$package_id" hex
  done

  say "OK: stack prehex checks passed"
}

main "$@"
