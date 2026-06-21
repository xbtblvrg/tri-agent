#!/usr/bin/env bash
# bootstrap.sh — üres gépről teljes tri-agent felállítás (egy parancs)
# Használat (üres gépen):
#   curl -fsSL https://raw.githubusercontent.com/xbtblvrg/tri-agent/master/bootstrap.sh | bash
# Vagy:
#   curl -fsSL ... | BLVRG_WORKSPACE=$HOME bash
set -euo pipefail

TARGET="${BLVRG_WORKSPACE:-$HOME}"
REPO_URL="${TRI_AGENT_REPO:-https://github.com/xbtblvrg/tri-agent.git}"
CLONE_DIR="${TRI_AGENT_CLONE:-$TARGET/tri-agent}"
BRANCH="${TRI_AGENT_BRANCH:-master}"

log() { echo "[bootstrap] $*"; }
die() { echo "[bootstrap] HIBA: $*" >&2; exit 1; }

log "Tri-agent bootstrap"
log "Workspace: $TARGET"
log "Repo: $REPO_URL"

# --- 1. Alap eszközök (Debian/Ubuntu / Raspberry Pi OS) ---
if command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    git curl ca-certificates jq shellcheck build-essential \
    python3 python3-venv python3-pip \
    nodejs npm ripgrep fd-find fzf git-delta libffi-dev \
    2>/dev/null || sudo apt-get install -y git curl jq shellcheck python3 nodejs npm
else
  log "apt-get nincs — feltételezzük, hogy git/curl/jq/node/python telepítve van"
fi

command -v git >/dev/null || die "git hiányzik"
command -v curl >/dev/null || die "curl hiányzik"

# --- 2. Repo klón / frissítés ---
if [[ -d "$CLONE_DIR/.git" ]]; then
  log "Repo frissítés: $CLONE_DIR"
  git -C "$CLONE_DIR" fetch origin "$BRANCH"
  git -C "$CLONE_DIR" checkout "$BRANCH"
  git -C "$CLONE_DIR" pull --ff-only origin "$BRANCH" 2>/dev/null || true
else
  log "Klón: $CLONE_DIR"
  mkdir -p "$(dirname "$CLONE_DIR")"
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" "$CLONE_DIR"
fi

# --- 3. Workspace telepítés ---
BLVRG_WORKSPACE="$TARGET" bash "$CLONE_DIR/install.sh" "$TARGET"

# --- 4. Dev környezet (apt, venv, npm global, ssh key) ---
if [[ -x "$TARGET/bin/dev-setup.sh" ]]; then
  BLVRG_WORKSPACE="$TARGET" "$TARGET/bin/dev-setup.sh"
fi

# --- 5. AI CLI-k (npm / grok) ---
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/bin:$PATH"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global" 2>/dev/null || true

if ! command -v claude >/dev/null 2>&1; then
  log "Claude Code telepítés (npm)..."
  npm install -g @anthropic-ai/claude-code 2>/dev/null || log "Claude npm install sikertelen — telepítsd kézzel"
fi

if ! command -v codex >/dev/null 2>&1; then
  log "Codex CLI telepítés (npm)..."
  npm install -g @openai/codex 2>/dev/null || log "Codex npm install sikertelen — telepítsd kézzel"
fi

if ! command -v grok >/dev/null 2>&1; then
  log "Grok CLI nincs — telepítsd: https://github.com/xai-org/grok-cli (vagy xAI installer)"
  log "  Utána: permission_mode = always-approve a ~/.grok/config.toml-ban"
fi

# --- 6. Health check (install.sh már futtatta setup-agent-configs + setup-skills) ---
log "Health check..."
if [[ -x "$TARGET/bin/dev-check.sh" ]]; then
  BLVRG_WORKSPACE="$TARGET" "$TARGET/bin/dev-check.sh" || true
fi

log ""
log "════════════════════════════════════════════════════════"
log "✓ Tri-agent bootstrap kész"
log "  Workspace: $TARGET"
log "  Repo (frissítéshez): $CLONE_DIR"
log ""
log "  source ~/.config/blvrg/dev-env.sh"
log "  do \"első teszt feladat\""
log ""
log "  Egyszeri auth (ha még nincs):"
log "    claude login / API key"
log "    codex login"
log "    grok login"
log "════════════════════════════════════════════════════════"