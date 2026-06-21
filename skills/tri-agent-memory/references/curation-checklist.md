# Memory curation checklist

## Olvasás (kötelező)

- [ ] `MEMORY.md` — jelenlegi index állapot
- [ ] `memory/YYYY-MM-DD.md` — mai session
- [ ] `memory/agent-decisions.md` — meglévő döntések
- [ ] Utolsó task summary-k (`agents/tasks/T-*-summary.md`)

## Döntés — mit érdemes megőrizni?

Megőrizd ha:
- Új rendszer / tool / workflow bevezetve
- User preferencia változott
- Döntés hatással van jövőbeli munkára
- Host/config fact változott

Ne őrizd ha:
- Egyszeri teszt output
- Már dokumentált és nem változott
- Task-szintű implement részlet (summary elég)

## Írás (prioritás)

1. Forrásfájl frissítés (`memory/system/`, `memory/preferences/`)
2. `MEMORY.md` index sor + link
3. `agent-decisions.md` append — csak új, jelentős döntés
4. `memory.json` report

## Minőség

- Rövid, scan-elhető mondatok
- Magyar ha user-facing fact; angol OK technikai indexhez
- Link out, ne duplikálj