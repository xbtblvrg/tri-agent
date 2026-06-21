# Workflow matrix — minden belépési pont

## Egyetlen igazság

| User mond | Bárki indítja | Mi történik |
|-----------|---------------|-------------|
| Feladat (implement/fix/feature) | Grok / Claude / Codex | → `agent-do.sh` → Codex → verify → Claude → auto-fix |
| Design / architektúra | Grok | → `agent-do.sh` design: → Grok `/design` |
| Memory kurálás | Claude | → `agent-do.sh` memory: → tri-agent-memory skill |
| Kérdés (mi/hogyan) | Grok | közvetlen válasz |
| Csak review | bárki | → `agent-do` review mód VAGY Claude diff review |

## Belépési pontok

| Indítás | Tri-agent tudja? | Feladatnál mit csinál? |
|---------|------------------|------------------------|
| **Grok** (chat) | ✓ AGENTS.md + rules | `agent-do.sh` |
| **Claude** `claude` | ✓ `.claude/CLAUDE.md` | `agent-do.sh` (nem implementál) |
| **Codex** `codex` | ✓ ~/.codex/AGENTS.md + AGENTS.md | implement VAGY `agent-do.sh` feature-nél |
| **`do "…"`** | ✓ | teljes pipeline |
| **`agent-run.sh X`** | ✓ bootstrap prompt | egy agent, egy lépés |

## Adatfolyam (feladat)

```
User feladat
  → agent-do (classify)
    → pipeline: Codex implement → Claude review → [Codex fix] → summary.md
    → review:   Claude only
    → question: Grok only
  → Grok összefoglalja usernek (chat)
```

## Busz (mellék)

`agents/bus/` — opcionális, `agent-send/recv` — manuális/demo. **Fő flow: agent-do** (nem busz-alapú).

## Memória írási jog

| Fájl | Grok | Claude | Codex |
|------|------|--------|-------|
| MEMORY.md | olvas | **ír** | olvas |
| memory/YYYY-MM-DD.md | append | append | append |
| agents/tasks/*.json | olvas | ír review | ír result |
| kódfájlok | — | — | **ír** |

## Konzisztencia ellenőrzés

```bash
dev-audit.sh    # doksi + symlink + jogosultság
make check      # eszközök + CLI
```