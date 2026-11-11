#!/usr/bin/env bash
# wiki-category – list pages or subcategories in a MediaWiki category
#
# Usage:
#   wiki-category.sh <category> [limit]                     # pages in a category (default 100)
#   wiki-category.sh <category> --subcategories [limit]     # subcategories of a category
#   wiki-category.sh <category> --in <category2>            # pages in BOTH categories
#   wiki-category.sh --search <term> [limit]                # search category titles
#
# Prints one title per line, with the "Category:" prefix stripped.
# Exits 0 with a "No results..." message when nothing matches, 1 on error.
# Category names may be given with or without the "Category:" prefix.

set -euo pipefail

usage() {
  echo "Usage: $0 <category> [limit]" >&2
  echo "       $0 <category> --subcategories [limit]" >&2
  echo "       $0 <category> --in <category2>" >&2
  echo "       $0 --search <term> [limit]" >&2
  exit 1
}

die() {
  echo "wiki-category: $1" >&2
  exit 1
}

MODE="pages"             # pages | subcategories | search
CATEGORY=""
CATEGORY2=""

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --in)
      [[ $# -ge 2 ]] || usage
      CATEGORY2="$2"; shift 2 ;;
    --subcategories)
      MODE="subcategories"; shift ;;
    --search)
      MODE="search"; shift ;;
    -*)
      usage ;;
    *)
      POSITIONAL+=("$1"); shift ;;
  esac
done

if [[ "$MODE" == "search" ]]; then
  [[ ${#POSITIONAL[@]} -ge 1 ]] || usage
  QUERY="${POSITIONAL[0]}"
  LIMIT="${POSITIONAL[1]:-10}"
else
  [[ ${#POSITIONAL[@]} -ge 1 ]] || usage
  CATEGORY="${POSITIONAL[0]}"
  LIMIT="${POSITIONAL[1]:-100}"
fi

# Load configuration and shared helpers
source "$(dirname "$0")/../../wiki-read/scripts/lib.sh"

# Print an API-level error (arrives with HTTP 200) and exit 1
fail_on_error() {
  local error
  error=$(jq -r '.error // empty' <<< "$1")
  if [[ -n "$error" ]]; then
    jq -r '"wiki-category: \(.error.code // "error") – \(.error.info // .error.code // "unknown error")"' <<< "$1" >&2
    exit 1
  fi
}

strip_prefix() {
  printf '%s\n' "$1" | sed 's|^Category:||'
}

# --- Search mode: search category titles ---
if [[ "$MODE" == "search" ]]; then
  RESULT=$(mw-search-categories "$QUERY" "$LIMIT")
  fail_on_error "$RESULT"
  TOTAL=$(jq '.query.search | length' <<< "$RESULT")
  if [[ "$TOTAL" -eq 0 ]]; then
    echo "No categories found for: $QUERY"
    exit 0
  fi
  jq -r '.query.search[].title' <<< "$RESULT" | while IFS= read -r title; do
    strip_prefix "$title"
  done
  exit 0
fi

# --- Intersection mode: pages in both $CATEGORY and $CATEGORY2 ---
if [[ -n "$CATEGORY2" ]]; then
  RESULT_A=$(mw-category "$CATEGORY" 500 pages)
  fail_on_error "$RESULT_A"
  RESULT_B=$(mw-category "$CATEGORY2" 500 pages)
  fail_on_error "$RESULT_B"
  TITLES=$(jq -nr \
    --argjson a "$RESULT_A" \
    --argjson b "$RESULT_B" \
    '[ $b.query.categorymembers[]?.title ] as $tb |
     $a.query.categorymembers[]?.title | select($tb | index(.))')
  if [[ -z "$TITLES" ]]; then
    echo "No pages in both $CATEGORY and $CATEGORY2"
    exit 0
  fi
  printf '%s\n' "$TITLES" | while IFS= read -r title; do
    strip_prefix "$title"
  done
  exit 0
fi

# --- Default: list members (pages or subcategories) ---
RESULT=$(mw-category "$CATEGORY" "$LIMIT" "$MODE")
fail_on_error "$RESULT"
TOTAL=$(jq '.query.categorymembers | length' <<< "$RESULT")
if [[ "$TOTAL" -eq 0 ]]; then
  echo "No results for category: $CATEGORY"
  exit 0
fi
jq -r '.query.categorymembers[].title' <<< "$RESULT" | while IFS= read -r title; do
  strip_prefix "$title"
done
