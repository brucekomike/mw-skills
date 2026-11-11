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

# Find exact pages and subpages matching the requested title prefix. Search in
# batches of 100; LIMIT controls how many page contents are read.
SEARCH_LIMIT=100
TITLES=()
OFFSET=""
while :; do
  RESULT=$(mw-prefix-search "$PAGE" "$SEARCH_LIMIT" "$OFFSET")
  ERROR=$(jq -r '.error // empty' <<< "$RESULT")
  if [[ -n "$ERROR" ]]; then
    jq -r '"mw-read: \(.error.code // "error") – \(.error.info // .error.code // "unknown error")"' <<< "$RESULT" >&2
    exit 1
  fi

  while IFS= read -r title; do
    TITLES+=("$title")
  done < <(jq -r '.query.prefixsearch[].title' <<< "$RESULT")

  NEXT_OFFSET=$(jq -r '.continue.psoffset // empty' <<< "$RESULT")
  if [[ -z "$NEXT_OFFSET" ]]; then
    break
  fi
  printf 'More matching pages are available (offset %s). Continue? [y/N] ' "$NEXT_OFFSET" >&2
  if [[ ! -t 0 || ! -t 1 ]]; then
    printf '\n' >&2
    break
  fi
  read -r ANSWER
  if [[ ! "$ANSWER" =~ ^[Yy]([Ee][Ss])?$ ]]; then
    break
  fi
  OFFSET="$NEXT_OFFSET"
done

MATCH_COUNT="${#TITLES[@]}"
if [[ "$MATCH_COUNT" -eq 0 ]]; then
  echo "Page not found: $PAGE" >&2
  exit 1
fi

if [[ "$MATCH_COUNT" -gt 1 ]]; then
  READ_COUNT="$LIMIT"
  if [[ "$READ_COUNT" -gt "$MATCH_COUNT" ]]; then
    READ_COUNT="$MATCH_COUNT"
  fi
  printf '=== matching pages (%s found; reading %s) ===\n' "$MATCH_COUNT" "$READ_COUNT"
  printf -- '- %s\n' "${TITLES[@]}"
  printf '\n'
fi

PRINTED=0
for title in "${TITLES[@]:0:$LIMIT}"; do
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
done

if [[ "$PRINTED" -eq 0 ]]; then
  echo "All matching pages are empty: $PAGE" >&2
  exit 1
fi
