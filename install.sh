#!/usr/bin/env bash
# install.sh — install shared mw-skills for Agent Skills-compatible clients
#
# Installs the canonical skills to ~/.agents/skills/ (Qwen Code, OpenCode,
# and other clients) and creates Claude Code compatibility links in
# ~/.claude/skills/:
#
#   wiki-read      <page-name>
#   wiki-search    <query> [limit]
#   wiki-category  <category> [limit] | --search <term> [limit]
#   wiki-edit      <page> <file> [summary]
#   wiki-plan      <page> [args...]
#
# Configuration is read from ~/.config/mw-skills/config.sh (created from the
# bundled config.sh.example if it does not exist yet). Define
# MW_SITE_NAME_URL/USER/PASS profiles for multiple sites and select one with
# MW_SITE. Only a URL is required; credentials are needed solely by wiki-edit.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_SRC="${SCRIPT_DIR}/.agents/skills"
SKILLS_DST="${HOME}/.agents/skills"
CLAUDE_SKILLS_DST="${HOME}/.claude/skills"
CONFIG_DIR="${HOME}/.config/mw-skills"

echo "==> Installing shared skills to ${SKILLS_DST}"
mkdir -p "$SKILLS_DST" "$CLAUDE_SKILLS_DST" "$CONFIG_DIR"

# Remove legacy user-level command files from earlier versions
mkdir -p "${HOME}/.claude/commands"
for f in mw-read mw-search mw-edit mw-exec; do
  rm -f "${HOME}/.claude/commands/${f}.md"
done

# Remove the skill renamed in earlier versions (wiki-exec -> wiki-plan)
rm -rf "${SKILLS_DST}/wiki-exec" "${CLAUDE_SKILLS_DST}/wiki-exec"

# Install canonical skills for clients that discover ~/.agents/skills, then
# link Claude Code's client-specific directory to the same copies.
for skill in wiki-read wiki-search wiki-category wiki-edit wiki-plan; do
  rm -rf "${SKILLS_DST}/${skill}"
  cp -R "${SKILLS_SRC}/${skill}" "${SKILLS_DST}/${skill}"
  rm -rf "${CLAUDE_SKILLS_DST}/${skill}"
  ln -s "${SKILLS_DST}/${skill}" "${CLAUDE_SKILLS_DST}/${skill}"
  echo "    Installed skill: ${skill}"
done

# Create user config if it doesn't exist
if [[ ! -f "${CONFIG_DIR}/config.sh" ]]; then
  cp "${SCRIPT_DIR}/config.sh.example" "${CONFIG_DIR}/config.sh"
  chmod 600 "${CONFIG_DIR}/config.sh"
  echo "    Created ${CONFIG_DIR}/config.sh — edit it to fill in your wiki settings."
else
  echo "    Existing ${CONFIG_DIR}/config.sh kept."
fi

echo ""
echo "==> Installed shared skills: wiki-read, wiki-search, wiki-category, wiki-edit, wiki-plan"
echo "==> Next step: edit ${CONFIG_DIR}/config.sh"
echo "    (MW_URL or a selected MW_SITE profile required; credentials only for wiki-edit)."
echo "    Then use the skills from any project, e.g. 'read wiki page X'."
