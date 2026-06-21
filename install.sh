#!/usr/bin/env bash
# install.sh — tri-agent telepítés workspace-be (idempotens)
# Használat: ./install.sh [target_dir]   (default: $BLVRG_WORKSPACE vagy $HOME)
set -euo pipefail

TARGET="${1:-${BLVRG_WORKSPACE:-$HOME}}"
SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(mkdir -p "$TARGET" && cd "$TARGET" && pwd)"

echo "▶ tri-agent install → $TARGET"

# Core
rsync -a "$SRC/agents/" "$TARGET/agents/"
rsync -a "$SRC/skills/" "$TARGET/skills/" 2>/dev/null || mkdir -p "$TARGET/skills"
rsync -a "$SRC/docs/" "$TARGET/docs/" 2>/dev/null || mkdir -p "$TARGET/docs"

mkdir -p "$TARGET/bin"
chmod +x "$SRC/bin/"*.sh "$TARGET/agents/bin/"*.sh 2>/dev/null || true

# bin/ symlinks
for s in agent-do agent-dev agent-run agent-send agent-recv agent-dispatch; do
  ln -sf "$TARGET/agents/bin/${s}.sh" "$TARGET/bin/${s}.sh"
done
for s in dev-setup dev-check dev-env dev-audit setup-skills setup-agent-configs; do
  [[ -f "$SRC/bin/${s}.sh" ]] && ln -sf "$SRC/bin/${s}.sh" "$TARGET/bin/${s}.sh"
done

# Dirs
mkdir -p "$TARGET/memory/"{system,preferences}
mkdir -p "$TARGET/agents/bus/inbox/"{grok,claude,codex} "$TARGET/agents/bus/archive"
mkdir -p "$TARGET/agents/tasks" "$TARGET/agents/dev"
mkdir -p "$TARGET/.claude" "$TARGET/.grok/rules" "$TARGET/.grok/agents"

# Memory stubs
if [[ ! -f "$TARGET/memory/agent-task-log.md" ]]; then
  cat >"$TARGET/memory/agent-task-log.md" <<'EOF'
# Agent feladatnapló

| Task ID | Leírás | Kiosztva | Státusz | Dátum |
|---------|--------|----------|---------|-------|
EOF
fi
[[ -f "$TARGET/memory/agent-decisions.md" ]] || echo "# Agent döntések" >"$TARGET/memory/agent-decisions.md"
[[ -f "$TARGET/memory/system/tri-agent.md" ]] || cp "$SRC/docs/tri-agent.md" "$TARGET/memory/system/tri-agent.md" 2>/dev/null || true

# Workspace docs (csak ha hiányzik)
[[ -f "$TARGET/CLAUDE.md" ]] || cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md" 2>/dev/null || true
[[ -f "$TARGET/.claude/CLAUDE.md" ]] || cp "$SRC/.claude/CLAUDE.md" "$TARGET/.claude/CLAUDE.md" 2>/dev/null || true
[[ -f "$TARGET/AGENTS.md" ]] || cp "$SRC/templates/AGENTS.md" "$TARGET/AGENTS.md" 2>/dev/null || true
[[ -f "$TARGET/MEMORY.md" ]] || cp "$SRC/templates/MEMORY.md" "$TARGET/MEMORY.md" 2>/dev/null || true
[[ -f "$TARGET/Makefile" ]] || cp "$SRC/Makefile" "$TARGET/"
[[ -f "$TARGET/.editorconfig" ]] || cp "$SRC/.editorconfig" "$TARGET/"

# Grok workspace rules
cp -n "$SRC/.grok/rules/"*.md "$TARGET/.grok/rules/" 2>/dev/null || cp "$SRC/.grok/rules/"*.md "$TARGET/.grok/rules/" 2>/dev/null || true
cp -n "$SRC/.grok/agents/"*.md "$TARGET/.grok/agents/" 2>/dev/null || cp "$SRC/.grok/agents/"*.md "$TARGET/.grok/agents/" 2>/dev/null || true

# Shell env
mkdir -p "$TARGET/.config/blvrg"
ln -sf "$TARGET/bin/dev-env.sh" "$TARGET/.config/blvrg/dev-env.sh"
if ! grep -qF 'blvrg dev-env' "$TARGET/.bashrc" 2>/dev/null; then
  cat >>"$TARGET/.bashrc" <<'EOF'

# >>> blvrg dev-env >>>
[[ -f "$HOME/.config/blvrg/dev-env.sh" ]] && source "$HOME/.config/blvrg/dev-env.sh"
# <<< blvrg dev-env <<<
EOF
fi

# Agent configs + skill symlinks
[[ -x "$SRC/bin/setup-agent-configs.sh" ]] && bash "$SRC/bin/setup-agent-configs.sh" "$TARGET"
[[ -x "$SRC/bin/setup-skills.sh" ]] && bash "$SRC/bin/setup-skills.sh" "$TARGET"

BLVRG_WORKSPACE="$TARGET" "$TARGET/agents/bin/agent-context-refresh.sh" >/dev/null 2>&1 || true

echo "✓ Telepítve: $TARGET"
echo "  source ~/.config/blvrg/dev-env.sh"
echo "  do \"feladat\""