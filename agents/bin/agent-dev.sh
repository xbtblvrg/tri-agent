#!/usr/bin/env bash
# agent-dev.sh — fejlesztői al-parancsok (user: használd agent-do.sh helyette)
set -euo pipefail

source "$(dirname "$0")/agent-lib.sh"

cmd_implement() {
  local desc="${1:?}"
  local id
  id=$(agent_next_id)
  agent_write_task "$id" "$desc"
  agent_run_codex "$id" "$desc"
  agent_append_log "$id" "$desc" "codex" "implement kész"
  echo "[$id] Kész."
}

cmd_review() {
  local id="${1:-review}"
  agent_run_claude_review "${1:-}"
  agent_append_log "$id" "review" "claude" "kész"
}

cmd_pipeline() {
  local desc="${1:?}"
  exec "$(dirname "$0")/agent-do.sh" "$desc"
}

cmd_route() {
  exec "$(dirname "$0")/agent-do.sh" "$*"
}

cmd_status() {
  "$AGENT_REFRESH"
  echo "=== Dev status ==="
  echo "Branch: $(git -C "$AGENT_WORK" branch --show-current 2>/dev/null)"
  git -C "$AGENT_WORK" status --short 2>/dev/null | head -15 || true
  echo ""
  grep -E '^\| T-' "$AGENT_LOG" 2>/dev/null | tail -5 || echo "(none)"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  implement) cmd_implement "$*" ;;
  review)    cmd_review "$*" ;;
  pipeline|route) cmd_route "$*" ;;
  refresh)   "$AGENT_REFRESH" ;;
  status)    cmd_status ;;
  *)
    echo "User: agent-do.sh \"feladat\"  (automatikus minden)"
    echo "Dev:  agent-dev.sh status|refresh|implement|review"
    exit 1
    ;;
esac