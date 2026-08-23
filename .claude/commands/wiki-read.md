---
description: Read the raw wikitext of a specific page from the configured MediaWiki wiki.
---

Read the wiki page specified in the arguments by running the `wiki-read.sh` skill.

If `config.sh` does not exist yet, tell the user to copy `config.sh.example` and fill in their credentials before proceeding.

Run:

```bash
bash wiki-read.sh $ARGUMENTS
```

Print the returned wikitext to the user. If the page is not found or the output is empty, report the error clearly.
