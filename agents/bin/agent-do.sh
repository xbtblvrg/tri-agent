#!/usr/bin/env bash
# agent-do.sh — te csak a feladatot mondod, mi megoldjuk
# Használat: agent-do.sh "bármi feladat"
set -euo pipefail

source "$(dirname "$0")/agent-lib.sh"

desc="${*:-}"
if [[ -z "$desc" ]]; then
  echo "Használat: agent-do.sh \"feladat leírása\"" >&2
  exit 1
fi

kind=$(agent_classify "$desc")
id=$(agent_next_id)

echo "▶ Feladat: $desc"
echo "▶ Mód: $kind | ID: $id"
echo ""

case "$kind" in
  question)
    agent_write_task "$id" "$desc" "active" "auto"
    agent_run_cli grok "$desc — válaszolj röviden, magyarul."
    agent_append_log "$id" "$desc" "grok" "válasz"
    ;;
  design)
    agent_write_task "$id" "$desc" "active" "auto"
    echo "[$id] Design (Grok /design skill)..."
    agent_run_cli grok "Design doc készítés. Feladat: $desc
Kövesd: $AGENT_WORK/.grok/bundled/skills/design/SKILL.md
Írd: agents/tasks/${id}-design.md (magyarul, tömör). Ne implementálj még."
    agent_append_log "$id" "$desc" "grok" "design doc"
    ;;
  review)
    agent_write_task "$id" "$desc" "active" "auto"
    agent_run_claude_review "$id"
    agent_append_log "$id" "$desc" "claude" "review kész"
    agent_write_summary "$id" "$desc"
    ;;
  pipeline|*)
    agent_write_task "$id" "$desc" "active" "auto"

    # 1. Implement (tri-agent-implement skill)
    agent_run_codex "$id" "$desc"

    # 2. Verify (tri-agent-verify)
    agent_run_verify "$id"

    # 3. Review (tri-agent-review skill)
    agent_run_claude_review "$id"
    verdict=$(agent_review_verdict "$id" || echo "UNKNOWN")

    # 4. Auto-fix ha kell (max 1 kör)
    if echo "$verdict" | grep -qiE 'CHANGES_REQUESTED|BLOCKED'; then
      echo "[$id] Review: $verdict → Codex javít..."
      findings=$(jq -r '.findings // [.verdict] | join("; ")' \
        "$AGENT_TASKS/${id}-review.json" 2>/dev/null || echo "$verdict")
      agent_run_codex "$id" "Javítsd a review megjegyzéseit: $findings" \
        "Előző result: agents/tasks/${id}.result.json. Frissítsd ugyanazt a result fájlt."
      agent_run_verify "$id"
      agent_run_claude_review "$id"
      verdict=$(agent_review_verdict "$id" || echo "UNKNOWN")
    fi

    agent_append_log "$id" "$desc" "auto (codex→claude)" "$verdict"
    summary=$(agent_write_summary "$id" "$desc" "$verdict")

    echo ""
    echo "════════════════════════════════════"
    cat "$summary"
    echo "════════════════════════════════════"
    ;;
esac