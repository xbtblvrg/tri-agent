# Tri-agent rendszer — Grok + Claude + Codex

Bevezetve: 2026-06-21. A három CLI agent közös munkarendszere.

## CLI eszközök

| Agent | Bináris | Nem interaktív |
|-------|---------|----------------|
| Grok | `~/.local/bin/grok` / `agent` | `grok -p "..." --always-approve` |
| Claude | `~/.local/bin/claude` (v2.1.183) | `claude -p "..."` |
| Codex | `~/.npm-global/bin/codex` (v0.139.0) | `codex exec "..."` |

## Szerepkörök

- **Grok** = koordinátor (feladatkiosztás, állapotkövetés)
- **Claude** = review + `MEMORY.md` gondnok
- **Codex** = implementer (kód, scriptek, tesztek)

## Fájlstruktúra

```
agents/
  AGENTS_PROTOCOL.md    # közös protokoll
  roles/{grok,claude,codex}.md
  bus/inbox/{grok,claude,codex}/   # JSON üzenetek
  bus/archive/                      # feldolgozott üzenetek
  tasks/T-NNNN.{task,result}.json
  dev/CONTEXT.md        # fast mode cache (git, tasks)
  bin/
    agent-do.sh         # ★ belépés (user)
    agent-dev.sh        # status, refresh (dev)
    agent-run.sh        # CLI wrapper (fast/full)
    agent-send.sh       # bus (belső)
    agent-recv.sh       # bus (belső)
    agent-dispatch.sh   # legacy → agent-do
```

## Közös memória rétegek

1. `MEMORY.md` — hosszú távú index (Claude kurálja)
2. `memory/YYYY-MM-DD.md` — napi log (bárki append)
3. `memory/agent-decisions.md` — döntések
4. `memory/agent-task-log.md` — feladatnapló

**NEM közös:** `~/.claude/projects/-home-blvrg/memory/` (Claude auto-memory, csak importforrás)

## User flow (egyetlen szabály)

**Te csak a feladatot mondod.** Mi megoldjuk:

```bash
agent-do.sh "bármi feladat"
```

Belsőleg: Codex implement → Claude review → auto-fix ha kell → összefoglaló.

Grok chatben ugyanez: feladat érkezik → `agent-do` automatikusan, routing kérdés nélkül.

Fast mode alapértelmezett: `agents/dev/CONTEXT.md` (git, branch) — nem olvassa újra MEMORY.md minden híváskor.

Részletek: `agents/DEV_WORKFLOW.md`

## Legacy parancsok

```bash
~/agents/bin/agent-send.sh codex grok T-0001 assign "..."
~/agents/bin/agent-run.sh --fast claude "..."
~/agents/bin/agent-dispatch.sh T-0001 "..." pipeline
```

## Kapcsolódó

- [memory-stack.md](memory-stack.md) — régi 3-rétegű memória (Claude auto + workspace + semantic)
- [agents/AGENTS_PROTOCOL.md](../../agents/AGENTS_PROTOCOL.md) — teljes protokoll