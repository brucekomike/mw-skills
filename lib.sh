#!/usr/bin/env bash
# lib.sh – shared MediaWiki API helpers for mw-skills

# Load configuration.
# Honour MW_SKILLS_CONFIG env var for user-wide installs; otherwise fall back
# to config.sh in the same directory as lib.sh itself.
if [[ -z "${MW_URL:-}" ]]; then
  _MW_CONFIG="${MW_SKILLS_CONFIG:-$(dirname "${BASH_SOURCE[0]}")/config.sh}"
  if [[ ! -f "$_MW_CONFIG" ]]; then
    echo "Config not found: $_MW_CONFIG" >&2
    echo "Copy config.sh.example to config.sh (or set MW_SKILLS_CONFIG) and fill in credentials." >&2
    exit 1
  fi
  # shellcheck source=/dev/null
  source "$_MW_CONFIG"
fi

# Private cookie jar created once per session with restricted permissions.
# Each script that sources lib.sh gets its own jar in /tmp.
if [[ -z "${_MW_COOKIE_JAR:-}" ]]; then
  _MW_COOKIE_JAR=$(mktemp /tmp/mw-skills-cookies-XXXXXX)
  chmod 600 "$_MW_COOKIE_JAR"
  trap 'rm -f "$_MW_COOKIE_JAR"' EXIT
fi

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
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php")
  jq -r ".query.tokens[\"${type}token\"]" <<< "$result"
}

# Log in to the configured wiki.
# Usage: mw-login
function mw-login() {
  curl -fsSL -X POST \
    -d action=login \
    --data-urlencode lgname="$MW_USER" \
    --data-urlencode lgpassword="$MW_PASS" \
    --data-urlencode lgtoken="$(get-token login)" \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php"
}

# Read the wikitext of a single page.
# Usage: mw-read-page <page-name>
function mw-read-page() {
  local page="$1"
  local result
  result=$(curl -fsSL -G \
    --data-urlencode "page=$page" \
    -d action=parse \
    -d prop=wikitext \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php")
  jq -r '.parse.wikitext["*"]' <<< "$result"
}

# Search wiki pages.
# Usage: mw-search <query> [limit]
function mw-search() {
  local query="$1"
  local limit="${2:-10}"
  curl -fsSL -G \
    --data-urlencode "srsearch=$query" \
    -d action=query \
    -d list=search \
    -d srlimit="$limit" \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php"
}

# Edit (create or update) a wiki page from a file.
# Usage: mw-edit-page <page-name> <content-file> [summary]
function mw-edit-page() {
  local page="$1"
  local content_file="$2"
  local summary="${3:-$BOT_INFO}"
  curl -fsSL -X POST \
    -d action=edit \
    -d format=json \
    --data-urlencode title="$page" \
    --data-urlencode text@"$content_file" \
    --data-urlencode summary="$summary" \
    -d bot=true \
    --data-urlencode token="$(get-token csrf)" \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php"
}
