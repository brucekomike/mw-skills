#!/usr/bin/env bash
# lib.sh – shared MediaWiki API helpers for mw-skills

# Obtain a MediaWiki API token.
# Usage: get-token <type>   (e.g. login, csrf)
function get-token() {
  local type="$1"
  local result
  result=$(curl -fsSL -X POST \
    -d action=query \
    -d meta=tokens \
    -d type="$type" \
    -d format=json \
    -c cookie.txt \
    -b cookie.txt \
    "${MW_URL}api.php")
  jq -r ".query.tokens[\"${type}token\"]" <<< "$result"
}

# Log in to the configured wiki.
# Usage: mw-login
function mw-login() {
  curl -fsSL -X POST \
    -d action=login \
    -d lgname="$MW_USER" \
    -d lgpassword="$MW_PASS" \
    --data-urlencode lgtoken="$(get-token login)" \
    -d format=json \
    -c cookie.txt \
    -b cookie.txt \
    "${MW_URL}api.php"
}

# Read the wikitext of a single page.
# Usage: mw-read-page <page-name>
function mw-read-page() {
  local page="$1"
  local result
  result=$(curl -fsSL -X GET \
    -c cookie.txt \
    -b cookie.txt \
    "${MW_URL}api.php?action=parse&page=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$page")&prop=wikitext&format=json")
  jq -r '.parse.wikitext["*"]' <<< "$result"
}

# Search wiki pages.
# Usage: mw-search <query> [limit]
function mw-search() {
  local query="$1"
  local limit="${2:-10}"
  curl -fsSL -X GET \
    -c cookie.txt \
    -b cookie.txt \
    "${MW_URL}api.php?action=query&list=search&srsearch=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$query")&srlimit=${limit}&format=json"
}

# Edit (create or update) a wiki page.
# Usage: mw-edit-page <page-name> <content> [summary]
function mw-edit-page() {
  local page="$1"
  local content="$2"
  local summary="${3:-$BOT_INFO}"
  curl -fsSL -X POST \
    -d action=edit \
    -d format=json \
    -d title="$page" \
    --data-urlencode text="$content" \
    -d summary="$summary" \
    -d bot=true \
    --data-urlencode token="$(get-token csrf)" \
    -c cookie.txt \
    -b cookie.txt \
    "${MW_URL}api.php"
}
