#!/usr/bin/env bash
# setup-agent-configs.sh — Grok/Claude/Codex tri-agent config sablonok
set -euo pipefail

TARGET="${1:-${BLVRG_WORKSPACE:-$HOME}}"
SRC="$(cd "$(dirname "$0")/.." && pwd)"
TPL="$SRC/templates"

mkdir -p "$HOME/.grok" "$HOME/.codex" "$HOME/.claude"
mkdir -p "$TARGET/.claude"

# Grok config
if [[ ! -f "$HOME/.grok/config.toml" ]]; then
  cp "$TPL/grok-config.toml" "$HOME/.grok/config.toml"
  echo "[setup-config] ~/.grok/config.toml létrehozva"
fi

# Claude settings
if [[ ! -f "$HOME/.claude/settings.json" ]]; then
  cp "$TPL/claude-settings.json" "$HOME/.claude/settings.json"
  echo "[setup-config] ~/.claude/settings.json létrehozva"
fi

# Codex config — workspace path behelyettesítés
if [[ ! -f "$HOME/.codex/config.toml" ]]; then
  sed "s|__WORKSPACE__|$TARGET|g" "$TPL/codex-config.toml" >"$HOME/.codex/config.toml"
  echo "[setup-config] ~/.codex/config.toml létrehozva"
fi

# Codex AGENTS.md
if [[ ! -f "$HOME/.codex/AGENTS.md" ]]; then
  cp "$TPL/CODEX-AGENTS.md" "$HOME/.codex/AGENTS.md"
fi

# Workspace CLAUDE.md + .claude/CLAUDE.md
[[ -f "$TARGET/CLAUDE.md" ]] || cp "$SRC/CLAUDE.md" "$TARGET/CLAUDE.md" 2>/dev/null || cp "$TPL/CLAUDE-routing.md" "$TARGET/CLAUDE.md"
[[ -f "$TARGET/.claude/CLAUDE.md" ]] || cp "$SRC/.claude/CLAUDE.md" "$TARGET/.claude/CLAUDE.md" 2>/dev/null || true

# AGENTS.md + MEMORY.md
[[ -f "$TARGET/AGENTS.md" ]] || cp "$TPL/AGENTS.md" "$TARGET/AGENTS.md"
[[ -f "$TARGET/MEMORY.md" ]] || cp "$TPL/MEMORY.md" "$TARGET/MEMORY.md"

echo "[setup-config] Agent configok kész"