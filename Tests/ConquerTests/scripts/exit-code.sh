#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <exit-code>" >&2
  exit 2
fi

code="$1"
# ensure numeric
if ! [[ "$code" =~ ^-?[0-9]+$ ]]; then
  echo "Error: exit code must be an integer" >&2
  exit 2
fi

exit "$code"
