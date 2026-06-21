#!/usr/bin/env bash
# dev-check.sh — teljes fejlesztői környezet health check
set -uo pipefail

work="${BLVRG_WORKSPACE:-$HOME}"
ok=0 fail=0 warn=0

export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.local/venv/dev/bin:$HOME/.npm-global/bin:$HOME/go/bin:$PATH"

check() {
  local name="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "  \033[32m✓\033[0m %s\n" "$name"
    ok=$((ok + 1))
  else
    printf "  \033[31m✗\033[0m %s\n" "$name"
    fail=$((fail + 1))
  fi
}

warn_check() {
  local name="$1" cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    printf "  \033[32m✓\033[0m %s\n" "$name"
    ok=$((ok + 1))
  else
    printf "  \033[33m!\033[0m %s (opcionális)\n" "$name"
    warn=$((warn + 1))
  fi
}

echo "═══ Dev Environment Check ═══"
echo "Workspace: $work"
echo ""

echo "▸ Nyelvek"
check "Node $(node -v 2>/dev/null)" "node -v"
check "npm $(npm -v 2>/dev/null)" "npm -v"
check "Python $(python3 --version 2>/dev/null)" "python3 --version"
check "Go $(go version 2>/dev/null | awk '{print $3}')" "go version"
warn_check "Rust" "rustc --version"

echo ""
echo "▸ CLI eszközök"
check "git" "git --version"
check "jq" "jq --version"
check "rg (ripgrep)" "rg --version"
check "fd" "fdfind --version || fd --version"
check "fzf" "fzf --version"
check "shellcheck" "shellcheck --version"
check "make/gcc" "make --version && gcc --version"
check "gh" "gh --version"
check "docker" "docker --version"
warn_check "docker compose" "docker compose version"
check "delta (git diff)" "delta --version"
check "SSH key" "test -f $HOME/.ssh/id_ed25519"
check "git user.email" "git config user.email | grep -q @"

echo ""
echo "▸ Python dev (venv)"
check "pytest" "pytest --version"
check "ruff" "ruff --version"
check "black" "black --version"

echo ""
echo "▸ Node dev (global)"
check "TypeScript" "tsc --version"
check "ESLint" "eslint --version"
check "Prettier" "prettier --version"

echo ""
echo "▸ Tri-agent CLIs"
check "grok $(grok --version 2>/dev/null | head -1 || echo '')" "command -v grok"
check "claude" "command -v claude && claude --version 2>/dev/null | head -1"
check "codex $(codex --version 2>/dev/null | head -1 || true)" "command -v codex"

echo ""
echo "▸ Tri-agent scripts"
for s in agent-do agent-dev agent-run agent-send; do
  check "$s.sh" "test -x $work/bin/${s}.sh"
done
check "AGENTS_PROTOCOL.md" "test -f $work/agents/AGENTS_PROTOCOL.md"
check "dev CONTEXT" "test -f $work/agents/dev/CONTEXT.md"

echo ""
echo "▸ Jogosultságok"
claude_mode=$(jq -r '.permissions.defaultMode // "?"' "$HOME/.claude/settings.json" 2>/dev/null)
codex_mode=$(grep -E '^sandbox_mode' "$HOME/.codex/config.toml" 2>/dev/null | head -1 || echo "?")
grok_mode=$(grep -E '^permission_mode' "$HOME/.grok/config.toml" 2>/dev/null | head -1 || echo "?")
printf "  Claude: %s\n" "$claude_mode"
printf "  Codex:  %s\n" "$codex_mode"
printf "  Grok:   %s\n" "$grok_mode"

echo ""
echo "▸ Git"
branch=$(git -C "$work" branch --show-current 2>/dev/null || echo "?")
changes=$(git -C "$work" status --short 2>/dev/null | wc -l)
printf "  Branch: %s | Változások: %s\n" "$branch" "$changes"

echo ""
echo "═══════════════════════════════"
printf "Eredmény: %d OK, %d FAIL, %d WARN\n" "$ok" "$fail" "$warn"
[[ $fail -eq 0 ]] && exit 0 || exit 1