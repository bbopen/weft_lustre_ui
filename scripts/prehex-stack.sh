#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACK_ROOT="$(cd "$ROOT_DIR/.." && pwd)"

say() { printf '%s\n' "$*" >&2; }
fail() {
  say "FAIL: $*"
  exit 1
}

REPOS=(weft weft_lustre weft_chart weft_lustre_ui gleam_contracts)

package_name_for_repo() {
  case "$1" in
    weft) printf 'weft' ;;
    weft_lustre) printf 'weft_lustre' ;;
    weft_chart) printf 'weft_chart' ;;
    weft_lustre_ui) printf 'weft_lustre_ui' ;;
    gleam_contracts) printf 'module_contracts' ;;
    *) fail "unknown repo: $1" ;;
  esac
}

git_url_for_repo() {
  case "$1" in
    weft) printf 'https://github.com/bbopen/weft' ;;
    weft_lustre) printf 'https://github.com/bbopen/weft_lustre' ;;
    weft_chart) printf 'https://github.com/bbopen/weft_chart' ;;
    weft_lustre_ui) printf 'https://github.com/bbopen/weft_lustre_ui' ;;
    gleam_contracts) printf 'https://github.com/bbopen/module_contracts' ;;
    *) fail "unknown repo: $1" ;;
  esac
}

version_for_repo() {
  case "$1" in
    weft) printf '>= 0.1.0 and < 1.0.0' ;;
    weft_lustre) printf '>= 0.1.0 and < 1.0.0' ;;
    weft_chart) printf '>= 0.2.0 and < 1.0.0' ;;
    weft_lustre_ui) printf '>= 0.1.0 and < 1.0.0' ;;
    gleam_contracts) printf '>= 0.1.0 and < 1.0.0' ;;
    *) fail "unknown repo: $1" ;;
  esac
}

required_hex_dependencies_for_repo() {
  case "$1" in
    weft) ;;
    weft_lustre)
      printf '%s\n' \
        'weft|>= 0.1.0 and < 1.0.0' \
        'plinth|>= 0.9.0 and < 1.0.0'
      ;;
    weft_chart)
      printf '%s\n' \
        'weft|>= 0.1.0 and < 1.0.0'
      ;;
    weft_lustre_ui)
      printf '%s\n' \
        'weft|>= 0.1.0 and < 1.0.0' \
        'weft_lustre|>= 0.1.0 and < 1.0.0'
      ;;
    gleam_contracts) ;;
    *) fail "unknown repo: $1" ;;
  esac
}

hex_package_status() {
  local package="$1"
  curl -sS --max-time 15 --retry 2 \
    -o /dev/null \
    -w '%{http_code}' \
    "https://hex.pm/api/packages/$package" || true
}

run_hex_dependency_gate() {
  local repo="$1"
  local requirements
  requirements="$(required_hex_dependencies_for_repo "$repo")"

  [[ -n "$requirements" ]] || return 0

  say "== hex dependency gate: $repo =="

  while IFS='|' read -r package constraint; do
    [[ -n "$package" ]] || continue
    local status
    status="$(hex_package_status "$package")"
    case "$status" in
      200)
        say "OK: found Hex package '$package' for constraint '$constraint'"
        ;;
      404)
        fail "$repo requires Hex dependency '$package ($constraint)' but package is not published yet"
        ;;
      000)
        fail "$repo could not verify Hex dependency '$package ($constraint)' due to network/timeout"
        ;;
      *)
        fail "$repo could not verify Hex dependency '$package ($constraint)' (unexpected status: $status)"
        ;;
    esac
  done <<< "$requirements"
}

run_repo_checks() {
  local repo="$1"
  local repo_dir="$STACK_ROOT/$repo"
  [[ -d "$repo_dir" ]] || fail "missing repo directory: $repo_dir"
  say "== checks: $repo =="
  (cd "$repo_dir" && bash scripts/check.sh)
}

run_publish_preflight() {
  local repo="$1"
  local repo_dir="$STACK_ROOT/$repo"
  [[ -d "$repo_dir" ]] || fail "missing repo directory: $repo_dir"

  say "== publish preflight: $repo =="

  local output
  local status=0
  set +e
  output="$(cd "$repo_dir" && printf 'I am not using semantic versioning\n' | env -u HEXPM_API_KEY gleam publish -y 2>&1)"
  status=$?
  set -e

  if grep -q "Unpublished dependencies" <<< "$output"; then
    say "$output"
    fail "$repo has unpublished dependencies"
  fi

  if grep -q "https://hex.pm username" <<< "$output"; then
    say "OK: $repo publish preflight reached Hex auth prompt"
    return
  fi

  if grep -q "HEXPM_API_KEY" <<< "$output"; then
    say "OK: $repo publish preflight reached auth requirement"
    return
  fi

  if [[ "$status" -eq 0 ]]; then
    say "OK: $repo publish preflight returned success"
    return
  fi

  # In CI/non-interactive contexts, Gleam can fail with stdio errors after
  # passing dependency checks. Treat this as non-fatal preflight success.
  if grep -q "Standard IO failure" <<< "$output"; then
    say "OK: $repo publish preflight passed dependency checks (stdio in non-interactive shell)"
    return
  fi

  say "$output"
  fail "$repo publish preflight failed"
}

run_consumer_smoke() {
  local repo="$1"
  local mode="$2"
  local package_name
  package_name="$(package_name_for_repo "$repo")"

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
      dep_line="$package_name = { git = \"$(git_url_for_repo "$repo")\", ref = \"main\" }"
      ;;
    hex)
      dep_line="$package_name = \"$(version_for_repo "$repo")\""
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
  for repo in "${REPOS[@]}"; do
    run_hex_dependency_gate "$repo"
  done

  for repo in "${REPOS[@]}"; do
    run_repo_checks "$repo"
  done

  for repo in "${REPOS[@]}"; do
    run_publish_preflight "$repo"
  done

  for repo in "${REPOS[@]}"; do
    run_consumer_smoke "$repo" git
  done

  for repo in "${REPOS[@]}"; do
    run_consumer_smoke "$repo" hex
  done

  say "OK: stack prehex checks passed"
}

main "$@"
