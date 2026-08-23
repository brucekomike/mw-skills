# mw-skills

A set of shell skills for reading, searching, editing, and executing MediaWiki pages.
Inspired by [brucekomike/mwpm](https://github.com/brucekomike/mwpm).

## Prerequisites

```
sudo apt update && sudo apt install curl jq
```

## Setup

```bash
cp config.sh.example config.sh
# Edit config.sh and fill in MW_URL, MW_USER, MW_PASS
```

Obtain bot credentials from `Special:BotPassword` on your wiki.

## Skills

### wiki-read

Read the wikitext of a specific page from the configured wiki.

```bash
./wiki-read.sh "Main Page"
```

### wiki-search

Search for pages matching a query.

```bash
./wiki-search.sh "installation guide"       # default 10 results
./wiki-search.sh "installation guide" 20    # up to 20 results
```

### wiki-edit

Create or update a wiki page from a local file.

```bash
# Single page
./wiki-edit.sh "My Page" content.txt "optional edit summary"

# Batch (one "page-name content-file" pair per line)
./wiki-edit.sh --batch pages.txt "batch import"
```

### wiki-exec

Fetch a wiki page and execute its content as a shell script.

> **Warning:** only run pages from wikis you fully control and have reviewed.

```bash
./wiki-exec.sh "Scripts/deploy" arg1 arg2
```

## File structure

| File | Description |
|------|-------------|
| `config.sh.example` | Template for wiki connection settings |
| `lib.sh` | Shared MediaWiki API helper functions |
| `wiki-read.sh` | Read a wiki page |
| `wiki-search.sh` | Search wiki pages |
| `wiki-edit.sh` | Edit one or more wiki pages |
| `wiki-exec.sh` | Execute a wiki page as a shell script |

## Claude Code

This repo is formatted as a Claude Code skill set. There are two ways to use it.

### Project-level (per-repo)

Open the repo directory in Claude Code. The slash commands are available immediately as:

| Command | Example |
|---------|---------|
| `/project:wiki-read` | `/project:wiki-read "Main Page"` |
| `/project:wiki-search` | `/project:wiki-search "deployment guide" 20` |
| `/project:wiki-edit` | `/project:wiki-edit "My Page" content.txt "initial import"` |
| `/project:wiki-exec` | `/project:wiki-exec "Scripts/deploy" arg1 arg2` |

### User-wide (any project)

Run the install script once to copy the skills to `~/.local/share/mw-skills/` and register them as global Claude Code commands:

```bash
bash install.sh
# Then edit ~/.config/mw-skills/config.sh with your wiki credentials
```

The following commands will then be available in Claude Code from **any** project:

| Command | Example |
|---------|---------|
| `/user:mw-read` | `/user:mw-read "Main Page"` |
| `/user:mw-search` | `/user:mw-search "deployment guide" 20` |
| `/user:mw-edit` | `/user:mw-edit "My Page" content.txt "initial import"` |
| `/user:mw-exec` | `/user:mw-exec "Scripts/deploy" arg1 arg2` |