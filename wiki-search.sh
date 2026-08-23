#!/usr/bin/env bash
# wiki-search – search pages on the configured wiki
#
# Usage:
#   ./wiki-search.sh <query> [limit]
#
# Prints matching page titles (one per line) to stdout.
# The optional second argument sets the maximum number of results (default 10).

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <query> [limit]" >&2
  exit 1
fi

QUERY="$1"
LIMIT="${2:-10}"

# Load configuration and helpers
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib.sh"

# Authenticate
mw-login > /dev/null

# Run the search and print titles
RESULT=$(mw-search "$QUERY" "$LIMIT")

echo "$RESULT" | jq -r '.query.search[] | .title'
