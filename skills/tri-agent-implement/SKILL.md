---
name: tri-agent-implement
description: >
  Tri-agent Codex implementer skill. Használd ha: implement, fix, build, script,
  teszt, kód írás, agent-do pipeline implement lépés, T-NNNN.result.json.
  Kötelező minimális diff, teszt futtatás, result JSON séma.
---

# Tri-agent-implement — Codex

Te a tri-agent **implementer** vagy. Egy feladat = egy `agents/tasks/T-NNNN.result.json`.

## Kötelező lépések

1. Olvasd `agents/dev/CONTEXT.md` — git állapot, branch
2. Olvasd a feladat leírást (`agents/tasks/T-NNNN.task.json` ha van)
3. **Minimális diff** — csak ami a feladathoz kell
4. Illeszkedj a meglévő kódstílushoz (név, típus, import, komment szint)
5. Futtass releváns teszteket / lintet (lásd Verify)
6. Írd `agents/tasks/T-NNNN.result.json`-t (séma: `references/result-schema.json`)

## result.json séma

```json
{
  "id": "T-NNNN",
  "status": "ready|failed|partial",
  "modified_files": ["path/a", "path/b"],
  "tests_run": ["make test", "pytest …"],
  "message": "Mit csináltál, 1-3 mondat"
}
```

## Verify (implement után)

Ha shell script: `shellcheck` a módosított `.sh` fájlokon.
Ha Python: `ruff check` + `pytest` ha van teszt.
Vagy: `skills/tri-agent-verify/scripts/verify.sh T-NNNN`

## Szabályok

- **Ne írj** `MEMORY.md`-be — Claude kurálja
- **Ne írj** titkot, API key-t
- Destruktív parancs (`rm`, force push) előtt állj meg
- Review megjegyzések javításánál **frissítsd** ugyanazt a `result.json`-t

## Ha teljes feature + review kell

Ne improvizálj pipeline-t — `agent-do.sh "feladat"` már futtatja a review-t is.