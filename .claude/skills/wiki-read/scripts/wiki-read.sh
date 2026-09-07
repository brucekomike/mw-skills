#!/usr/bin/env bash
# wiki-read – read a specific page from the configured wiki
#
# Usage:
#   wiki-read.sh <page-name> [limit]
#
# Finds pages by title prefix, then prints the raw wikitext of each match.
# Exit 1 if no page is found or the wiki returns an error.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <page-name> [limit]" >&2
  exit 1
fi

PAGE="$1"
LIMIT="${2:-5}"
if [[ ! "$LIMIT" =~ ^[1-9][0-9]*$ ]]; then
  echo "Limit must be a positive integer: $LIMIT" >&2
  exit 1
fi

# Load configuration and helpers
source "$(dirname "$0")/lib.sh"

# Find exact pages and subpages matching the requested title prefix.
RESULT=$(mw-prefix-search "$PAGE" "$LIMIT")
ERROR=$(jq -r '.error // empty' <<< "$RESULT")
if [[ -n "$ERROR" ]]; then
  jq -r '"mw-read: \(.error.code // "error") – \(.error.info // .error.code // "unknown error")"' <<< "$RESULT" >&2
  exit 1
fi

MATCH_COUNT=$(jq '.query.prefixsearch | length' <<< "$RESULT")
if [[ "$MATCH_COUNT" -eq 0 ]]; then
  echo "Page not found: $PAGE" >&2
  exit 1
fi

PRINTED=0
while IFS= read -r title; do
  CONTENT=$(mw-read-page-source "$title")
  if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
    echo "Page is empty: $title" >&2
    continue
  fi
  if [[ "$MATCH_COUNT" -gt 1 ]]; then
    printf '=== %s ===\n' "$title"
  fi
  printf '%s\n' "$CONTENT"
  PRINTED=1
done < <(jq -r '.query.prefixsearch[].title' <<< "$RESULT")

if [[ "$PRINTED" -eq 0 ]]; then
  echo "All matching pages are empty: $PAGE" >&2
  exit 1
fi
