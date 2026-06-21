# Dev Workflow — user csak feladatot mond

## User szempontból

```
Te: "Add retry logikát a foo()-hoz"
Mi:  agent-do → Codex implement → Claude review → auto-fix → összefoglaló
```

**Nincs parancs, nincs routing, nincs agent választás.**

## Egy belépési pont

```bash
agent-do.sh "bármi feladat"
```

## Belső flow (automatikus)

```
agent-do.sh
  ├─ classify (kérdés → Grok | review → Claude | feladat → pipeline)
  ├─ Codex implement (fast mode)
  ├─ Claude review (git diff)
  ├─ ha CHANGES_REQUESTED → Codex fix (1 kör)
  └─ summary.md → Grok összefoglalja a usernek
```

## Grok (chat) viselkedés

Feladat érkezik → `agent-do.sh` azonnal → összefoglaló magyarul.

Kérdés érkezik → közvetlen válasz, nincs agent-do.

## Jogosultságok

Mind bypass: Claude `bypassPermissions`, Codex `danger-full-access`, Grok `always-approve`.

## Közös memória

Task közben: `agents/tasks/*.json` + napi log.
`MEMORY.md`: session végén, nem minden feladatnál.