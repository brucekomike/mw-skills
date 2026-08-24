#!/usr/bin/env bash
# wiki-edit – overwrite a single wiki page from a local file
#
# Usage:
#   wiki-edit.sh <page-name> <content-file> [summary]
#
# Logs in with bot credentials, then:
#   1. fetches and prints the current page content (so you can review what
#      will be replaced); a brand-new page reports that no page was found;
#   2. overwrites the page with the file's contents.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <page-name> <content-file> [summary]" >&2
  exit 1
fi

PAGE="$1"
CONTENT_FILE="$2"
SUMMARY="${3:-$BOT_INFO}"

# Load configuration and shared helpers
source "$(dirname "$0")/../../wiki-read/scripts/lib.sh"

if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Content file not found: $CONTENT_FILE" >&2
  exit 1
fi

# Editing is the only skill that needs login (bot credentials).
mw-login > /dev/null

# Read the page before editing so the current content is visible.
echo "=== existing page: $PAGE ==="
existing=$(mw-read-page-source "$PAGE" || true)
if [[ -z "$existing" || "$existing" == "null" ]]; then
  echo "(no existing page content – will create $PAGE)"
else
  printf '%s\n' "$existing"
fi
echo

# Overwrite the page with the file's contents.
echo "=== editing page: $PAGE ==="
result=$(mw-edit-page "$PAGE" "$CONTENT_FILE" "$SUMMARY")
printf '%s\n' "$result"
if [[ "$(jq -r '.edit.result // empty' <<< "$result")" != "Success" ]]; then
  echo "Edit failed: $(jq -r '.error.info // .error.code // "unknown error"' <<< "$result")" >&2
  exit 1
fi
echo "=== done: $PAGE ==="
