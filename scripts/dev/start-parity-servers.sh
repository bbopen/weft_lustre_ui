#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ARTIFACT_DIR="$ROOT_DIR/examples/dashboard_benchmark/visual-artifacts"
BENCH_DIR="$ROOT_DIR/examples/dashboard_benchmark"
SHADCN_DIR="$ROOT_DIR/_refs/shadcn-ui"
BENCH_HOST="${PARITY_BENCH_HOST:-127.0.0.1}"
BENCH_PORT="${PARITY_BENCH_PORT:-4175}"
REF_HOST="${PARITY_REF_HOST:-127.0.0.1}"
REF_PORT="${PARITY_REF_PORT:-4180}"
REF_PATH="${PARITY_REF_PATH:-/dashboard}"
BENCH_PID_FILE="$ARTIFACT_DIR/server-4175.pid"
REF_PID_FILE="$ARTIFACT_DIR/server-4180.pid"
BENCH_LOG="$ARTIFACT_DIR/server-4175.log"
REF_LOG="$ARTIFACT_DIR/server-4180.log"
WAIT_LOOPS="${PARITY_WAIT_LOOPS:-300}"
SKIP_BENCH_BUILD="${PARITY_SKIP_BENCH_BUILD:-0}"

usage() {
  cat <<EOF
Usage:
  scripts/dev/start-parity-servers.sh [--skip-install]

Options:
  --skip-install     Skip shadcn dependency install/build checks.
  --help             Show this message.

Environment overrides:
  PARITY_BENCH_HOST, PARITY_BENCH_PORT
  PARITY_REF_HOST, PARITY_REF_PORT, PARITY_REF_PATH
  PARITY_SKIP_BENCH_BUILD (set to 1 to skip benchmark Gleam build)
  PARITY_WAIT_LOOPS
EOF
}

SKIP_INSTALL=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --skip-install)
      SKIP_INSTALL=1
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "error: unknown option '$1'" >&2
      usage
      exit 1
      ;;
  esac
  shift
done

mkdir -p "$ARTIFACT_DIR"

stop_from_pid_file() {
  local pid_file="$1"
  if [ ! -f "$pid_file" ]; then
    return 0
  fi

  local pid
  pid="$(cat "$pid_file" || true)"
  if [ -n "$pid" ] && kill -0 "$pid" >/dev/null 2>&1; then
    kill "$pid" >/dev/null 2>&1 || true
    sleep 0.2
  fi
  rm -f "$pid_file"
}

stop_from_pid_file "$BENCH_PID_FILE"
stop_from_pid_file "$REF_PID_FILE"

if [ "$SKIP_INSTALL" -eq 0 ]; then
  if [ ! -d "$SHADCN_DIR/node_modules" ]; then
    (cd "$SHADCN_DIR" && npx --yes pnpm@9.0.6 install --frozen-lockfile)
  fi

  if [ ! -f "$SHADCN_DIR/packages/shadcn/dist/icons/index.js" ] || [ ! -f "$SHADCN_DIR/packages/shadcn/dist/tailwind.css" ]; then
    (cd "$SHADCN_DIR" && npx --yes pnpm@9.0.6 --filter=shadcn build)
  fi
fi

if [ "$SKIP_BENCH_BUILD" -ne 1 ]; then
  (cd "$BENCH_DIR" && gleam build --target javascript)
fi

nohup python3 -m http.server "$BENCH_PORT" --bind "$BENCH_HOST" --directory "$BENCH_DIR" >"$BENCH_LOG" 2>&1 &
echo "$!" > "$BENCH_PID_FILE"

(
  cd "$SHADCN_DIR"
  NEXT_PUBLIC_APP_URL="http://${REF_HOST}:${REF_PORT}" \
    nohup npx --yes pnpm@9.0.6 --filter=v4 exec next dev --turbopack --port "$REF_PORT" >"$REF_LOG" 2>&1 &
  echo "$!" > "$REF_PID_FILE"
)

for _ in $(seq 1 "$WAIT_LOOPS"); do
  bench_ok=0
  ref_ok=0
  marker_ok=0

  if curl -sf "http://${BENCH_HOST}:${BENCH_PORT}/index.html" >/dev/null 2>&1; then
    bench_ok=1
  fi

  if curl -sf "http://${REF_HOST}:${REF_PORT}${REF_PATH}" >/tmp/parity-reference-health.html 2>/dev/null; then
    ref_ok=1
    if grep -q 'data-sidebar="sidebar"' /tmp/parity-reference-health.html && grep -q 'role="tablist"' /tmp/parity-reference-health.html; then
      marker_ok=1
    fi
  fi

  if [ "$bench_ok" -eq 1 ] && [ "$ref_ok" -eq 1 ] && [ "$marker_ok" -eq 1 ]; then
    echo "benchmark_url=http://${BENCH_HOST}:${BENCH_PORT}/index.html"
    echo "reference_url=http://${REF_HOST}:${REF_PORT}${REF_PATH}"
    echo "benchmark_pid=$(cat "$BENCH_PID_FILE")"
    echo "reference_pid=$(cat "$REF_PID_FILE")"
    rm -f /tmp/parity-reference-health.html
    exit 0
  fi

  sleep 0.2
done

echo "error: parity servers failed readiness checks." >&2
echo "benchmark log: $BENCH_LOG" >&2
echo "reference log: $REF_LOG" >&2
tail -n 30 "$BENCH_LOG" >&2 || true
tail -n 60 "$REF_LOG" >&2 || true
rm -f /tmp/parity-reference-health.html
exit 1
