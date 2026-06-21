# tri-agent

Grok + Claude + Codex közös fejlesztői rendszer fájl-alapú agent bus-szal.

**User csak a feladatot mondja** — a rendszer automatikusan kiosztja, implementálja, review-zza.

## Disaster recovery (üres gép, egy parancs)

```bash
curl -fsSL https://raw.githubusercontent.com/xbtblvrg/tri-agent/master/bootstrap.sh | bash
```

Utána: `source ~/.config/blvrg/dev-env.sh` → `do "első teszt"`

Részletek: [docs/DISASTER-RECOVERY.md](docs/DISASTER-RECOVERY.md)

## Gyors start (git clone)

```bash
git clone git@github.com:xbtblvrg/tri-agent.git
cd tri-agent
./bootstrap.sh          # teljes felállítás (vagy ./install.sh ~)
source ~/.config/blvrg/dev-env.sh
do "első teszt feladat"
```

## Követelmények

| CLI | Parancs | Bypass |
|-----|---------|--------|
| Grok Build | `grok` | `--always-approve` |
| Claude Code | `claude` | `bypassPermissions` |
| Codex | `codex` | `danger-full-access` |

További eszközök: `git`, `jq`, `rg`, `make` — lásd `make check`

## Használat

```bash
do "add retry logic to foo()"     # Codex → verify → Claude → auto-fix
do "design: új API"               # Grok design doc
do "memory: kuráld a sessiont"   # Claude MEMORY kurálás
make check                         # health check
make status                        # git + tasks
```

## Szerepkörök

| Agent | Szerep |
|-------|--------|
| **Grok** | Koordinátor — user felé, `agent-do` indítás |
| **Codex** | Implementer |
| **Claude** | Review + MEMORY.md gondnok |

## Skillek

| Skill | Agent | Fájl |
|-------|-------|------|
| `tri-agent-do` | Grok | `skills/tri-agent-do/SKILL.md` |
| `tri-agent-implement` | Codex | `skills/tri-agent-implement/SKILL.md` |
| `tri-agent-review` | Claude | `skills/tri-agent-review/SKILL.md` |
| `tri-agent-verify` | Pipeline | `skills/tri-agent-verify/scripts/verify.sh` |
| `tri-agent-memory` | Claude | `skills/tri-agent-memory/SKILL.md` |

## Struktúra

```
agents/
  bin/agent-do.sh      ★ belépési pont
  bin/agent-run.sh     CLI wrapper (fast/full)
  roles/               agent szerepleírások
  bus/                 JSON üzenetsor (belső)
  tasks/               task + result + summary
bin/
  dev-setup.sh         környezet telepítés
  dev-check.sh         health check
  dev-env.sh           shell aliasok (do, devcheck)
docs/                  dokumentáció
```

## Dokumentáció

- [agents/DEV_WORKFLOW.md](agents/DEV_WORKFLOW.md) — munkafolyamat
- [agents/AGENTS_PROTOCOL.md](agents/AGENTS_PROTOCOL.md) — protokoll
- [docs/tri-agent-autonomy.md](docs/tri-agent-autonomy.md) — user preferencia

## Licensz

MIT — szabadon használható, módosítható.