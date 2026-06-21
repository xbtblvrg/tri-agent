#!/usr/bin/env bash
# install.sh — tri-agent telepítés workspace-be
# Használat: ./install.sh [target_dir]   (default: $HOME)
set -euo pipefail

TARGET="${1:-$HOME}"
SRC="$(cd "$(dirname "$0")" && pwd)"
TARGET="$(cd "$TARGET" && pwd)"

echo "▶ tri-agent install → $TARGET"

rsync -a "$SRC/agents/" "$TARGET/agents/"
mkdir -p "$TARGET/bin"
chmod +x "$TARGET/agents/bin/"*.sh "$SRC/bin/"*.sh 2>/dev/null || true

for s in agent-do agent-dev agent-run agent-send agent-recv agent-dispatch; do
  ln -sf "$TARGET/agents/bin/${s}.sh" "$TARGET/bin/${s}.sh"
done
for s in dev-setup dev-check dev-env dev-audit; do
  ln -sf "$SRC/bin/${s}.sh" "$TARGET/bin/${s}.sh"
done

mkdir -p "$TARGET/memory/"{system,preferences,daily}
mkdir -p "$TARGET/agents/bus/inbox/"{grok,claude,codex} "$TARGET/agents/bus/archive" "$TARGET/agents/tasks" "$TARGET/agents/dev"

if [[ ! -f "$TARGET/memory/agent-task-log.md" ]]; then
  cat >"$TARGET/memory/agent-task-log.md" <<'EOF'
# Agent feladatnapló

| Task ID | Leírás | Kiosztva | Státusz | Dátum |
|---------|--------|----------|---------|-------|
EOF
fi

[[ -f "$TARGET/memory/agent-decisions.md" ]] || echo "# Agent döntések" >"$TARGET/memory/agent-decisions.md"
[[ -f "$TARGET/CLAUDE.md" ]] || cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md"
# Codex global tri-agent hint (merge with existing if present)
if [[ ! -f "$HOME/.codex/AGENTS.md" ]]; then
  mkdir -p "$HOME/.codex"
  cp "$SRC/templates/CODEX-AGENTS.md" "$HOME/.codex/AGENTS.md" 2>/dev/null || true
fi
[[ -f "$TARGET/Makefile" ]] || cp "$SRC/Makefile" "$TARGET/"
[[ -f "$TARGET/.editorconfig" ]] || cp "$SRC/.editorconfig" "$TARGET/"

mkdir -p "$TARGET/.config/blvrg"
ln -sf "$TARGET/bin/dev-env.sh" "$TARGET/.config/blvrg/dev-env.sh"
if ! grep -qF 'blvrg dev-env' "$TARGET/.bashrc" 2>/dev/null; then
  cat >>"$TARGET/.bashrc" <<'EOF'

# >>> blvrg dev-env >>>
[[ -f "$HOME/.config/blvrg/dev-env.sh" ]] && source "$HOME/.config/blvrg/dev-env.sh"
# <<< blvrg dev-env <<<
EOF
fi

BLVRG_WORKSPACE="$TARGET" "$TARGET/agents/bin/agent-context-refresh.sh" >/dev/null

echo "✓ Telepítve: $TARGET"
echo "  do \"feladat\""
echo "  make check"