---
description: Search for pages on the configured MediaWiki wiki.
---

Search the wiki using the query (and optional result limit) specified in the arguments by running the `wiki-search.sh` skill.

Arguments format: `<query> [limit]`  — limit defaults to 10 if omitted.

If `config.sh` does not exist yet, tell the user to copy `config.sh.example` and fill in their credentials before proceeding.

Run:

```bash
bash wiki-search.sh $ARGUMENTS
```

Print the matching page titles to the user, one per line. If no results are found, say so clearly.
