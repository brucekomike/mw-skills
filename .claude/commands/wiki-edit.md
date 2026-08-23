---
description: Create or update a MediaWiki page from a local file, or batch-edit multiple pages.
---

Edit a wiki page (or multiple pages in batch mode) by running the `wiki-edit.sh` skill.

Arguments:
- Single page: `<page-name> <content-file> [summary]`
- Batch mode: `--batch <batch-file> [summary]`  — batch file has one `page-name content-file` pair per line.

If `config.sh` does not exist yet, tell the user to copy `config.sh.example` and fill in their credentials before proceeding.

Run:

```bash
bash wiki-edit.sh $ARGUMENTS
```

Report whether each page was edited successfully. If any errors occur, show them to the user.
