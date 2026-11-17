#!/usr/bin/env bash
# install.sh — install shared mw-skills for Agent Skills-compatible clients
#
# Installs the canonical skills to ~/.agents/skills/ and links them into
# ~/.claude/skills and ~/.qwen/skills:
#
#   wiki-read      <page-name>
#   wiki-search    <query> [limit]
#   wiki-category  <category> [limit] | --search <term> [limit]
#   wiki-edit      <page> <file> [summary]
#   wiki-plan      <page> [args...]
#
# Requires the shared skill-config loader (~/.config/skill-config/loader.sh, from
# a bk-skills bundle); it is checked first and nothing is installed without it.
#
# No config is created. Profiles are yours to write, per workspace, at
# <workspace-root>/.config/.mw-skills.sh — one array per wiki:
#   MW_OSSMEDIA=("https://ossmedia.cn/" "" "")          # reads need only the url
#   MW_WRITABLE=("https://wiki.example/w/" "Bot@name" "<botpassword>")
# Select with MW_SITE=<name>; slot 3 is an optional proxy, absent or `nil` = off.
# The legacy MW_SITE_<NAME>_URL/USER/PASS form still loads unchanged.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SKILLS_SRC="${SCRIPT_DIR}/.agents/skills"
SKILLS_DST="${HOME}/.agents/skills"
LINK_ROOTS=("${HOME}/.claude/skills" "${HOME}/.qwen/skills")

LOADER="${SKILL_CONFIG_LOADER:-${HOME}/.config/skill-config/loader.sh}"
if [[ ! -f "$LOADER" ]]; then
  cat >&2 <<EOF
install.sh: shared config loader not found at ${LOADER}

  Install a bk-skills bundle, which carries the loader and every skill at once:
    gh release download --repo brucekomike/bk-skills --pattern '*.tar.gz'
    # then, from a bk-skills checkout:
    bash scripts/install-bundle.sh ./bk-skills-*.tar.gz
    # or: bash scripts/install-bundle.sh --latest

  Nothing was installed. Override the loader location with SKILL_CONFIG_LOADER=...
EOF
  exit 3
fi

echo "==> Installing shared skills to ${SKILLS_DST}"
mkdir -p "$SKILLS_DST"

# Remove legacy user-level command files from earlier versions
mkdir -p "${HOME}/.claude/commands"
for f in mw-read mw-search mw-edit mw-exec; do
  rm -f "${HOME}/.claude/commands/${f}.md"
done

# Remove the skill renamed in earlier versions (wiki-exec -> wiki-plan)
for root in "$SKILLS_DST" "${LINK_ROOTS[@]}"; do
  rm -rf "${root:?}/wiki-exec"
done

# Install canonical skills, then link each client-specific directory to the same
# copies. rm -rf before ln -s: a leftover REAL directory at a link path would make
# `ln -sfn` nest the new link inside it instead of replacing it.
for skill in wiki-read wiki-search wiki-category wiki-edit wiki-plan; do
  rm -rf "${SKILLS_DST:?}/${skill}"
  cp -R "${SKILLS_SRC}/${skill}" "${SKILLS_DST}/${skill}"
  chmod 755 "${SKILLS_DST}/${skill}/scripts/"*.sh 2>/dev/null || true
  for root in "${LINK_ROOTS[@]}"; do
    mkdir -p "$root"
    rm -rf "${root:?}/${skill}"
    ln -s "${SKILLS_DST}/${skill}" "${root}/${skill}"
  done
  echo "    Installed skill: ${skill}"
done

echo
echo "==> Verify:"
for skill in wiki-read wiki-search wiki-category wiki-edit wiki-plan; do
  printf '    %-16s canonical:%s claude:%s qwen:%s\n' "$skill" \
    "$( [[ -f "${SKILLS_DST}/${skill}/SKILL.md" ]] && echo ok || echo MISSING )" \
    "$( [[ -f "${HOME}/.claude/skills/${skill}/SKILL.md" ]] && echo ok || echo MISSING )" \
    "$( [[ -f "${HOME}/.qwen/skills/${skill}/SKILL.md" ]] && echo ok || echo MISSING )"
done

echo
echo "==> Config is yours to write (nothing was created):"
echo "    <workspace-root>/.config/.mw-skills.sh    # preferred, per workspace"
echo "    ~/.config/mw-skills/config.sh             # machine-wide fallback"
echo "  Template: ${SCRIPT_DIR}/config.sh.example"
echo "  Only a url is required for reads; credentials are needed solely by wiki-edit."
