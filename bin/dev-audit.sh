#!/usr/bin/env bash
# dev-audit.sh — konzisztencia ellenőrzés (doksi + script + symlink)
set -uo pipefail

work="${BLVRG_WORKSPACE:-$HOME}"
ok=0 fail=0

pass() { printf "  \033[32m✓\033[0m %s\n" "$1"; ok=$((ok + 1)); }
fail() { printf "  \033[31m✗\033[0m %s\n" "$1"; fail=$((fail + 1)); }

echo "═══ Konzisztencia audit ═══"

# Egy belépési pont
for doc in AGENTS.md agents/DEV_WORKFLOW.md memory/preferences/tri-agent-autonomy.md; do
  grep -q 'agent-do' "$work/$doc" 2>/dev/null && pass "$doc → agent-do" || fail "$doc hiányzik agent-do"
done

# Script lánc
test -x "$work/bin/agent-do.sh" && pass "bin/agent-do.sh executable" || fail "agent-do missing"
readlink -f "$work/bin/agent-do.sh" | grep -q 'agents/bin/agent-do' && pass "agent-do symlink OK" || fail "agent-do symlink"

# dispatch → do
grep -q 'agent-do.sh' "$work/agents/bin/agent-dispatch.sh" && pass "dispatch → do" || fail "dispatch chain"

# dev-env bashrc
grep -q 'blvrg dev-env' "$work/.bashrc" && pass "bashrc dev-env hook" || fail "bashrc hook"

# Jogosultságok
jq -e '.permissions.defaultMode == "bypassPermissions"' "$HOME/.claude/settings.json" >/dev/null 2>&1 \
  && pass "Claude bypass" || fail "Claude bypass"
grep -q 'danger-full-access' "$HOME/.codex/config.toml" 2>/dev/null \
  && pass "Codex full access" || fail "Codex sandbox"
grep -q 'always-approve' "$HOME/.grok/config.toml" 2>/dev/null \
  && pass "Grok always-approve" || fail "Grok approve"

# Nincs ellentmondó primary entry
! grep -q 'prefer: agent-dev' "$work/agents/bin/agent-dispatch.sh" 2>/dev/null \
  && pass "dispatch nem agent-dev-re mutat" || fail "dispatch stale ref"

echo ""
printf "Eredmény: %d OK, %d FAIL\n" "$ok" "$fail"
exit $(( fail > 0 ))