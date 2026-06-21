#!/usr/bin/env bash
# agent-send.sh — üzenet küldése a tri-agent buszra (atomi drop)
# Használat: agent-send.sh <to> <from> <task-id> <type> "<body>"
set -euo pipefail

to="${1:?to required (grok|claude|codex)}"
from="${2:?from required}"
task="${3:?task-id required}"
type="${4:?type required (assign|result|review|question|done|blocked)}"
body="${5:?body required}"

BASE="${BLVRG_WORKSPACE:-$HOME}/agents/bus"
ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)
id="M-$(date +%s)-$RANDOM"
dir="$BASE/inbox/$to"
tmp="$dir/.$id.tmp"

mkdir -p "$dir"

jq -n \
  --arg id "$id" \
  --arg from "$from" \
  --arg to "$to" \
  --arg task "$task" \
  --arg type "$type" \
  --arg body "$body" \
  --arg ts "$ts" \
  '{id:$id, from:$from, to:$to, task:$task, type:$type, body:$body, ts:$ts}' \
  > "$tmp"

mv "$tmp" "$dir/${ts}__${from}__${id}.json"
echo "$id"