#!/usr/bin/env bash
# publish-github.sh — GitHub repo létrehozás + push (gh auth szükséges)
set -euo pipefail
cd "$(dirname "$0")/.."

if ! gh auth status >/dev/null 2>&1; then
  echo "gh nincs bejelentkezve. Futtasd:"
  echo "  gh auth login -h github.com -p ssh -w"
  echo "Majd újra: ./bin/publish-github.sh"
  exit 1
fi

gh repo view xbtblvrg/tri-agent >/dev/null 2>&1 || \
  gh repo create xbtblvrg/tri-agent \
    --public \
    --description "Grok + Claude + Codex tri-agent dev system" \
    --source=. \
    --remote=origin \
    --push

git push -u origin master 2>/dev/null || git push -u origin master
echo "✓ https://github.com/xbtblvrg/tri-agent"