---
name: wiki-read
description: Read the raw wikitext of a specific page from the configured MediaWiki wiki. Use when the user asks to read, view, or fetch the content of a wiki page.
compatibility: Requires Bash, curl, jq, and network access to a MediaWiki API.
---

# Read a wiki page

Run the bundled script from this skill's directory. Resolve the directory from
the loaded `SKILL.md` path; do not assume a client-specific variable or the
current working directory:

```bash
bash <skill-directory>/scripts/wiki-read.sh "<page-name>" [limit]
```

Resolve the script path relative to the directory containing this SKILL.md
using the path information supplied by your agent runtime.

It searches page titles by prefix, then prints the raw wikitext for each match.
Exact pages and subpages are supported. Multiple matches begin with a list of
matching page titles and are separated by page title headings. Prefix results
are queried in batches of 100; if another batch is available, the script asks
whether to continue. The limit defaults to 5 pages whose contents are read,
while the displayed matching-page list includes all discovered results. If the
page is not found or the output is empty, report the error clearly.

To expand templates and parser functions in a template or module page, run:

```bash
bash <skill-directory>/scripts/wiki-parse.sh "Template:Recipe"
```

This reads the page source and uses MediaWiki's `action=expandtemplates` API,
including parser functions such as `#dpl`.

The default wiki is Wikipedia. Set `MW_URL` for a one-off target or select a
configured profile with `MW_SITE`.

- To query a different wiki, export `MW_URL` inline: `MW_URL="https://www.mediawiki.org/" bash <skill-directory>/scripts/wiki-read.sh "<page-name>"`
- `MW_URL` is always a manual override and takes precedence over the selected site's URL.
- For multiple configured sites, set `MW_SITE=mediawiki`; profiles use `MW_SITE_MEDIAWIKI_URL`, `MW_SITE_MEDIAWIKI_USER`, and `MW_SITE_MEDIAWIKI_PASS`.
- Persistent config is selected in this order: `$MW_SKILLS_CONFIG`, then `./config.sh`, then `~/.config/mw-skills/config.sh`.
