# mw-skills

A set of shell skills for reading, searching, editing, and executing MediaWiki pages.
Inspired by [brucekomike/mwpm](https://github.com/brucekomike/mwpm).

## Prerequisites

```
sudo apt update && sudo apt install curl jq python3
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