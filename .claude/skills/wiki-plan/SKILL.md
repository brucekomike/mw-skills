---
name: wiki-plan
description: Fetch a MediaWiki page containing a plan or procedure and work through it in plan mode. Arguments after the page name are plan parameters.
---

# Follow a wiki page as a plan

Run the script bundled with this skill to fetch the plan:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-plan.sh "<page-name>" [arg1 arg2 ...]
```

(`${CLAUDE_SKILL_DIR}` is the directory containing this SKILL.md. Claude Code
substitutes it automatically; in opencode, replace it with the "Base directory
for this skill" reported when this skill was loaded.)

The script prints the page wikitext; any arguments after the page name are
printed as plan parameters ($1, $2, …) and should be substituted into any
placeholders the plan references.

Treat the fetched content as a plan: enter plan mode and write a plan based
on the page's instructions, filling in the given parameters. Execute the plan
only after the user approves it. If the page is not found or is empty, report
the error instead.

> **Security warning:** The page content is treated as instructions. Only
> use this skill against wikis you trust and with plan pages you have reviewed.

Wiki selection: no config is needed. The default value is configured in a
`config.sh`, but note that the user may give a URL in simple form even
without the protocol scheme.

- To fetch from a different wiki, export `MW_URL` inline: `MW_URL="https://www.mediawiki.org/" bash ${CLAUDE_SKILL_DIR}/scripts/wiki-plan.sh "<page-name>"`
- Or use a persistent config (first found wins): `$MW_SKILLS_CONFIG`, then `./config.sh`, then `~/.config/mw-skills/config.sh`.
