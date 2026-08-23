#!/usr/bin/env bash
# wiki-read – read a specific page from the configured wiki
#
# Usage:
#   ./wiki-read.sh <page-name>
#
# Prints the raw wikitext of the requested page to stdout.
# Exit 1 if the page is not found or the wiki returns an error.

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <page-name>" >&2
  exit 1
fi

PAGE="$1"

# Load configuration and helpers
source "$(dirname "$0")/lib.sh"

# Authenticate
mw-login > /dev/null

# Fetch and print the page wikitext
CONTENT=$(mw-read-page "$PAGE")

if [[ -z "$CONTENT" || "$CONTENT" == "null" ]]; then
  echo "Page not found or empty: $PAGE" >&2
  exit 1
fi

echo "$CONTENT"
