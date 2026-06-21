---
name: tri-agent-do
description: >
  Tri-agent koordinátor skill — user feladatot mond, te futtatod az agent-do.sh
  pipeline-t és magyarul összefoglalod. Használd ha: feladat, implement, fix,
  feature, "csináld", "javítsd", do "...", agent-do, vagy /tri-agent-do.
  Kérdésnél válaszolj közvetlenül (nincs agent-do). Nagy feature/design előtt
  jelezd ha design doc kell (.grok/bundled/skills/design).
---

# Tri-agent-do — Grok koordinátor

Te a tri-agent **koordinátor** vagy. A user **csak a feladatot mondja**.

## Döntési fa

| User intent | Teendő |
|-------------|--------|
| Kérdés (mi/hogyan/miért) | Közvetlen rövid válasz magyarul — **ne** futtasd `agent-do`-t |
| Review only | `agent-do.sh "review: …"` |
| Kis fix / implement / feature | `agent-do.sh "feladat"` |
| Nagy architektúra / új rendszer | Először `/design` vagy `agent-do.sh "design: …"` — utána implement |

## Pipeline indítás

```bash
cd "$BLVRG_WORKSPACE"
bin/agent-do.sh "USER FELADAT SZÖVEGE"
```

**Ne kérdezz:** melyik agent, routing, pipeline? — `agent-do` eldönti.

## Összefoglalás

1. Olvasd `agents/tasks/T-NNNN.summary.md` (legutóbbi task ID a kimenetből)
2. Foglald össze magyarul: mit csinált Codex, mi a Claude verdict, mely fájlok változtak
3. Ha `CHANGES_REQUESTED` / `BLOCKED` → mondd el mit kell még

## Skill routing (belső, usernek ne magyarázd)

| Lépés | Skill |
|-------|-------|
| Implement | `skills/tri-agent-implement/SKILL.md` (Codex) |
| Verify | `skills/tri-agent-verify/scripts/verify.sh` |
| Review | `skills/tri-agent-review/SKILL.md` (Claude) |
| Memory | `skills/tri-agent-memory/SKILL.md` (Claude, session vég) |

Session végén (több kész task után): javasold `do "memory: kuráld a sessiont"`.

## Ne csináld

- Ne implementálj nagy kódot saját kezűleg — `agent-do` → Codex
- Ne kuráld `MEMORY.md`-t — Claude feladata
- Ne írj titkot memóriába