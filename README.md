# mw-skills

A cross-agent set of Agent Skills for reading, searching, browsing categories,
editing, and planning from MediaWiki pages.
Inspired by [brucekomike/mwpm](https://github.com/brucekomike/mwpm).

## Prerequisites

```
curl jq
```

## Skills

Each skill is a folder under `.agents/skills/` containing a standard `SKILL.md` and the shell
scripts it bundles.

### wiki-read

Find pages by title prefix and read their raw wikitext, including subpages.
Prefix results are fetched in batches of 100; the optional limit controls the
number of page contents read (default: 5), while the matching-page list is
complete for the batches you approve.

```bash
bash .agents/skills/wiki-read/scripts/wiki-read.sh "Main Page"       # 5 matches
bash .agents/skills/wiki-read/scripts/wiki-read.sh "Mediawiki" 10    # 10 matches
```

Expand a template or module page through MediaWiki's parser:

```bash
bash .agents/skills/wiki-read/scripts/wiki-parse.sh "Template:Recipe"
```

### wiki-search

Search for pages matching a query. Prints one `title — snippet` line per match.

```bash
bash .agents/skills/wiki-search/scripts/wiki-search.sh "installation guide"       # default 10 results
bash .agents/skills/wiki-search/scripts/wiki-search.sh "installation guide" 20     # up to 20 results
```

### wiki-category

List pages in a category, list subcategories, find pages in multiple
categories, or search category names. Prints one title per line.

```bash
bash .agents/skills/wiki-category/scripts/wiki-category.sh "Linux"              # pages in Category:Linux
bash .agents/skills/wiki-category/scripts/wiki-category.sh "Linux" --subcategories
bash .agents/skills/wiki-category/scripts/wiki-category.sh "Linux" --in "Debian"
bash .agents/skills/wiki-category/scripts/wiki-category.sh --search "Linux"     # search category names
```

### wiki-edit

Create or replace one wiki page from a local file. The only skill that needs bot credentials.

```bash
# Single page
bash .agents/skills/wiki-edit/scripts/wiki-edit.sh "My Page" content.txt "optional edit summary"

```

### wiki-plan

Fetch a wiki page containing a plan or procedure, and have Claude work through
it in plan mode — arguments after the page name are plan parameters.

> **Warning:** the page content is treated as instructions. Only follow pages
> from wikis you fully control and have reviewed.

```bash
bash .agents/skills/wiki-plan/scripts/wiki-plan.sh "Plans/deploy" arg1 arg2
```

## Setup (optional)

The skills work with no configuration: `wiki-read`, `wiki-search`, `wiki-category`,
and `wiki-plan` default to **Wikipedia** (`https://en.wikipedia.org/`). To point them
at another wiki, either export `MW_URL` for a single call, or create a config file:

```bash
cp config.sh.example config.sh
# Edit config.sh and fill in MW_URL.
# For wiki-edit, also fill in MW_USER and MW_PASS from Special:BotPassword.
# Multiple sites can use MW_SITE_NAME_URL/USER/PASS profiles and MW_SITE=name.
```

Resolution order: first found config (`$MW_SKILLS_CONFIG`, `./config.sh`,
`~/.config/mw-skills/config.sh`), then explicit environment overrides. `MW_SITE`
selects a named profile; `MW_URL`/`MW_USER`/`MW_PASS` override it. Each site has
its own cookie jar.

### BotPassword handling

`wiki-read`, `wiki-search`, `wiki-category`, and `wiki-plan` need only a wiki
URL. `wiki-edit` uses a dedicated MediaWiki BotPassword. Keep it in the ignored
`config.sh` or a secret manager, restrict it to the rights the bot needs, and
never commit or upload that file with a toolkit. The installer creates the
user config with mode `600`.

For a remote agent sandbox, prefer a small authenticated MCP gateway that keeps
the BotPassword on the host and exposes only the wiki operations the agent
needs. Do not copy the BotPassword into the sandbox environment or prompt.

## Agent Skills compatibility

The canonical skills are in `.agents/skills/`, following the open Agent Skills
directory layout. Qwen Code, OpenCode, and other compatible clients can load
those skills directly. Claude Code currently discovers `.claude/skills/`; this
repository keeps `.claude/skills` as a symlink to the canonical `.agents/skills`
directory.

### Project-level use

Open this repository in an Agent Skills-compatible client. Project config is
read from `./config.sh` when commands run from the repo root, or use
`MW_SKILLS_CONFIG` to select a private config file explicitly.

### User-wide use

```bash
bash install.sh
# Then edit ~/.config/mw-skills/config.sh
```

The installer copies canonical skills to `~/.agents/skills/` for shared clients
and links Claude Code's `~/.claude/skills/` entries to those copies. Credentials
remain separate in `~/.config/mw-skills/config.sh`.

## File structure

| File | Description |
|------|-------------|
| `.agents/skills/wiki-read/` | Read a wiki page (SKILL.md + scripts/) |
| `.agents/skills/wiki-search/` | Search wiki pages (SKILL.md + scripts/) |
| `.agents/skills/wiki-category/` | Browse and search categories (SKILL.md + scripts/) |
| `.agents/skills/wiki-edit/` | Edit one or more wiki pages (SKILL.md + scripts/) |
| `.agents/skills/wiki-plan/` | Follow an approved wiki procedure (SKILL.md + scripts/) |
| `.claude/skills` | Claude Code compatibility symlink to `.agents/skills` |
| `config.sh.example` | Template for wiki connection settings |
| `install.sh` | Install shared skills and Claude compatibility links |
