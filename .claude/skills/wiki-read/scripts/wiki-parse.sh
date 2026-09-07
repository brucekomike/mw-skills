#!/usr/bin/env bash
# wiki-parse - expand templates and parser functions from a wiki page
#
# Usage:
#   wiki-parse.sh <page-name>
#
# Reads the page's raw wikitext, sends it through MediaWiki's
# action=expandtemplates API, and prints the expanded wikitext. This is useful
# for inspecting Template: and Module: pages or pages containing DPL queries.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <page-name>" >&2
  exit 1
fi

PAGE="$1"

# Load configuration and shared helpers.
source "$(dirname "$0")/lib.sh"

CONTENT=$(mw-read-page-source "$PAGE")
if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
  echo "Page not found or empty: $PAGE" >&2
  exit 1
fi

RESULT=$(mw-expand-wikitext "$CONTENT")
if [[ -z "$RESULT" || "$RESULT" == "null" ]]; then
  echo "Could not parse page: $PAGE" >&2
  exit 1
fi

printf '%s\n' "$RESULT"
