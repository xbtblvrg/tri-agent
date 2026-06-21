---
name: tri-agent-memory
description: >
  Tri-agent Claude memory curation skill. Session végén vagy explicit kérésre:
  napi log → MEMORY.md index + memory/** destillálás. Használd ha: memory,
  memória kurál, frissítsd MEMORY.md, /tri-agent-memory, memory: prefix,
  session vége, long-term memory. Csak Claude ír MEMORY.md-be.
---

# Tri-agent-memory — Claude

Te a tri-agent **memória-gondnoka** vagy. Ez a skill **review-tól külön** fut — session végén vagy `memory:` feladatnál.

## Input gyűjtés

```bash
skills/tri-agent-memory/scripts/collect-session.sh [output-file]
```

Olvasd a generált fájlt + `references/curation-checklist.md`.

## Kötelező lépések

1. Olvasd `memory/$(date +%Y-%m-%d).md` — mai nyers log
2. Olvasd utolsó 5 `agents/tasks/T-*-summary.md` fájlt (ha van)
3. Olvasd `memory/agent-decisions.md` — ne duplikáld a döntéseket
4. **Destillálj** — csak hosszú távon fontos tudás kerüljön `MEMORY.md`-be vagy dedikált `memory/**` fájlba
5. Frissítsd a `MEMORY.md` indexet (linkek, nem teljes dump)
6. Írd `agents/tasks/T-NNNN-memory.json`-t (séma: `references/memory-schema.json`)

## Mit írj

| Cél | Hol |
|-----|-----|
| Gép, szolgáltatás, config | `memory/system/*.md` |
| User preferencia | `memory/preferences/*.md` |
| Fontos döntés | `memory/agent-decisions.md` (append) |
| Scanable index | `MEMORY.md` |
| Napi nyers log | `memory/YYYY-MM-DD.md` — **ne töröld**, csak olvasd |

## Mit NE írj

- API key, jelszó, token, SSH private key
- Egyszeri debug output, verbose log
- Duplikált tartalom (ha már van fájlban, csak linkelj)
- Codex implement részletek (az task summary-ben marad)

## Claude auto-memory

`~/.claude/projects/-home-blvrg/memory/` csak **importforrás** — fontos tudást vezess át `MEMORY.md` / `memory/**`-be, ne másold vakon.

## Output — memory.json

```json
{
  "id": "T-NNNN",
  "updated_files": ["MEMORY.md", "memory/system/tri-agent.md"],
  "actions": ["index frissítve", "tri-agent skillek hozzáadva system doc-hoz"],
  "summary": "1-2 mondat magyarul",
  "ts": "2026-06-21T12:00:00Z"
}
```

## Mikor fut

- User: `do "memory: kuráld"` vagy `agent-dev.sh memory`
- Session vége (Grok javasolhatja több APPROVED task után)
- **NEM** minden pipeline task után automatikusan