---
description: Fetch a MediaWiki page and execute its content as a shell script.
---

Execute a wiki page as a shell script by running the `wiki-exec.sh` skill.

Arguments: `<page-name> [arg1 arg2 ...]`  — extra arguments are passed to the script.

If `config.sh` does not exist yet, tell the user to copy `config.sh.example` and fill in their credentials before proceeding.

> **Security warning:** Only use this command against wikis you fully control and with pages you have reviewed. Never execute untrusted wiki content.

Run:

```bash
bash wiki-exec.sh $ARGUMENTS
```

Show the script output to the user. If the page is not found or execution fails, report the error.
