#!/usr/bin/env bash
# wiki-plan – use a wiki page as a plan to follow
#
# Fetches the specified wiki page and prints its content so it can be
# treated as a plan. This lets you store procedures on the wiki and have
# Claude turn them into an approved plan instead of executing them raw.
#
# Usage:
#   wiki-plan.sh <page-name> [arg1 arg2 ...]
#
# The page wikitext is printed to stdout. Any arguments supplied after the
# page name are printed as plan parameters and are intended to fill in the
# page's placeholders ($1, $2, …).

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <page-name> [args...]" >&2
  exit 1
fi

PAGE="$1"
shift

# Load configuration and shared helpers (also sets up the cookie-jar trap).
source "$(dirname "$0")/../../wiki-read/scripts/lib.sh"

# Fetch the page content
CONTENT=$(mw-read-page "$PAGE")

if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
  echo "Page not found or empty: $PAGE" >&2
  exit 1
fi

echo "=== wiki plan: $PAGE ===" >&2
if [[ $# -gt 0 ]]; then
  echo "=== parameters: $* ===" >&2
fi
printf '%s\n' "$CONTENT"
