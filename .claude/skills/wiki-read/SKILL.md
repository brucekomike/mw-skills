---
name: wiki-read
description: Read the raw wikitext of a specific page from the configured MediaWiki wiki. Use when the user asks to read, view, or fetch the content of a wiki page.
---

# Read a wiki page

Run the script bundled with this skill:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-read.sh "<page-name>"
```

(`${CLAUDE_SKILL_DIR}` is the directory containing this SKILL.md. Claude Code
substitutes it automatically; in opencode, replace it with the "Base directory
for this skill" reported when this skill was loaded.)

It prints the page's raw wikitext. Show it to the user. If the page is not found or the output is empty, report the error clearly.

Wiki selection: no config is needed. 
Default value is configured in a `config.sh`
but to note that user may give a url in simple form even without protocol scheme.

- To query a different wiki, export `MW_URL` inline: `MW_URL="https://www.mediawiki.org/" bash ${CLAUDE_SKILL_DIR}/scripts/wiki-read.sh "<page-name>"`
- Or use a persistent config (first found wins): `$MW_SKILLS_CONFIG`, then `./config.sh`, then `~/.config/mw-skills/config.sh`.
