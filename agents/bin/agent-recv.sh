#!/usr/bin/env bash
# agent-recv.sh — inbox kiolvasása + archiválás
# Használat: agent-recv.sh <agent-name>
set -euo pipefail

agent="${1:?agent required (grok|claude|codex)}"
work="${BLVRG_WORKSPACE:-$HOME}"
inbox="$work/agents/bus/inbox/$agent"
archive="$work/agents/bus/archive/$agent"
mkdir -p "$archive"

count=0
for f in "$inbox"/*.json; do
  [[ -f "$f" ]] || continue
  cat "$f"
  echo "---"
  mv "$f" "$archive/"
  ((count++)) || true
done

if [[ $count -eq 0 ]]; then
  echo '{"status":"empty","agent":"'"$agent"'"}'
fi