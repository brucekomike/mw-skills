#!/usr/bin/env bash
# lib.sh – shared MediaWiki API helpers for mw-skills

# Wiki selection (no config file required): config is loaded first, then
# explicit environment values override it. MW_SITE selects named profiles such
# as MW_SITE_WIKI_URL, MW_SITE_WIKI_USER, and MW_SITE_WIKI_PASS.
# MW_USER/MW_PASS (BotPassword) are needed solely by mw-login (wiki-edit).
_MW_ENV_URL="${MW_URL:-}"
_MW_ENV_USER="${MW_USER:-}"
_MW_ENV_PASS="${MW_PASS:-}"
_MW_ENV_SITE="${MW_SITE:-}"
_MW_ENV_PROXY="${MW_PROXY:-}"
_MW_ENV_BOT_INFO="${BOT_INFO:-}"
_MW_ENV_COOKIE_JAR="${MW_COOKIE_JAR:-}"
_MW_ENV_COOKIE_DIR="${MW_SKILLS_COOKIE_DIR:-}"
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

MW_SITE="${_MW_ENV_SITE:-${MW_SITE:-default}}"
if [[ ! "$MW_SITE" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
  echo "mw-skills: invalid MW_SITE: $MW_SITE" >&2
  return 1 2>/dev/null || exit 1
fi
_MW_SITE_KEY="${MW_SITE^^}"
if [[ "$_MW_SITE_KEY" != "DEFAULT" ]]; then
  _MW_PROFILE_URL="$(eval "printf '%s' \"\${MW_SITE_${_MW_SITE_KEY}_URL:-}\"")"
  _MW_PROFILE_USER="$(eval "printf '%s' \"\${MW_SITE_${_MW_SITE_KEY}_USER:-}\"")"
  _MW_PROFILE_PASS="$(eval "printf '%s' \"\${MW_SITE_${_MW_SITE_KEY}_PASS:-}\"")"
  if [[ -z "$_MW_PROFILE_URL" && -z "$_MW_ENV_URL" ]]; then
    echo "mw-skills: unknown site profile: $MW_SITE" >&2
    return 1 2>/dev/null || exit 1
  fi
  if [[ -n "$_MW_PROFILE_URL" ]]; then
    MW_URL="$_MW_PROFILE_URL"
    MW_USER="$_MW_PROFILE_USER"
    MW_PASS="$_MW_PROFILE_PASS"
  fi
fi
MW_URL="${_MW_ENV_URL:-${MW_URL:-https://en.wikipedia.org/w/}}"
MW_USER="${_MW_ENV_USER:-${MW_USER:-}}"
MW_PASS="${_MW_ENV_PASS:-${MW_PASS:-}}"
MW_PROXY="${_MW_ENV_PROXY:-${MW_PROXY:-}}"
BOT_INFO="${BOT_INFO:-mw-skills}"
if [[ -n "$_MW_ENV_BOT_INFO" ]]; then
  BOT_INFO="$_MW_ENV_BOT_INFO"
fi

# Common curl flags. The API can be slow on some networks; an optional proxy
# can be set via MW_PROXY (e.g. MW_PROXY="http://127.0.0.1:7890").
_MW_CURL=(curl -fsSL --max-time 30)
if [[ -n "${MW_PROXY:-}" ]]; then
  _MW_CURL+=(-x "$MW_PROXY")
fi

# Persistent cookie jar so a login session is reused across runs instead of
# logging in every time. Default site: ~/.config/mw-skills/cookies.txt;
# named sites use ~/.config/mw-skills/cookies-<site>.txt.
# Override with $MW_COOKIE_JAR (full path) or $MW_SKILLS_COOKIE_DIR (dir).
if [[ -z "${_MW_COOKIE_JAR:-}" ]]; then
  if [[ -n "$_MW_ENV_COOKIE_JAR" ]]; then
    _MW_COOKIE_JAR="$_MW_ENV_COOKIE_JAR"
  else
    _MW_COOKIE_DIR="${_MW_ENV_COOKIE_DIR:-${MW_SKILLS_COOKIE_DIR:-${HOME}/.config/mw-skills}}"
    if [[ "$_MW_SITE_KEY" == "DEFAULT" ]]; then
      _MW_COOKIE_JAR="${_MW_COOKIE_DIR}/cookies.txt"
    else
      _MW_COOKIE_JAR="${_MW_COOKIE_DIR}/cookies-${_MW_SITE_KEY}.txt"
    fi
  fi
  mkdir -p "$(dirname "$_MW_COOKIE_JAR")"
  if [[ -f "$_MW_COOKIE_JAR" ]]; then
    chmod 600 "$_MW_COOKIE_JAR"
  fi
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

# Find pages whose titles start with a prefix.
# Usage: mw-prefix-search <prefix> [limit]
function mw-prefix-search() {
  local prefix="$1"
  local limit="${2:-10}"
  "${_MW_CURL[@]}" -G \
    --data-urlencode "pssearch=$prefix" \
    -d action=query \
    -d list=prefixsearch \
    -d pslimit="$limit" \
    -d format=json \
    -c "$_MW_COOKIE_JAR" \
    -b "$_MW_COOKIE_JAR" \
    "${MW_URL}api.php"
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
