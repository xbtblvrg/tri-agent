#!/usr/bin/env bash
# collect-session.sh — összegyűjti a memory kurálás inputját
set -euo pipefail

work="${BLVRG_WORKSPACE:-$HOME}"
today="$(date +%Y-%m-%d)"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
out="${1:-$work/agents/tasks/memory-collect-${today}.txt}"

{
  echo "=== TRI-AGENT MEMORY COLLECTION ==="
  echo "Generated: $ts"
  echo "Workspace: $work"
  echo ""

  echo "=== MEMORY.md (current, max 12k) ==="
  head -c 12000 "$work/MEMORY.md" 2>/dev/null || echo "(missing)"
  echo ""
  echo ""

  echo "=== memory/$today.md ==="
  if [[ -f "$work/memory/$today.md" ]]; then
    cat "$work/memory/$today.md"
  else
    echo "(empty — nincs mai napi log)"
  fi
  echo ""

  echo "=== memory/agent-decisions.md (tail 80 lines) ==="
  tail -80 "$work/memory/agent-decisions.md" 2>/dev/null || echo "(missing)"
  echo ""

  echo "=== memory/agent-task-log.md (tail 15) ==="
  tail -15 "$work/memory/agent-task-log.md" 2>/dev/null || echo "(missing)"
  echo ""

  echo "=== Recent task summaries (last 5) ==="
  found=0
  while IFS= read -r f; do
    echo "--- $f ---"
    cat "$f"
    echo ""
    found=$((found + 1))
  done < <(find "$work/agents/tasks" -maxdepth 1 -name 'T-*-summary.md' -printf '%T@ %p\n' 2>/dev/null \
    | sort -rn | head -5 | cut -d' ' -f2-)
  [[ "$found" -eq 0 ]] && echo "(nincs summary)"
  echo ""

  echo "=== Git status (short) ==="
  git -C "$work" status -sb 2>/dev/null | head -20 || echo "(not a git repo)"
} >"$out"

echo "$out"