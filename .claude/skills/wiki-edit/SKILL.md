---
name: wiki-edit
description: Create or update a MediaWiki page from a local file, or batch-edit multiple pages. This skill logs in with bot credentials.
---

# Edit wiki pages

Run the script bundled with this skill:

```bash
# Single page
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-edit.sh "<page-name>" <content-file> [summary]

# Batch (file with one "page-name content-file" per line)
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-edit.sh --batch <batch-file> [summary]
```

This is the only skill that requires bot credentials (`MW_USER`/`MW_PASS` from the wiki's Special:BotPassword); the others work with just `MW_URL`. If login fails, report the error — it usually means missing or wrong credentials.

Configuration: the script looks for a config in this order — `$MW_SKILLS_CONFIG`, then `./config.sh`, then `~/.config/mw-skills/config.sh`.
