# MEMORY.md — Workspace Long-Term Memory

Curated long-term memory. Claude kurálja (`tri-agent-memory` skill).

## Organization

- **This file** = scannable index
- `memory/system/` = machine facts
- `memory/preferences/` = user preferences
- `memory/YYYY-MM-DD.md` = daily session log

## Key facts

- **Tri-agent:** Grok + Claude + Codex — see [memory/system/tri-agent.md](memory/system/tri-agent.md)
- **Bootstrap:** `curl -fsSL .../bootstrap.sh | bash` — disaster recovery

## Conventions

- Link out, don't duplicate
- No secrets in memory files