#!/usr/bin/env bash
# install.sh — install mw-skills as user-wide Claude Code skills
#
# Copies each skill folder to ~/.claude/skills/ so the skills are available
# from any project:
#
#   wiki-read   <page-name>
#   wiki-search <query> [limit]
#   wiki-edit   <page> <file> [summary]  |  --batch <file> [summary]
#   wiki-plan   <page> [args...]
#
# Configuration is read from ~/.config/mw-skills/config.sh (created from the
# bundled config.sh.example if it does not exist yet). Only MW_URL is
# required; MW_USER/MW_PASS are needed solely by wiki-edit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="${SCRIPT_DIR}/.claude/skills"
SKILLS_DST="${HOME}/.claude/skills"
CONFIG_DIR="${HOME}/.config/mw-skills"

echo "==> Installing mw-skills to ${SKILLS_DST}"
mkdir -p "$SKILLS_DST" "$CONFIG_DIR"

# Remove legacy user-level command files from earlier versions
mkdir -p "${HOME}/.claude/commands"
for f in mw-read mw-search mw-edit mw-exec; do
  rm -f "${HOME}/.claude/commands/${f}.md"
done

# Remove the skill renamed in earlier versions (wiki-exec -> wiki-plan)
rm -rf "${SKILLS_DST}/wiki-exec"

# Copy each skill folder (SKILL.md + bundled scripts)
for skill in wiki-read wiki-search wiki-edit wiki-plan; do
  rm -rf "${SKILLS_DST}/${skill}"
  cp -R "${SKILLS_SRC}/${skill}" "${SKILLS_DST}/${skill}"
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
echo "==> Installed skills: wiki-read, wiki-search, wiki-edit, wiki-plan"
echo "==> Next step: edit ${CONFIG_DIR}/config.sh"
echo "    (MW_URL required; MW_USER/MW_PASS needed only for wiki-edit)."
echo "    Then use the skills from any project, e.g. 'read wiki page X'."
