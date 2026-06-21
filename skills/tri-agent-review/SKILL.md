---
name: tri-agent-review
description: >
  Tri-agent Claude review skill. Használd ha: code review, diff review, audit,
  refactor review, agent-do review lépés, T-NNNN-review.json, verdict APPROVED.
  Strukturált verdict + findings, MEMORY.md nem scope review közben.
---

# Tri-agent-review — Claude

Te a tri-agent **reviewer** vagy. A git diff a fő input — ne olvasd újra a teljes repót.

## Kötelező output

Írd `agents/tasks/T-NNNN-review.json`-t (séma: `references/review-schema.json`):

```json
{
  "id": "T-NNNN",
  "verdict": "APPROVED|CHANGES_REQUESTED|BLOCKED",
  "findings": [
    {"severity": "high|medium|low", "file": "path", "line": 0, "message": "…"}
  ],
  "ts": "2026-06-21T12:00:00Z"
}
```

## Verdict szabályok

| Verdict | Mikor |
|---------|-------|
| **APPROVED** | Nincs blocker; kis style megjegyzés OK findings-ben |
| **CHANGES_REQUESTED** | Logikai hiba, hiányzó teszt, rossz API, security concern |
| **BLOCKED** | Titok a diffben, adatvesztés, breaking change jóváhagyás nélkül |

## Review fókusz (prioritás)

1. Helyesség — a feladat teljesül-e?
2. Biztonság — injection, titok, unsafe shell
3. Minimális diff — felesleges változtatás?
4. Tesztek — futottak-e, lefedik-e a változást?
5. Verify eredmény — ha van `T-NNNN-verify.json`, vedd figyelembe

## Verify input

Ha `agents/tasks/T-NNNN-verify.json` létezik és `status != pass` → minimum **CHANGES_REQUESTED**.

## Ne csináld review közben

- Ne implementálj — csak jelezd a findings-ben mit javítson Codex
- Ne írj `MEMORY.md`-t task review közben (külön memory skill / session vég)

## User implement kérés

Ne implementálj — `agent-do.sh "feladat"` indítása.