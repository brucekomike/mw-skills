---
name: wiki-read
description: Read the raw wikitext of a specific page from the configured MediaWiki wiki. Use when the user asks to read, view, or fetch the content of a wiki page.
---

# Read a wiki page

Run the script bundled with this skill:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-read.sh "<page-name>" [limit]
```

(`${CLAUDE_SKILL_DIR}` is the directory containing this SKILL.md. Claude Code
substitutes it automatically; in opencode, replace it with the "Base directory
for this skill" reported when this skill was loaded.)

It searches page titles by prefix, then prints the raw wikitext for each match.
Exact pages and subpages are supported. Multiple matches begin with a list of
matching page titles and are separated by page title headings. Prefix results
are queried in batches of 100; if another batch is available, the script asks
whether to continue. The limit defaults to 5 pages whose contents are read,
while the displayed matching-page list includes all discovered results. If the
page is not found or the output is empty, report the error clearly.

To expand templates and parser functions in a template or module page, run:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-parse.sh "Template:Recipe"
```

This reads the page source and uses MediaWiki's `action=expandtemplates` API,
including parser functions such as `#dpl`.

Wiki selection: no config is needed. 
Default value is configured in a `config.sh`
but to note that user may give a url in simple form even without protocol scheme.

- To query a different wiki, export `MW_URL` inline: `MW_URL="https://www.mediawiki.org/" bash ${CLAUDE_SKILL_DIR}/scripts/wiki-read.sh "<page-name>"`
- `MW_URL` is always a manual override and takes precedence over the selected site's URL.
- For multiple configured sites, set `MW_SITE=mediawiki`; profiles use `MW_SITE_MEDIAWIKI_URL`, `MW_SITE_MEDIAWIKI_USER`, and `MW_SITE_MEDIAWIKI_PASS`.
- Persistent config is selected in this order: `$MW_SKILLS_CONFIG`, then `./config.sh`, then `~/.config/mw-skills/config.sh`.
