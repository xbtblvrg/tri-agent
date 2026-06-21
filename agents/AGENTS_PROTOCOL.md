# Tri-Agent Protocol — Grok + Claude + Codex

Közös munkarendszer a `/home/blvrg` workspace-en.

## Belépési pont (user)

```bash
agent-do.sh "feladat"    # vagy: do "feladat" / make do TASK="..."
```

User **csak feladatot mond** — routing, busz, agent választás belső. Lásd `agents/DEV_WORKFLOW.md`.

Az alábbi busz/protokoll **belső** (agent-do és agent-run használja), nem user-facing.

## Szerepkörök

| Agent | CLI | Szerep | Írási jog |
|-------|-----|--------|-----------|
| **Grok** | `grok` / `agent` | Koordinátor — feladatbontás, kiosztás, állapotkövetés | `agents/tasks/*.task.json`, `agents/bus/` |
| **Claude** | `claude -p` | Review + memória-gondnok — kód-review, `MEMORY.md` kurálás | `MEMORY.md`, `memory/**`, review outbox |
| **Codex** | `codex exec` | Implementer — kód, scriptek, tesztek, diff | kódfájlok, `agents/tasks/*.result.json` |

**Egy író per artefaktum.** Soha ne írjon két agent ugyanazt a fájlt.

## Közös memória (single source of truth)

| Réteg | Útvonal | Ki írja |
|-------|---------|---------|
| Hosszú táv | `/home/blvrg/MEMORY.md` | **Csak Claude** (tri-agent-memory skill) |
| Napi log | `/home/blvrg/memory/YYYY-MM-DD.md` | Bárki append-only |
| Döntések | `/home/blvrg/memory/agent-decisions.md` | Grok + Claude append |
| Feladatnapló | `/home/blvrg/memory/agent-task-log.md` | Mindhárom append |
| Rendszer | `/home/blvrg/memory/system/*.md` | **Claude** kurálja (memory skill); Grok/Codex olvas |

**NEM közös** (csak olvasható háttérforrás):
- `~/.claude/projects/-home-blvrg/memory/` — Claude auto-memory
- `~/.codex/sessions/` — Codex session history

Fontos tudás Claude auto-memory-ból → átvezetni `MEMORY.md` vagy napi log alá.

## Kommunikáció

**Fő flow:** `agent-do.sh` → `agents/tasks/T-NNNN.{result,review,verify,memory}.json` (nem busz-alapú).

### Agent bus (legacy / demo)

Üzenet = egy JSON fájl a címzett inboxában. Atomi írás `mv`-vel.

**Útvonal:** `agents/bus/inbox/<to>/<ts>__<from>__<id>.json`

```json
{
  "id": "M-1718966400-a1",
  "from": "grok",
  "to": "codex",
  "task": "T-0001",
  "type": "assign",
  "body": "Feladat leírása",
  "ts": "2026-06-21T09:00:00Z"
}
```

**Típusok:** `assign` | `result` | `review` | `question` | `done` | `blocked`

### Shell parancsok

```bash
# Üzenet küldése
~/agents/bin/agent-send.sh <to> <from> <task-id> <type> "<body>"

# Inbox kiolvasása + archiválás
~/agents/bin/agent-recv.sh <agent-name>

# Agent futtatása egységes wrapperrel
~/agents/bin/agent-run.sh <grok|claude|codex> "<prompt>"
```

## Bootstrap

**Fast mode (alapértelmezett, dev):** `agents/dev/CONTEXT.md` + `agents/roles/<saját>.md`

**Full mode (session vég, MEMORY kurálás):** + `MEMORY.md`, napi log, `agent-decisions.md`

## Munkafolyamat (agent-do)

```
User feladat → agent-do.sh
  ├→ Codex implement (fast)
  ├→ Claude review (git diff)
  ├→ auto-fix ha CHANGES_REQUESTED (1 kör)
  └→ agents/tasks/T-NNNN.summary.md
```

Grok chatben: feladat → `agent-do` azonnal → összefoglaló magyarul.

## Szabályok

- **Titkok:** soha ne írj API key-t, jelszót, tokent memóriába vagy buszra
- **Destructive ops:** `trash` > `rm`; destruktív művelet előtt emberi jóváhagyás
- **Max hop:** 3 agent-hívás láncban (loop védelem)
- **Nyelv:** magyar válaszok a user felé (lásd `memory/preferences/language.md`)