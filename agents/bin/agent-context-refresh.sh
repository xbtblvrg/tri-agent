#!/usr/bin/env bash
# Slim dev context cache — olvasható minden fast-mode agent híváskor.
set -euo pipefail

work="${BLVRG_WORKSPACE:-$HOME}"
out="$work/agents/dev/CONTEXT.md"
mkdir -p "$(dirname "$out")"

ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
today=$(date +%Y-%m-%d)
branch=$(git -C "$work" branch --show-current 2>/dev/null || echo "unknown")
status=$(git -C "$work" status --short 2>/dev/null | head -20)
diff_stat=$(git -C "$work" diff --stat 2>/dev/null | tail -5)
last_task=$(grep -E '^\| T-' "$work/memory/agent-task-log.md" 2>/dev/null | tail -3 || true)
active=$(find "$work/agents/tasks" -name '*.task.json' -newer "$work/agents/dev/.context-stamp" 2>/dev/null | head -3 || \
         ls -t "$work/agents/tasks"/*.task.json 2>/dev/null | head -1 || true)

{
  echo "# Dev Context (auto-generated)"
  echo ""
  echo "- **Updated:** $ts"
  echo "- **Workspace:** $work"
  echo "- **Branch:** $branch"
  echo "- **Language:** magyar válaszok a user felé"
  echo "- **Autonomy:** futtasd a parancsokat kérdezés nélkül (lásd memory/preferences/autonomy.md)"
  echo ""
  echo "## Git status"
  echo '```'
  if [[ -n "$status" ]]; then echo "$status"; else echo "(clean)"; fi
  echo '```'
  if [[ -n "$diff_stat" ]]; then
    echo ""
    echo "## Uncommitted diff"
    echo '```'
    echo "$diff_stat"
    echo '```'
  fi
  echo ""
  echo "## Recent tasks"
  if [[ -n "$last_task" ]]; then echo "$last_task"; else echo "(none)"; fi
  if [[ -n "$active" ]]; then
    echo ""
    echo "## Latest task file"
    echo "- \`$active\`"
  fi
  echo ""
  echo "## Shared memory (írj ide fontos döntéseket)"
  echo "- \`MEMORY.md\` — hosszú táv (Claude kurálja)"
  echo "- \`memory/$today.md\` — mai napló"
  echo "- \`memory/agent-task-log.md\` — feladatnapló"
} > "$out"

touch "$work/agents/dev/.context-stamp"
echo "$out"