# mw-skills — MediaWiki Shell Skills

A set of Claude Code skills for interacting with a MediaWiki instance from the command line.
Inspired by [brucekomike/mwpm](https://github.com/brucekomike/mwpm).

## Prerequisites

- `curl` — HTTP requests to the MediaWiki API
- `jq` — JSON parsing
- `bash` 4+

Install on Debian/Ubuntu:
```bash
sudo apt update && sudo apt install curl jq
```

## Setup (optional)

The skills work with no configuration: `wiki-read`, `wiki-search`, and `wiki-plan`
default to **Wikipedia** (`https://en.wikipedia.org/`). To point them at another wiki,
either export `MW_URL` for a single call, or create a config file:

```bash
cp config.sh.example config.sh
# Edit config.sh and fill in:
#   MW_URL  – e.g. https://www.mediawiki.org/
#   MW_USER – bot username from Special:BotPassword (wiki-edit only)
#   MW_PASS – bot password from Special:BotPassword (wiki-edit only)
# For multiple sites, define MW_SITE_NAME_URL/USER/PASS and select one with MW_SITE.
```

Resolution order: first found config (`$MW_SKILLS_CONFIG`, `./config.sh`,
`~/.config/mw-skills/config.sh`), then explicit environment overrides. MW_SITE
selects a named profile; the default is Wikipedia.
An explicit MW_URL always manually overrides the selected profile URL.
The bot credentials are needed solely by `wiki-edit`.
`config.sh` is git-ignored — never commit credentials.

## Skills

Each skill is a `SKILL.md` plus the shell scripts it bundles, in `.claude/skills/`.

| Skill | Bundled script | Description |
|-------|----------------|-------------|
| `wiki-read` | `scripts/wiki-read.sh <page> [limit]` | Prefix-search and read raw wikitext (default 5) |
| `wiki-search` | `scripts/wiki-search.sh <query> [limit]` | Search for pages (prints `title — snippet` per match) |
| `wiki-edit` | `scripts/wiki-edit.sh <page> <file> [summary]` | Create or update a page (reads the page before editing) |
| `wiki-plan` | `scripts/wiki-plan.sh <page> [args...]` | Follow a wiki page as a plan (worked through in plan mode) |

### Project-level

Skills live in `.claude/skills/` and are available whenever this repo is open in Claude Code.

### User-wide (after running `bash install.sh`)

`install.sh` copies the skill folders to `~/.claude/skills/`, making the same four skills
available in any project. User-wide config is stored in `~/.config/mw-skills/config.sh`.

## File Structure

| File | Purpose |
|------|---------|
| `.claude/skills/wiki-read/` | Read a page (SKILL.md + scripts/) |
| `.claude/skills/wiki-search/` | Search pages (SKILL.md + scripts/) |
| `.claude/skills/wiki-edit/` | Edit one or more pages (SKILL.md + scripts/) |
| `.claude/skills/wiki-plan/` | Follow a page as a plan (SKILL.md + scripts/) |
| `config.sh.example` | Credentials template |
| `install.sh` | Install the skills to `~/.claude/skills/` |

The shared MediaWiki API helpers live in `.claude/skills/wiki-read/scripts/lib.sh`;
the other skills source it by relative path.
