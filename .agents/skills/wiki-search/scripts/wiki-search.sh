#!/usr/bin/env bash
# wiki-search – search pages on the configured wiki
#
# Usage:
#   wiki-search.sh <query> [limit]
#
# Prints matching pages to stdout, one per line, formatted as:
#   <title> — <snippet>
# Snippets have the API's <mark> highlighting stripped.
# The optional second argument sets the maximum number of results (default 10).
# Exits 0 with a "no results" message when the query matches nothing.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <query> [limit]" >&2
  exit 1
fi

QUERY="$1"
LIMIT="${2:-10}"

# Load configuration and shared helpers
source "$(dirname "$0")/../../wiki-read/scripts/lib.sh"

# Run the search (API defaults include totalhits and snippet per srinfo/srprop)
RESULT=$(mw-search "$QUERY" "$LIMIT")

# API-level errors arrive with HTTP 200, so check for them explicitly
ERROR=$(jq -r '.error // empty' <<< "$RESULT")
if [[ -n "$ERROR" ]]; then
  jq -r '"mw-search: \(.error.code // "error") – \(.error.info // .error.code // "unknown error")"' <<< "$RESULT" >&2
  exit 1
fi

TOTAL=$(jq -r '.query.searchinfo.totalhits // 0' <<< "$RESULT")
if [[ "$TOTAL" -eq 0 ]]; then
  echo "No results for: $QUERY"
  exit 0
fi

# title — snippet (one per line)
jq -r '.query.search[]
       | (.title
          + (if (.snippet // "") != "" then " — " + (.snippet | gsub("<mark>"; "") | gsub("</mark>"; "")) else "" end))' <<< "$RESULT"
