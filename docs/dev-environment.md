# Fejlesztői környezet — blvrg-raspberrypi5

Teljes dev setup a `/home/blvrg` workspace-en. Frissítve: 2026-06-21.

## Hardver / OS

- Raspberry Pi 5 (aarch64), Raspberry Pi OS / Debian trixie
- 8 GB RAM, kernel 6.18.x
- Lásd: [host.md](host.md)

## Nyelvek

| Nyelv | Verzió | Útvonal |
|-------|--------|---------|
| Node.js | 22.x | `~/.npm-global/bin` |
| Python | 3.13 | `/usr/bin/python3` |
| Go | 1.24 | `~/go/bin` |

## CLI eszközök

| Eszköz | Parancs | Megjegyzés |
|--------|---------|------------|
| git, jq, make, gcc/g++ | apt | build-essential |
| ripgrep | `rg` | apt: ripgrep |
| fd | `fdfind` vagy alias `fd` | apt: fd-find |
| bat | `batcat` (alias `bat`) | Debian név |
| fzf, gh, curl, wget | apt | |
| shellcheck | `shellcheck` | shell lint |
| delta | `delta` | színes git diff (apt: git-delta) |
| docker | `docker` + `docker compose` | docker csoport |

## Python dev venv

Útvonal: `~/.local/venv/dev/` — pytest, ruff, black (PEP 668 miatt venv-ben, nem system pip).

## Node dev (global npm)

TypeScript (`tsc`), ESLint, Prettier — `~/.npm-global/bin`

## Git + SSH

- `user.name=blvrg`, `user.email=belavarga@me.com`
- `core.pager=delta`
- SSH: `~/.ssh/id_ed25519` + `~/.ssh/config` (github.com, gitlab.com)
- **GitHub:** add public key at https://github.com/settings/keys

## Tri-agent (fejlesztés)

| CLI | Verzió | Bypass |
|-----|--------|--------|
| Grok | ~/.grok | always-approve |
| Claude | ~/.local/bin/claude | bypassPermissions |
| Codex | ~/.npm-global/bin/codex | danger-full-access |

**User flow:** csak feladatot mond → `do "feladat"` vagy `make do TASK="..."`

## Parancsok

```bash
make setup          # teljes környezet telepítés (idempotens)
make check          # health check
make status         # git + tasks
make do TASK="..."  # feladat → Codex → Claude → auto-fix

do "feladat"        # alias (shell-ben, dev-env után)
devcheck            # alias → dev-check.sh
devstatus           # alias → agent-dev.sh status
```

## Shell integráció

`~/.config/blvrg/dev-env.sh` — PATH (`~/bin`), aliasok, bat/fd aliasok.
Automatikusan betöltődik `.bashrc`-ből.

## Workspace fájlok

| Fájl | Cél |
|------|-----|
| `.editorconfig` | Egységes formázás |
| `Makefile` | `make check/setup/do` |
| `CLAUDE.md` | Claude bootstrap |
| `agents/` | Tri-agent infrastruktúra |
| `bin/dev-*.sh` | Setup, check, env |

## Git

- Repo: `/home/blvrg` (master)
- `.gitignore` — AI state, secrets, caches kizárva; `agents/`, `skills/`, docs tracked

## Kapcsolódó

- [tri-agent.md](tri-agent.md) — multi-agent workflow
- [autonomy.md](../preferences/autonomy.md) — ne kérdezz, futtasd
- [tri-agent-autonomy.md](../preferences/tri-agent-autonomy.md) — user csak feladatot mond