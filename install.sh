#!/usr/bin/env bash
# install.sh — install mw-skills as user-wide Claude Code slash commands
#
# After running this script, the following commands are available in Claude Code
# from any project on your machine:
#
#   /user:mw-read   <page>
#   /user:mw-search <query> [limit]
#   /user:mw-edit   <page> <file> [summary]  |  --batch <file> [summary]
#   /user:mw-exec   <page> [args...]
#
# Configuration is read from ~/.config/mw-skills/config.sh (created from the
# bundled config.sh.example if it does not exist yet).

set -euo pipefail

SKILL_DIR="${HOME}/.local/share/mw-skills"
CMD_DIR="${HOME}/.claude/commands"
CONFIG_DIR="${HOME}/.config/mw-skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing mw-skills to ${SKILL_DIR}"
mkdir -p "$SKILL_DIR" "$CMD_DIR" "$CONFIG_DIR"

# Copy shell scripts
for f in lib.sh wiki-read.sh wiki-search.sh wiki-edit.sh wiki-exec.sh; do
  cp "$SCRIPT_DIR/$f" "$SKILL_DIR/$f"
  chmod 755 "$SKILL_DIR/$f"
done

# Create user config if it doesn't exist
if [[ ! -f "${CONFIG_DIR}/config.sh" ]]; then
  cp "$SCRIPT_DIR/config.sh.example" "${CONFIG_DIR}/config.sh"
  chmod 600 "${CONFIG_DIR}/config.sh"
  echo "    Created ${CONFIG_DIR}/config.sh — edit it to fill in your wiki credentials."
else
  echo "    Existing ${CONFIG_DIR}/config.sh kept."
fi

# Generate user-level Claude Code command files
# Each command sources the user config then delegates to the installed skill.

generate_cmd() {
  local name="$1"       # e.g. mw-read
  local script="$2"     # e.g. wiki-read.sh
  local description="$3"
  local args_hint="$4"  # shown in description

  cat > "${CMD_DIR}/${name}.md" <<EOF
---
description: ${description}
---

Run the \`${script}\` skill installed at \`${SKILL_DIR}\`.

Arguments: \`${args_hint}\`

First ensure \`${CONFIG_DIR}/config.sh\` exists and contains valid credentials (MW_URL, MW_USER, MW_PASS). If it is missing or unconfigured, tell the user to edit that file before proceeding.

Run:

\`\`\`bash
MW_SKILLS_CONFIG="${CONFIG_DIR}/config.sh" bash "${SKILL_DIR}/${script}" $ARGUMENTS
\`\`\`

Report the output to the user. On error, show the error message clearly.
EOF
}

generate_cmd "mw-read"   "wiki-read.sh"   "Read the raw wikitext of a MediaWiki page"                        "<page-name>"
generate_cmd "mw-search" "wiki-search.sh" "Search for pages on the configured MediaWiki wiki"                "<query> [limit]"
generate_cmd "mw-edit"   "wiki-edit.sh"   "Create or update a MediaWiki page from a local file"              "<page> <file> [summary]  |  --batch <file> [summary]"
generate_cmd "mw-exec"   "wiki-exec.sh"   "Fetch a MediaWiki page and execute its content as a shell script" "<page-name> [args...]"

echo "==> Installed Claude Code commands:"
for f in mw-read mw-search mw-edit mw-exec; do
  echo "    /user:${f}"
done
echo ""
echo "==> Next step: edit ${CONFIG_DIR}/config.sh with your wiki credentials."
echo "    Then open Claude Code in any project and use /user:mw-read, /user:mw-search, etc."
