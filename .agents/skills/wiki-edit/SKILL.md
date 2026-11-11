---
name: wiki-edit
description: Create or replace a MediaWiki page from a local file. Use only when asked to edit a wiki page; review the current page and get approval before writing.
compatibility: Requires Bash, curl, jq, network access to a MediaWiki API, and a locally configured BotPassword for edits.
---

# Edit wiki pages (single-page upload)

Overwrite one wiki page with the contents of a local file. Before editing, the
script fetches and prints the current page content so you can review what will
be replaced. For a brand-new page it reports that no existing page was found.

Before editing, use `wiki-read` to fetch the target page, show the current
content to the user, and get approval for the replacement. Confirm that the
local content file is the intended complete replacement (or that the page is
new) before invoking this script. The script overwrites the page; it does not
merge content.

```bash
bash <skill-directory>/scripts/wiki-edit.sh "<page-name>" <content-file> [summary]
```

Resolve the script path relative to the directory containing this SKILL.md
using the path information supplied by your agent runtime. Do not rely on
client-specific skill-path variables.

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

This is the only skill that requires bot credentials (`MW_USER`/`MW_PASS` from
the wiki's Special:BotPassword); the others work with just `MW_URL`. Keep the
BotPassword in the ignored local config or a secret manager, never in this skill,
the repository, or an agent prompt. Prefer a dedicated bot with only the rights
needed to edit the intended pages. If login fails, report the error — it usually
means missing or wrong credentials.

This is the only skill that logs in. It keeps a persistent cookie (default
`~/.config/mw-skills/cookies.txt`), so a login is reused and you only log in
again when the session is missing or has expired.

Configuration: the script looks for a config in this order — `$MW_SKILLS_CONFIG`,
then `./config.sh`, then `~/.config/mw-skills/config.sh`. Set `MW_SITE=name` to
select a named profile (`MW_SITE_NAME_URL`, `MW_SITE_NAME_USER`, and
`MW_SITE_NAME_PASS`). Each site gets a separate persistent cookie jar.
