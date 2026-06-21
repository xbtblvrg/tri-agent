#!/usr/bin/env bash
# Shared tri-agent helpers — source only, do not execute directly.
[[ -n "${AGENT_LIB_LOADED:-}" ]] && return 0
AGENT_LIB_LOADED=1

AGENT_WORK="${BLVRG_WORKSPACE:-$HOME}"
AGENT_BIN="$AGENT_WORK/agents/bin"
AGENT_TASKS="$AGENT_WORK/agents/tasks"
AGENT_LOG="$AGENT_WORK/memory/agent-task-log.md"
AGENT_TODAY="$AGENT_WORK/memory/$(date +%Y-%m-%d).md"
AGENT_RUN_SCRIPT="$AGENT_BIN/agent-run.sh"
AGENT_REFRESH="$AGENT_BIN/agent-context-refresh.sh"

agent_run_cli() {
  "$AGENT_RUN_SCRIPT" --fast "$@"
}

agent_next_id() {
  local last n
  last=$(grep -oE 'T-[0-9]+' "$AGENT_LOG" 2>/dev/null | tail -1 || echo "T-0000")
  n=$((10#${last#T-} + 1))
  printf 'T-%04d' "$n"
}

agent_write_task() {
  local id="$1" desc="$2" status="${3:-active}" mode="${4:-dev}"
  jq -n \
    --arg id "$id" --arg desc "$desc" \
    --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --arg status "$status" --arg mode "$mode" \
    '{id:$id, description:$desc, status:$status, created:$ts, mode:$mode}' \
    > "$AGENT_TASKS/${id}.task.json"
}

agent_append_log() {
  local id="$1" desc="$2" target="$3" status="$4"
  {
    echo ""
    echo "## $(date -u +%Y-%m-%dT%H:%M:%SZ) — $id"
    echo "- Feladat: $desc"
    echo "- Agent: $target | Státusz: $status"
  } >> "$AGENT_TODAY"
  echo "| $id | $desc | $target | $status | $(date +%Y-%m-%d) |" >> "$AGENT_LOG"
}

agent_classify() {
  local desc="$1"
  local lower
  lower=$(echo "$desc" | tr '[:upper:]' '[:lower:]')

  if echo "$lower" | grep -qE '^(mi |mi a |mi az |hogyan |miért |magyarázd|explain|what |why |működik)'; then
    echo question
  elif echo "$lower" | grep -qE 'review|refactor|audit|ellenőriz|vizsgáld|átnézed|code review|nézd át'; then
    if echo "$lower" | grep -qE 'implement|írj|készít|add|fix|javít|fejleszt|build'; then
      echo pipeline
    else
      echo review
    fi
  elif echo "$lower" | grep -qE 'implement|build|fix|add|create|write|script|test|készít|írj|javít|fejleszt|telepít|állíts|konfigurál'; then
    echo pipeline
  else
    echo pipeline
  fi
}

agent_review_verdict() {
  local id="$1"
  local f="$AGENT_TASKS/${id}-review.json"
  [[ -f "$f" ]] || f="$AGENT_TASKS/${id}-claude.result.json"
  [[ -f "$f" ]] || return 1
  jq -r '.verdict // .status // "UNKNOWN"' "$f" 2>/dev/null | tr '[:lower:]' '[:upper:]'
}

agent_run_codex() {
  local id="$1" desc="$2" extra="${3:-}"
  "$AGENT_REFRESH" >/dev/null
  echo "[$id] Codex dolgozik..."
  agent_run_cli codex "Task $id: $desc
$extra
Szabályok: minimális diff, futtasd a teszteket ha releváns, írd agents/tasks/${id}.result.json-ba (status, modified_files, message). Ne írj MEMORY.md-be."
}

agent_run_claude_review() {
  local id="$1"
  local task_note=""
  [[ -f "$AGENT_TASKS/${id}.task.json" ]] && \
    task_note="Task $id: $(jq -r .description "$AGENT_TASKS/${id}.task.json")"

  local diff staged
  diff=$(git -C "$AGENT_WORK" diff 2>/dev/null | head -c 50000)
  staged=$(git -C "$AGENT_WORK" diff --cached 2>/dev/null | head -c 20000)

  echo "[$id] Claude review..."
  agent_run_cli claude "Code review. $task_note
Verdict: APPROVED | CHANGES_REQUESTED | BLOCKED. Írd agents/tasks/${id}-review.json-ba (verdict, findings[], ts).
---
STAGED: $staged
---
UNSTAGED: $diff"
}

agent_write_summary() {
  local id="$1" desc="$2" verdict="${3:-}"
  local sum="$AGENT_TASKS/${id}.summary.md"
  local codex_msg review_msg files

  codex_msg=$(jq -r '.message // "—"' "$AGENT_TASKS/${id}.result.json" 2>/dev/null || echo "—")
  review_msg=$(jq -r '.verdict // .status // "—"' "$AGENT_TASKS/${id}-review.json" 2>/dev/null || echo "—")
  files=$(jq -r '.modified_files // [] | join(", ")' "$AGENT_TASKS/${id}.result.json" 2>/dev/null || echo "—")

  {
    echo "# $id — összefoglaló"
    echo ""
    echo "**Feladat:** $desc"
    echo "**Codex:** $codex_msg"
    echo "**Claude:** $review_msg"
    echo "**Fájlok:** $files"
    echo "**Végső:** ${verdict:-$review_msg}"
    echo ""
    echo "Generálva: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$sum"
  echo "$sum"
}