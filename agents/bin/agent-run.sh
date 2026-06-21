#!/usr/bin/env bash
# agent-run.sh — egységes CLI wrapper (fast = dev default, full = bootstrap)
# Használat: agent-run.sh [--fast|--full] <grok|claude|codex> "<prompt>"
set -euo pipefail

mode="fast"
if [[ "${1:-}" == --fast || "${1:-}" == --full ]]; then
  mode="$1"
  shift
fi

agent="${1:?agent required (grok|claude|codex)}"
prompt="${2:?prompt required}"
work="${BLVRG_WORKSPACE:-$HOME}"
refresh="$work/agents/bin/agent-context-refresh.sh"

"$refresh" >/dev/null

if [[ "$mode" == fast ]]; then
  bootstrap="Tri-agent: olvasd $work/agents/roles/${agent}.md (ez a TE szereped, kötelező). Dev context: $work/agents/dev/CONTEXT.md. Feladat: $prompt"
else
  bootstrap="Tri-agent: olvasd $work/agents/AGENTS_PROTOCOL.md és $work/agents/roles/${agent}.md (ez a TE szereped). MEMORY: $work/MEMORY.md, $work/memory/$(date +%Y-%m-%d).md. Feladat: $prompt"
fi

cd "$work"

case "$agent" in
  grok)
    grok -p "$bootstrap" \
      --agent "$work/agents/roles/grok.md" \
      --always-approve \
      --output-format plain 2>&1
    ;;
  claude)
    claude -p "$bootstrap" \
      --add-dir "$work" \
      --permission-mode bypassPermissions \
      --output-format text 2>&1
    ;;
  codex)
    codex exec "$bootstrap" 2>&1
    ;;
  *)
    echo "Unknown agent: $agent" >&2
    exit 1
    ;;
esac