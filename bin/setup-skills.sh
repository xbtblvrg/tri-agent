#!/usr/bin/env bash
# setup-skills.sh — tri-agent skill symlink-ek Grok + Claude alá
set -euo pipefail

TARGET="${1:-${BLVRG_WORKSPACE:-$HOME}}"
SKILLS="$TARGET/skills"

mkdir -p "$TARGET/.grok/skills" "$TARGET/.claude/skills"

for name in tri-agent-do tri-agent-implement tri-agent-review tri-agent-verify tri-agent-memory; do
  [[ -d "$SKILLS/$name" ]] || continue
  ln -sfn "$SKILLS/$name" "$TARGET/.grok/skills/$name"
  [[ "$name" == tri-agent-review || "$name" == tri-agent-memory ]] && \
    ln -sfn "$SKILLS/$name" "$TARGET/.claude/skills/$name"
done

# Grok rules + agents (workspace szint)
if [[ -d "$TARGET/tri-agent/.grok/rules" ]]; then
  mkdir -p "$TARGET/.grok/rules" "$TARGET/.grok/agents"
  for f in "$TARGET/tri-agent/.grok/rules/"*.md; do
    [[ -f "$f" ]] && cp -n "$f" "$TARGET/.grok/rules/" 2>/dev/null || cp "$f" "$TARGET/.grok/rules/"
  done
  for f in "$TARGET/tri-agent/.grok/agents/"*.md; do
    [[ -f "$f" ]] && cp -n "$f" "$TARGET/.grok/agents/" 2>/dev/null || cp "$f" "$TARGET/.grok/agents/"
  done
fi

# Ha a script a clone-ból fut (install közben)
SRC="$(cd "$(dirname "$0")/.." && pwd)"
if [[ -d "$SRC/.grok/rules" ]]; then
  mkdir -p "$TARGET/.grok/rules" "$TARGET/.grok/agents"
  cp -n "$SRC/.grok/rules/"*.md "$TARGET/.grok/rules/" 2>/dev/null || cp "$SRC/.grok/rules/"*.md "$TARGET/.grok/rules/" 2>/dev/null || true
  cp -n "$SRC/.grok/agents/"*.md "$TARGET/.grok/agents/" 2>/dev/null || cp "$SRC/.grok/agents/"*.md "$TARGET/.grok/agents/" 2>/dev/null || true
fi

chmod +x "$SKILLS/"*/scripts/*.sh 2>/dev/null || true
echo "[setup-skills] Symlink-ek: $TARGET/.grok/skills + .claude/skills"