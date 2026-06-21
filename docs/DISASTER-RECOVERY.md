# Disaster recovery — tri-agent teljes felállítás

Ha a gép elszállt vagy újra kell építeni a rendszert, **egy parancs** felállítja a tri-agent workspace-et.

## Egy parancs (üres Debian/Ubuntu/Raspberry Pi OS)

```bash
curl -fsSL https://raw.githubusercontent.com/xbtblvrg/tri-agent/master/bootstrap.sh | bash
```

Opcionális workspace útvonal:

```bash
curl -fsSL https://raw.githubusercontent.com/xbtblvrg/tri-agent/master/bootstrap.sh | BLVRG_WORKSPACE="$HOME" bash
```

## Mit csinál a bootstrap?

1. `apt` — git, curl, jq, shellcheck, python3, nodejs, npm, rg, fd, …
2. `git clone` → `~/tri-agent` (frissítéshez megtartja)
3. `install.sh` → `~/agents`, `~/bin`, `~/skills`, `~/memory`, …
4. `dev-setup.sh` — venv, npm global, SSH key, bashrc hook
5. Claude + Codex npm telepítés (ha hiányzik)
6. Agent config sablonok (`~/.grok`, `~/.claude`, `~/.codex`)
7. Skill symlink-ek
8. `dev-check.sh` health check

## Utána (egyszeri, kézi)

Az AI CLI-k auth-ja **nem** automatizálható:

```bash
source ~/.config/blvrg/dev-env.sh
claude login          # vagy ANTHROPIC_API_KEY
codex login           # vagy OPENAI_API_KEY
grok login            # xAI auth
```

Grok CLI telepítés ha a bootstrap nem találta:

```bash
# xAI Grok CLI — lásd https://github.com/xai-org/grok-cli
```

## Ellenőrzés

```bash
devcheck              # 32+ OK várható
do "mi a tri-agent?"  # smoke teszt
```

## Frissítés meglévő gépen

```bash
cd ~/tri-agent && git pull && ./install.sh ~ && ./bin/setup-skills.sh ~
```

## SSH GitHub (opcionális)

Bootstrap generál `~/.ssh/id_ed25519`-et ha nincs. Add hozzá GitHub-hoz:

```bash
cat ~/.ssh/id_ed25519.pub
gh auth login
```