#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -lt 3 ]; then
  echo "usage: retry.sh <attempts> <sleep_seconds> <command...>" >&2
  exit 2
fi

attempts="$1"
shift
sleep_seconds="$1"
shift

if ! [[ "$attempts" =~ ^[0-9]+$ ]] || [ "$attempts" -lt 1 ]; then
  echo "attempts must be a positive integer" >&2
  exit 2
fi

if ! [[ "$sleep_seconds" =~ ^[0-9]+$ ]] || [ "$sleep_seconds" -lt 0 ]; then
  echo "sleep_seconds must be a non-negative integer" >&2
  exit 2
fi

command=("$@")

for attempt in $(seq 1 "$attempts"); do
  echo "Attempt ${attempt}/${attempts}: ${command[*]}" >&2
  if "${command[@]}"; then
    exit 0
  fi

  if [ "$attempt" -lt "$attempts" ]; then
    sleep "$sleep_seconds"
  fi
done

exit 1
