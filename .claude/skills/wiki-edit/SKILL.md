---
name: wiki-edit
description: Overwrite a single MediaWiki page from a local file. Logs in with bot credentials and shows the current page content before editing.
---

# Edit wiki pages (single-page upload)

Overwrite one wiki page with the contents of a local file. Before editing, the
script fetches and prints the current page content so you can review what will
be replaced. For a brand-new page it reports that no existing page was found.

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/wiki-edit.sh "<page-name>" <content-file> [summary]
```

- `<page-name>` – the page title to create or update (subpages like `Foo/Bar` work).
- `<content-file>` – a local file whose contents become the page's wikitext.
- `[summary]` – edit summary (defaults to `mw-skills`).

The script prints the existing page first, then the edit result, and exits `1`
if the edit does not return `Success`.

### Permission errors

If the edit (or login) fails for a reason that looks permission-related — e.g. a
login failure, or an error code/message of `notregistered`, `cantcreate`,
`permissiondenied`, or `badtoken` — do **not** retry. Instead, explain the error
to the user and ask them to resolve it (grant the bot the needed permission on the
wiki, or fix `MW_USER`/`MW_PASS`). Only re-run the script once they confirm the
permission has been granted.

This is the only skill that requires bot credentials (`MW_USER`/`MW_PASS` from the
wiki's Special:BotPassword); the others work with just `MW_URL`. If login fails,
report the error — it usually means missing or wrong credentials.

This is the only skill that logs in. It keeps a persistent cookie (default
`~/.config/mw-skills/cookies.txt`), so a login is reused and you only log in
again when the session is missing or has expired.

Configuration: the script looks for a config in this order — `$MW_SKILLS_CONFIG`,
then `./config.sh`, then `~/.config/mw-skills/config.sh`.
