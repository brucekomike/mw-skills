#!/usr/bin/env bash
# lib.sh – shared MediaWiki API helpers for mw-skills

# Wiki selection (no config file required):
#   1. MW_URL in the environment wins — no config file is read if it is set.
#   2. Otherwise source the first config found: $MW_SKILLS_CONFIG,
#      then ./config.sh, then ~/.config/mw-skills/config.sh.
#   3. If none of those exist, default to Wikipedia.
# MW_USER/MW_PASS (BotPassword) are needed solely by mw-login (wiki-edit).
if [[ -z "${MW_URL:-}" ]]; then
  _MW_CONFIG="${MW_SKILLS_CONFIG:-}"
  if [[ -z "$_MW_CONFIG" ]]; then
    for _candidate in "${PWD}/config.sh" "${HOME}/.config/mw-skills/config.sh"; do
      if [[ -f "$_candidate" ]]; then
        _MW_CONFIG="$_candidate"
        break
      fi
    done
  fi
  if [[ -n "$_MW_CONFIG" && -f "$_MW_CONFIG" ]]; then
    # shellcheck source=/dev/null
    source "$_MW_CONFIG"
  fi
fi
MW_URL="${MW_URL:-https://en.wikipedia.org/w/}"
MW_USER="${MW_USER:-}"
MW_PASS="${MW_PASS:-}"
BOT_INFO="${BOT_INFO:-mw-skills}"

# Common curl flags. The API can be slow on some networks; an optional proxy
# can be set via MW_PROXY (e.g. MW_PROXY="http://127.0.0.1:7890").
_MW_CURL=(curl -fsSL --max-time 30)
if [[ -n "${MW_PROXY:-}" ]]; then
  _MW_CURL+=(-x "$MW_PROXY")
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
  result=$("${_MW_CURL[@]}" -X POST \
    -d action=query \
    -d meta=tokens \
    -d type="$type" \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php")
  jq -r ".query.tokens[\"${type}token\"]" <<< "$result"
}

# Log in to the configured wiki. Only needed for editing (bot writes).
# Usage: mw-login
# Returns 1 with a clear message on failure
# (wrong credentials come back as HTTP 200, so the JSON must be checked).
function mw-login() {
  local result
  result=$("${_MW_CURL[@]}" -X POST \
    -d action=login \
    --data-urlencode lgname="$MW_USER" \
    --data-urlencode lgpassword="$MW_PASS" \
    --data-urlencode lgtoken="$(get-token login)" \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php")
  if [[ "$(jq -r '.login.result // empty' <<< "$result")" != "Success" ]]; then
    echo "mw-login: login failed: $(jq -r '.login.errorinfo // .login.error // "unknown error"' <<< "$result")" >&2
    return 1
  fi
  echo "$result"
}

# Read the wikitext of a single page.
# Usage: mw-read-page-source <page-name>
function mw-read-page-source() {
  local page="$1"
  local result
  result=$("${_MW_CURL[@]}" -G \
    --data-urlencode "page=$page" \
    -d action=parse \
    -d prop=wikitext \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php")
  jq -r '.parse.wikitext["*"]' <<< "$result"
}

# Read a page's wikitext extract, keeping wikitext section headings
# (redirects are resolved; templates render to their link text).
# Usage: mw-read-page <page-name>
function mw-read-page() {
  local page="$1"
  local result
  result=$("${_MW_CURL[@]}" -G \
    --data-urlencode "titles=$page" \
    -d action=query \
    -d prop=extracts \
    -d explaintext \
    -d exsectionformat=wiki \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php")
  jq -r '.query.pages[].extract' <<< "$result"
}

# Search wiki pages.
# API defaults already include totalhits (srinfo) and snippet (srprop).
# Usage: mw-search <query> [limit]
function mw-search() {
  local query="$1"
  local limit="${2:-10}"
  "${_MW_CURL[@]}" -G \
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
  "${_MW_CURL[@]}" -X POST \
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
