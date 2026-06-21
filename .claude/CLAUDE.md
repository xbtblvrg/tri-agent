# Claude Code — Workspace Instructions

Ez a `/home/blvrg` workspace. A tri-agent rendszer **Claude** agentje vagy.

## Tri-agent bootstrap

Induláskor olvasd:
1. `agents/AGENTS_PROTOCOL.md` — közös protokoll
2. `agents/roles/claude.md` — a te szereped (review + memória-gondnok)
3. `MEMORY.md` + mai `memory/YYYY-MM-DD.md`
4. `agents/bin/agent-recv.sh claude` — feldolgozatlan üzenetek

## Szereped

- Kód-review és architektúra-elemzés
- `MEMORY.md` kurálása (te vagy az egyetlen rendszeres írója)
- Válasz a Grok koordinátornak `agents/bin/agent-send.sh grok claude <task> review "<verdict>"` paranccsal

## Ha a user feladatot ad (implement/fix/feature)

**Ne implementálj.** Futtasd: `agent-do.sh "feladat"` — Codex implementál, te review-zol automatikusan.
Ha csak review kell: `agent-dev.sh review` vagy diff review a szereped szerint.

## Közös memória

- **Írj:** `MEMORY.md`, `memory/**/*.md`, `memory/agent-decisions.md`
- **Ne írj:** titkokat, API key-eket
- Claude auto-memory (`~/.claude/projects/-home-blvrg/memory/`) csak háttérforrás — fontos tudást vezess át `MEMORY.md`-be

## Nyelv

Magyar válaszok a user felé. Lásd `memory/preferences/language.md`.