#!/usr/bin/env bash
# wiki-edit – create or update one or more wiki pages
#
# Usage (single page):
#   ./wiki-edit.sh <page-name> <content-file> [summary]
#
# Usage (batch – page list file):
#   ./wiki-edit.sh --batch <batch-file> [summary]
#
# Batch file format (one entry per line):
#   <page-name> <content-file>
#   Lines starting with # and blank lines are ignored.

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <page-name> <content-file> [summary]" >&2
  echo "       $0 --batch <batch-file> [summary]" >&2
  exit 1
fi

# Load configuration and helpers
source "$(dirname "$0")/config.sh"
source "$(dirname "$0")/lib.sh"

# Authenticate once
mw-login > /dev/null

edit_page() {
  local page="$1"
  local content_file="$2"
  local summary="${3:-$BOT_INFO}"
  if [[ ! -f "$content_file" ]]; then
    echo "Content file not found: $content_file" >&2
    return 1
  fi
  echo "+++ editing page: $page +++"
  mw-edit-page "$page" "$content_file" "$summary"
  echo
}

if [[ "$1" == "--batch" ]]; then
  BATCH_FILE="$2"
  SUMMARY="${3:-$BOT_INFO}"
  if [[ ! -f "$BATCH_FILE" ]]; then
    echo "Batch file not found: $BATCH_FILE" >&2
    exit 1
  fi
  while IFS= read -r line; do
    trimmed=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [[ -z "$trimmed" || "$trimmed" =~ ^# ]] && continue
    read -r page content_file <<< "$trimmed"
    edit_page "$page" "$content_file" "$SUMMARY"
  done < "$BATCH_FILE"
else
  PAGE="$1"
  CONTENT_FILE="$2"
  SUMMARY="${3:-$BOT_INFO}"
  edit_page "$PAGE" "$CONTENT_FILE" "$SUMMARY"
fi
