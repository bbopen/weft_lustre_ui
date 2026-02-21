#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
BENCHMARK_URL="${BENCHMARK_URL:-http://127.0.0.1:4175/index.html}"
REFERENCE_URL="${REFERENCE_URL:-http://127.0.0.1:4180/dashboard}"
MAX_DIFF_RATIO="${REFERENCE_VISUAL_MAX_DIFF_RATIO:-0.02}"
DIFF_METRIC="${REFERENCE_VISUAL_DIFF_METRIC:-MAE}"
ARTIFACT_DIR="${REFERENCE_VISUAL_ARTIFACT_DIR:-$ROOT_DIR/examples/dashboard_benchmark/visual-artifacts/reference-diff}"
HOST="127.0.0.1"
PORT="4175"

usage() {
  cat <<EOF2
Usage:
  scripts/dev/check-visual.sh [options]

Options:
  --benchmark-url <url>    Benchmark URL (default: ${BENCHMARK_URL})
  --reference-url <url>    Reference URL (default: ${REFERENCE_URL})
  --max-diff-ratio <num>   Max allowed diff ratio in [0,1] (default: ${MAX_DIFF_RATIO})
  --metric <name>          ImageMagick metric: AE|MAE|RMSE|DSSIM (default: ${DIFF_METRIC})
  --artifact-dir <dir>     Output directory for screenshots + diff artifacts
  --host <host>            Convenience: sets benchmark URL host (default: 127.0.0.1)
  --port <port>            Convenience: sets benchmark URL port (default: 4175)
  --update-baseline        Deprecated (ignored; baseline mode removed)
  --skip-build             Deprecated (ignored; parity server handles build)
  --help                   Show this message
EOF2
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
    --host)
      HOST="$2"
      BENCHMARK_URL="http://${HOST}:${PORT}/index.html"
      shift
      ;;
    --port)
      PORT="$2"
      BENCHMARK_URL="http://${HOST}:${PORT}/index.html"
      shift
      ;;
    --update-baseline|--skip-build)
      echo "warn: '$1' is deprecated and ignored by reference visual mode" >&2
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

exec bash "$ROOT_DIR/scripts/dev/check-reference-visual.sh" \
  --benchmark-url "$BENCHMARK_URL" \
  --reference-url "$REFERENCE_URL" \
  --max-diff-ratio "$MAX_DIFF_RATIO" \
  --metric "$DIFF_METRIC" \
  --artifact-dir "$ARTIFACT_DIR"
