# mw-skills — MediaWiki Shell Skills

A set of shell skills for interacting with a MediaWiki instance from the command line.
Inspired by [brucekomike/mwpm](https://github.com/brucekomike/mwpm).

## Prerequisites

- `curl` — HTTP requests to the MediaWiki API
- `jq` — JSON parsing
- `bash` 4+

Install on Debian/Ubuntu:
```bash
sudo apt update && sudo apt install curl jq
```

## Setup (required before using any skill)

```bash
cp config.sh.example config.sh
# Edit config.sh and fill in:
#   MW_URL  – e.g. https://wiki.example.com/
#   MW_USER – bot username from Special:BotPassword
#   MW_PASS – bot password from Special:BotPassword
```

`config.sh` is git-ignored — never commit credentials.

## Available Slash Commands

| Command | Description |
|---------|-------------|
| `/project:wiki-read <page>` | Read raw wikitext of a page |
| `/project:wiki-search <query> [limit]` | Search for pages |
| `/project:wiki-edit <page> <file> [summary]` | Create or update a page |
| `/project:wiki-exec <page> [args...]` | Execute a wiki page as a shell script |

## File Structure

| File | Purpose |
|------|---------|
| `config.sh.example` | Credentials template |
| `lib.sh` | Shared MediaWiki API helpers |
| `wiki-read.sh` | Read a page |
| `wiki-search.sh` | Search pages |
| `wiki-edit.sh` | Edit one or more pages |
| `wiki-exec.sh` | Execute a page as a shell script |
