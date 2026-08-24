#!/usr/bin/env bash
# wiki-edit – overwrite a single wiki page from a local file
#
# Usage:
#   wiki-edit.sh <page-name> <content-file> [summary]
#
# Uses a persistent cookie (default ~/.config/mw-skills/cookies.txt), so a
# previous login is reused and you only log in when the session is missing or
# stale. Before editing, the current page content is printed so you can review
# what will be replaced (a brand-new page reports that none was found), then the
# page is overwritten with the file's contents.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <page-name> <content-file> [summary]" >&2
  exit 1
fi

PAGE="$1"
CONTENT_FILE="$2"
SUMMARY="${3:-$BOT_INFO}"

# Load configuration and shared helpers (sets up the persistent cookie jar)
source "$(dirname "$0")/../../wiki-read/scripts/lib.sh"

if [[ ! -f "$CONTENT_FILE" ]]; then
  echo "Content file not found: $CONTENT_FILE" >&2
  exit 1
fi

# Read the page before editing so the current content is visible.
echo "=== existing page: $PAGE ==="
existing=$(mw-read-page-source "$PAGE" || true)
if [[ -z "$existing" || "$existing" == "null" ]]; then
  echo "(no existing page content – will create $PAGE)"
else
  printf '%s\n' "$existing"
fi
echo

# Overwrite the page. Reuse the persistent login session; if the edit is
# rejected (no/stale session), log in once and retry.
echo "=== editing page: $PAGE ==="
result=$(mw-edit-page "$PAGE" "$CONTENT_FILE" "$SUMMARY")
if [[ "$(jq -r '.edit.result // empty' <<< "$result")" != "Success" ]]; then
  mw-login > /dev/null
  result=$(mw-edit-page "$PAGE" "$CONTENT_FILE" "$SUMMARY")
fi
printf '%s\n' "$result"
if [[ "$(jq -r '.edit.result // empty' <<< "$result")" != "Success" ]]; then
  echo "Edit failed: $(jq -r '.error.info // .error.code // "unknown error"' <<< "$result")" >&2
  exit 1
fi
echo "=== done: $PAGE ==="
