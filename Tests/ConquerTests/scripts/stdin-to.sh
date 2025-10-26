#!/usr/bin/env bash
set -euo pipefail

# Usage: stdin-to.sh [stdout|stderr]
# Reads from stdin and writes to the chosen stream (default: stdout)

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [stdout|stderr]" >&2
  exit 2
fi

stream="${1:-stdout}"
case "$stream" in
  stdout)
    cat
    ;;
  stderr)
    cat >&2
    ;;
  *)
    echo "Usage: $0 [stdout|stderr]" >&2
    exit 2
    ;;
 esac
