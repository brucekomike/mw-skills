---
name: wiki-category
description: List pages or subcategories in a MediaWiki wiki category, search category names, and list pages belonging to multiple categories. Use when the user asks what's in a category, to browse categories, to find subcategories, or to find pages in a specific category (e.g. "what articles are in Category:Linux distros").
compatibility: Requires Bash, curl, jq, and network access to a MediaWiki API.
---

# List wiki categories

Run the bundled script from this skill's directory. Resolve the directory from
the loaded `SKILL.md` path; do not assume a client-specific variable or the
current working directory:

```bash
bash <skill-directory>/scripts/wiki-category.sh "<category>" [limit]
```

Resolve script paths relative to the directory containing this SKILL.md using
the path information supplied by your agent runtime.

## Modes

List pages in a category (default limit 100):
```bash
bash <skill-directory>/scripts/wiki-category.sh "Category:Linux distros" 20
# or without the prefix:
bash <skill-directory>/scripts/wiki-category.sh "Linux distros" 20
```

List subcategories of a category:
```bash
bash <skill-directory>/scripts/wiki-category.sh "Linux distros" --subcategories
```

List pages that belong to BOTH categories (intersection):
```bash
bash <skill-directory>/scripts/wiki-category.sh "Linux distros" --in "Free software"
```

Search category titles:
```bash
bash <skill-directory>/scripts/wiki-category.sh --search "Linux" 10
```

## Notes

- Output is one title per line with the `Category:` prefix stripped. Use the
  titles with the `wiki-read` skill to read page content.
- Titles may be non-ASCII; the script URL-encodes everything, so pass them
  through as-is.
- Category names may be given with or without the `Category:` prefix.
- The API caps single-request results at 500; for larger categories, use a
  limit up to 500.
- Intersection mode fetches up to 500 pages per category — it may miss matches
  beyond that cap.
- If requests time out (the wiki can be slow), retry with a local proxy:
  `MW_PROXY="http://127.0.0.1:7890" bash <skill-directory>/scripts/wiki-category.sh ...`.
  Do not use the proxy by default.

If it printed `No results for category: ...`, say so clearly.

The default wiki is Wikipedia. To target another wiki, export `MW_URL` inline:
`MW_URL="https://ossmedia.cn/" bash <skill-directory>/scripts/wiki-category.sh "Category:..."`.
