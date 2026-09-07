# mw-skills

A set of Claude Code skills for reading, searching, editing, and planning from MediaWiki pages.
Inspired by [brucekomike/mwpm](https://github.com/brucekomike/mwpm).

## Prerequisites

```
curl jq
```

## Skills

Each skill is a folder under `.claude/skills/` containing a `SKILL.md` and the shell
scripts it bundles.

### wiki-read

Find pages by title prefix and read their raw wikitext, including subpages
(default limit: 5).

```bash
bash .claude/skills/wiki-read/scripts/wiki-read.sh "Main Page"       # 5 matches
bash .claude/skills/wiki-read/scripts/wiki-read.sh "Mediawiki" 10    # 10 matches
```

### wiki-search

Search for pages matching a query. Prints one `title — snippet` line per match.

```bash
bash .claude/skills/wiki-search/scripts/wiki-search.sh "installation guide"       # default 10 results
bash .claude/skills/wiki-search/scripts/wiki-search.sh "installation guide" 20     # up to 20 results
```

### wiki-edit

Create or update a wiki page from a local file. The only skill that needs bot credentials.

```bash
# Single page
bash .claude/skills/wiki-edit/scripts/wiki-edit.sh "My Page" content.txt "optional edit summary"

# Batch (one "page-name content-file" pair per line)
bash .claude/skills/wiki-edit/scripts/wiki-edit.sh --batch pages.txt "batch import"
```

### wiki-plan

Fetch a wiki page containing a plan or procedure, and have Claude work through
it in plan mode — arguments after the page name are plan parameters.

> **Warning:** the page content is treated as instructions. Only follow pages
> from wikis you fully control and have reviewed.

```bash
bash .claude/skills/wiki-plan/scripts/wiki-plan.sh "Plans/deploy" arg1 arg2
```

## Setup (optional)

The skills work with no configuration: `wiki-read`, `wiki-search`, and `wiki-plan`
default to **Wikipedia** (`https://en.wikipedia.org/`). To point them at another wiki,
either export `MW_URL` for a single call, or create a config file:

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

## Claude Code

Skills are available in two scopes:

### Project-level

Open this repo in Claude Code — the four skills (`wiki-read`, `wiki-search`,
`wiki-edit`, `wiki-plan`) are available, and the skill scripts resolve `./config.sh`
in the repo root.

### User-wide (any project)

```bash
bash install.sh
# Then edit ~/.config/mw-skills/config.sh
```

The skills are copied to `~/.claude/skills/` and are available from any project.
They read their configuration from `~/.config/mw-skills/config.sh`.

## opencode

opencode uses the same `SKILL.md` format and discovers Claude-compatible skill
directories, so no separate copy is needed:

- **Project-level:** open this repo in opencode — it scans `.claude/skills/`.
- **User-wide:** after `bash install.sh`, opencode also scans `~/.claude/skills/`.

One difference: Claude Code substitutes `${CLAUDE_SKILL_DIR}` inside the skill
body, while opencode emits the body verbatim. Each SKILL.md therefore instructs
the agent to resolve it with the "Base directory for this skill" that opencode
reports when the skill is loaded.

## File structure

| File | Description |
|------|-------------|
| `.claude/skills/wiki-read/` | Read a wiki page (SKILL.md + scripts/) |
| `.claude/skills/wiki-search/` | Search wiki pages (SKILL.md + scripts/) |
| `.claude/skills/wiki-edit/` | Edit one or more wiki pages (SKILL.md + scripts/) |
| `.claude/skills/wiki-plan/` | Follow a wiki page as a plan (SKILL.md + scripts/) |
| `config.sh.example` | Template for wiki connection settings |
| `install.sh` | Install the skills to `~/.claude/skills/` |
