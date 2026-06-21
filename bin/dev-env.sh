#!/usr/bin/env bash
# dev-env.sh — fejlesztői környezet (source: . ~/.config/blvrg/dev-env.sh)
# Telepítve: 2026-06-21

export BLVRG_WORKSPACE="${BLVRG_WORKSPACE:-$HOME}"
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.local/venv/dev/bin:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.grok/bin:$PATH"

# Debian: bat → batcat, fd → fdfind
command -v batcat >/dev/null 2>&1 && alias bat=batcat
command -v fdfind >/dev/null 2>&1 && alias fd=fdfind

# Tri-agent — user csak feladatot mond
alias do='agent-do.sh'
alias devcheck='dev-check.sh'
alias devstatus='agent-dev.sh status'

# Gyors navigáció
alias ws='cd "$BLVRG_WORKSPACE"'
alias agents='cd "$BLVRG_WORKSPACE/agents"'

# Git kényelem
alias gs='git status -sb'
alias gd='git diff'
alias gl='git log --oneline -15'

# Színes diff ha van delta/bat
if command -v batcat >/dev/null 2>&1; then
  export PAGER=batcat
fi