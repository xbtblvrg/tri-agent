---
name: tri-agent-verify
description: >
  Tri-agent post-implement verify skill. Futtatás Codex után, Claude review előtt.
  dev-check, shellcheck, ruff, pytest a diff alapján. Írja agents/tasks/T-NNNN-verify.json.
  Trigger: verify, ellenőrzés, smoke test, agent-do pipeline verify lépés.
---

# Tri-agent-verify

Determinisztikus ellenőrzés implement után, review előtt.

## Futtatás

```bash
skills/tri-agent-verify/scripts/verify.sh T-NNNN
```

## Output

`agents/tasks/T-NNNN-verify.json`:

```json
{
  "id": "T-NNNN",
  "status": "pass|warn|fail",
  "checks": [{"name": "shellcheck", "status": "pass|fail", "detail": "…"}],
  "ts": "2026-06-21T12:00:00Z"
}
```

## Mit ellenőriz

1. Módosított `.sh` → `shellcheck`
2. Módosított `.py` → `ruff check` (ha van), `pytest` (ha van `tests/` vagy `test_*.py`)
3. `Makefile` / `agents/` diff → `make -n check` vagy `dev-check.sh` subset

## Ha fail

Codex auto-fix kör vagy Claude `CHANGES_REQUESTED` — az `agent-do` pipeline kezeli.