#!/usr/bin/env bash
# dev-setup.sh — fejlesztői környezet telepítés / javítás (idempotens)
set -euo pipefail

work="${BLVRG_WORKSPACE:-$HOME}"
log() { echo "[dev-setup] $*"; }

log "Workspace: $work"

# Apt eszközök (ha hiányoznak)
missing=()
for pkg in ripgrep fd-find shellcheck build-essential jq git gh fzf libffi-dev git-delta; do
  dpkg -s "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  log "Telepítés: ${missing[*]}"
  sudo apt-get install -y "${missing[@]}"
fi

# Config könyvtár
mkdir -p "$HOME/.config/blvrg"
mkdir -p "$work/agents/dev"
mkdir -p "$work/bin"

# dev-env symlink
ln -sf "$work/bin/dev-env.sh" "$HOME/.config/blvrg/dev-env.sh"

# Bashrc hook (egyszer)
hook='# >>> blvrg dev-env >>>'
if ! grep -qF 'blvrg dev-env' "$HOME/.bashrc" 2>/dev/null; then
  cat >>"$HOME/.bashrc" <<'EOF'

# >>> blvrg dev-env >>>
[[ -f "$HOME/.config/blvrg/dev-env.sh" ]] && source "$HOME/.config/blvrg/dev-env.sh"
# <<< blvrg dev-env <<<
EOF
  log "bashrc frissítve (dev-env source)"
fi

# Git alapbeállítások (ha nincs)
git config --global init.defaultBranch master 2>/dev/null || true
git config --global pull.rebase false 2>/dev/null || true
git config --global core.editor "nano" 2>/dev/null || true

# Agent script symlinks
for s in agent-do agent-dev agent-run agent-send agent-recv agent-dispatch; do
  [[ -f "$work/agents/bin/${s}.sh" ]] && \
    ln -sf "$work/agents/bin/${s}.sh" "$work/bin/${s}.sh"
done
chmod +x "$work/bin/"*.sh "$work/agents/bin/"*.sh 2>/dev/null || true

# Python dev venv
if [[ ! -x "$HOME/.local/venv/dev/bin/pytest" ]]; then
  log "Python venv létrehozás..."
  python3 -m venv "$HOME/.local/venv/dev"
  "$HOME/.local/venv/dev/bin/pip" install -U pip pytest ruff black
fi

# Node dev globals
if ! command -v tsc >/dev/null 2>&1; then
  log "npm global: typescript eslint prettier"
  npm install -g typescript eslint prettier
fi

# SSH key (ha nincs)
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
  log "SSH kulcs generálás..."
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  ssh-keygen -t ed25519 -f "$HOME/.ssh/id_ed25519" -N "" -C "blvrg@$(hostname)"
  chmod 600 "$HOME/.ssh/id_ed25519"
fi

# Context refresh
"$work/agents/bin/agent-context-refresh.sh" >/dev/null

log "Health check..."
"$work/bin/dev-check.sh" || true

log "Kész. Új shell-ben: do \"feladat\" | devcheck | devstatus"