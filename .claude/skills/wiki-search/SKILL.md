---
name: wiki-search
description: Search for pages on a MediaWiki wiki (default Wikipedia, or MW_URL / configured wiki) using local curl against the MediaWiki API (no server-side WebSearch/WebFetch). Use when the user asks to search the wiki, look up a page/article on that wiki, or find pages matching a query.
---

# Search the wiki

Run the script bundled with this skill:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-search.sh "<query>" [limit]
```

Limit defaults to 10. Output is one line per match: `title — snippet`.

Typical workflow:

1. Search with the user's query.
2. Pick the best-matching `title` from the results.
3. Read it with the wiki-read skill.
4. When reporting results, include the page link: `<MW_URL>wiki/<urlencoded title>` (adjust if the site uses a non-default article path).

Notes:

- Search results with an empty snippet are still valid matches — pull the page to see its content.
- Titles may be non-ASCII (e.g. Chinese); the script URL-encodes everything, so pass them through as-is.
- If requests time out (the wiki can be slow), retry with a local proxy: `MW_PROXY="http://127.0.0.1:7890" bash ${CLAUDE_SKILL_DIR}/scripts/wiki-search.sh ...`. Do not use the proxy by default.

If it printed `No results for: ...`, say so clearly.

Wiki selection: no config is needed. 
Default value is configured in a `config.sh`
but to note that user may give a url in simple form even without protocol scheme.

- To search a different wiki, export `MW_URL` inline: `MW_URL="https://www.mediawiki.org/w/" bash ${CLAUDE_SKILL_DIR}/scripts/wiki-search.sh "<query>"`
- Or use a persistent config (first found wins): `$MW_SKILLS_CONFIG`, then `./config.sh`, then `~/.config/mw-skills/config.sh`.
