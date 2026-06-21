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
AGENT_SKILL_IMPL="$AGENT_WORK/skills/tri-agent-implement/SKILL.md"
AGENT_SKILL_REVIEW="$AGENT_WORK/skills/tri-agent-review/SKILL.md"
AGENT_SKILL_MEMORY="$AGENT_WORK/skills/tri-agent-memory/SKILL.md"
AGENT_SKILL_MEMORY_COLLECT="$AGENT_WORK/skills/tri-agent-memory/scripts/collect-session.sh"
AGENT_SKILL_VERIFY="$AGENT_WORK/skills/tri-agent-verify/scripts/verify.sh"

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
  elif echo "$lower" | grep -qE '^memory:|/tri-agent-memory|memory kurál|kuráld.*memóri|frissítsd.*memory\.md|memória.*kurál|session vége.*memóri'; then
    echo memory
  elif echo "$lower" | grep -qE '^design:|/design|design doc|architekt|system design|tervezd meg|tervezés|adatmodell|api design'; then
    echo design
  elif echo "$lower" | grep -qE 'review|refactor|audit|ellenőriz|vizsgáld|átnézed|code review|nézd át'; then
    if echo "$lower" | grep -qE 'implement|írj|készít|add|fix|javít|fejleszt|build'; then
      echo pipeline
    else
      echo review
    fi
  elif echo "$lower" | grep -qE 'implement|build|fix|add|create|write|script|test|készít|írj|javít|fejleszt|telepít|állíts|konfigurál|csináld'; then
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
  echo "[$id] Codex dolgozik (tri-agent-implement skill)..."
  agent_run_cli codex "Task $id: $desc
$extra
Kötelező skill: $AGENT_SKILL_IMPL — olvasd és kövesd (result.json séma, minimális diff, tesztek). Ne írj MEMORY.md-be."
}

agent_run_verify() {
  local id="$1"
  echo "[$id] Verify (tri-agent-verify)..."
  if [[ -x "$AGENT_SKILL_VERIFY" ]]; then
    "$AGENT_SKILL_VERIFY" "$id" 2>&1 || true
  else
    echo "[$id] Verify: skip (script missing)"
  fi
}

agent_verify_summary() {
  local id="$1"
  local f="$AGENT_TASKS/${id}-verify.json"
  [[ -f "$f" ]] || return 0
  jq -c . "$f" 2>/dev/null | head -c 8000
}

agent_run_claude_review() {
  local id="$1"
  local task_note=""
  [[ -f "$AGENT_TASKS/${id}.task.json" ]] && \
    task_note="Task $id: $(jq -r .description "$AGENT_TASKS/${id}.task.json")"

  local diff staged
  diff=$(git -C "$AGENT_WORK" diff 2>/dev/null | head -c 50000)
  staged=$(git -C "$AGENT_WORK" diff --cached 2>/dev/null | head -c 20000)

  local verify_note
  verify_note=$(agent_verify_summary "$id")

  echo "[$id] Claude review (tri-agent-review skill)..."
  agent_run_cli claude "Code review. $task_note
Kötelező skill: $AGENT_SKILL_REVIEW — olvasd és kövesd (review.json séma, verdict szabályok).
VERIFY: ${verify_note:-nincs}
Írd agents/tasks/${id}-review.json-ba (verdict, findings[], ts).
---
STAGED: $staged
---
UNSTAGED: $diff"
}

agent_collect_memory() {
  local out
  if [[ -x "$AGENT_SKILL_MEMORY_COLLECT" ]]; then
    out=$("$AGENT_SKILL_MEMORY_COLLECT" 2>/dev/null | tail -1)
    echo "${out:-}"
  fi
}

agent_run_memory_curate() {
  local id="$1" desc="${2:-memory kurálás}"
  local collect ctx
  "$AGENT_REFRESH" >/dev/null
  collect=$(agent_collect_memory)
  ctx=""
  [[ -n "$collect" && -f "$collect" ]] && ctx=$(head -c 60000 "$collect")

  echo "[$id] Claude memory kurálás (tri-agent-memory skill)..."
  "$AGENT_RUN_SCRIPT" --full claude "Memory curation. Task $id: $desc
Kötelező skill: $AGENT_SKILL_MEMORY — olvasd references/curation-checklist.md-t is.
Gyűjtött kontextus:
---
${ctx:-nincs collect output}
---
Írd agents/tasks/${id}-memory.json-ba (updated_files, actions, summary, ts).
Frissítsd MEMORY.md indexet és releváns memory/** fájlokat. Ne írj titkot."
}

agent_write_summary() {
  local id="$1" desc="$2" verdict="${3:-}"
  local sum="$AGENT_TASKS/${id}.summary.md"
  local codex_msg review_msg files

  codex_msg=$(jq -r '.message // "—"' "$AGENT_TASKS/${id}.result.json" 2>/dev/null || echo "—")
  review_msg=$(jq -r '.verdict // .status // "—"' "$AGENT_TASKS/${id}-review.json" 2>/dev/null || echo "—")
  verify_msg=$(jq -r '.status // "—"' "$AGENT_TASKS/${id}-verify.json" 2>/dev/null || echo "—")
  files=$(jq -r '.modified_files // [] | join(", ")' "$AGENT_TASKS/${id}.result.json" 2>/dev/null || echo "—")

  {
    echo "# $id — összefoglaló"
    echo ""
    echo "**Feladat:** $desc"
    echo "**Codex:** $codex_msg"
    echo "**Verify:** $verify_msg"
    echo "**Claude:** $review_msg"
    echo "**Fájlok:** $files"
    echo "**Végső:** ${verdict:-$review_msg}"
    echo ""
    echo "Generálva: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  } > "$sum"
  echo "$sum"
}