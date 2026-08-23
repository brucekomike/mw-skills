#!/usr/bin/env bash
# wiki-exec – use a wiki page as execution context
#
# Fetches the specified wiki page and evaluates its content as a shell script.
# This lets you store runnable procedures on the wiki and execute them on demand.
#
# Usage:
#   ./wiki-exec.sh <page-name> [arg1 arg2 ...]
#
# The page wikitext is expected to contain a shell script.  Any arguments
# supplied after the page name are passed to that script as positional
# parameters ($1, $2, …).
#
# WARNING: Never run untrusted wiki content with this skill.  Only use it
#          against wikis you control and with pages you have reviewed.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <page-name> [args...]" >&2
  exit 1
fi

PAGE="$1"
shift   # remaining positional params are passed to the page script

# Load configuration and helpers
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib.sh"

# Authenticate
mw-login > /dev/null

# Fetch the page content
CONTENT=$(mw-read-page "$PAGE")

if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
  echo "Page not found or empty: $PAGE" >&2
  exit 1
fi

# Write content to a temp file and execute it
TMPFILE=$(mktemp /tmp/wiki-exec-XXXXXX.sh)
trap 'rm -f "$TMPFILE"' EXIT

printf '%s\n' "$CONTENT" > "$TMPFILE"
chmod 700 "$TMPFILE"

echo "=== executing wiki page: $PAGE ===" >&2
bash "$TMPFILE" "$@"
