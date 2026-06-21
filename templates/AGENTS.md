# AGENTS.md — Tri-agent workspace

Tri-agent mód: Grok (koordinátor) + Claude (review + MEMORY) + Codex (implementer).

## User szabály

**Csak a feladatot mondod** → `do "feladat"` vagy `agent-do.sh "feladat"`

## Ki vagy? — bináris alapján

| Bináris | Szerep | Skill |
|---------|--------|-------|
| `grok` | Koordinátor | `skills/tri-agent-do/SKILL.md` |
| `claude` | Review + MEMORY | `skills/tri-agent-review/SKILL.md`, `tri-agent-memory` |
| `codex` | Implementer | `skills/tri-agent-implement/SKILL.md` |

## Pipeline

`agent-do.sh` → Codex → verify → Claude → summary

## Memória

- **Claude** írja: `MEMORY.md`, `memory/**`
- **Codex/Grok** csak olvassa

Lásd: `agents/AGENTS_PROTOCOL.md`