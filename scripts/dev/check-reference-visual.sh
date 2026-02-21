#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BENCHMARK_URL="${BENCHMARK_URL:-http://127.0.0.1:4175/index.html}"
REFERENCE_URL="${REFERENCE_URL:-http://127.0.0.1:4180/dashboard}"
MAX_DIFF_RATIO="${REFERENCE_VISUAL_MAX_DIFF_RATIO:-0.02}"
DIFF_METRIC="${REFERENCE_VISUAL_DIFF_METRIC:-MAE}"
ARTIFACT_DIR="${REFERENCE_VISUAL_ARTIFACT_DIR:-$ROOT_DIR/examples/dashboard_benchmark/visual-artifacts/reference-diff}"

usage() {
  cat <<EOF
Usage:
  scripts/dev/check-reference-visual.sh [options]

Options:
  --benchmark-url <url>    Benchmark URL (default: ${BENCHMARK_URL})
  --reference-url <url>    Reference URL (default: ${REFERENCE_URL})
  --max-diff-ratio <num>   Max allowed diff ratio in [0,1] (default: ${MAX_DIFF_RATIO})
  --metric <name>          ImageMagick metric: AE|MAE|RMSE|DSSIM (default: ${DIFF_METRIC})
  --artifact-dir <dir>     Output directory for benchmark/reference/diff screenshots
  --help                   Show this message
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --benchmark-url)
      BENCHMARK_URL="$2"
      shift
      ;;
    --reference-url)
      REFERENCE_URL="$2"
      shift
      ;;
    --max-diff-ratio)
      MAX_DIFF_RATIO="$2"
      shift
      ;;
    --metric)
      DIFF_METRIC="$2"
      shift
      ;;
    --artifact-dir)
      ARTIFACT_DIR="$2"
      shift
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

if [ "${WEFT_LUSTRE_UI_SKIP_BROWSER_INSTALL:-0}" != "1" ]; then
  if [ "${CI:-}" = "true" ] || [ "${CI:-}" = "1" ]; then
    npx --yes playwright@1.54.1 install --with-deps chromium
  else
    npx --yes playwright@1.54.1 install chromium
  fi
fi

if ! curl -sf "$BENCHMARK_URL" >/dev/null 2>&1; then
  echo "error: benchmark URL is not reachable: $BENCHMARK_URL" >&2
  exit 1
fi

if ! curl -sf "$REFERENCE_URL" >/dev/null 2>&1; then
  echo "error: reference URL is not reachable: $REFERENCE_URL" >&2
  exit 1
fi

REFERENCE_VISUAL_ARTIFACT_DIR="$ARTIFACT_DIR" \
REFERENCE_VISUAL_MAX_DIFF_RATIO="$MAX_DIFF_RATIO" \
REFERENCE_VISUAL_DIFF_METRIC="$DIFF_METRIC" \
BENCHMARK_URL="$BENCHMARK_URL" \
REFERENCE_URL="$REFERENCE_URL" \
npx --yes \
  --package=playwright@1.54.1 \
  node "$ROOT_DIR/scripts/dev/reference-visual-diff.mjs"
