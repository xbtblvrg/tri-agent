#!/usr/bin/env bash
# do.sh — tri-agent-do skill wrapper (Grok vagy shell)
set -euo pipefail
work="${BLVRG_WORKSPACE:-$HOME}"
exec "$work/bin/agent-do.sh" "$@"