# Tri-agent autonómia — user preferencia

**Bevezetve:** 2026-06-21

## Mit akar a user

- **Csak a feladatot mondja** — nem kell parancsot, routingot, agent nevet megadni
- **Mi megoldjuk** — Grok koordinál, Codex implementál, Claude review-z
- **Ne kérdezz** vissza „melyik agentet hívjam?" / „pipeline vagy implement?" — csináld

## Grok viselkedés (kötelező)

Ha a user **feladatot** ad (nem tisztán kérdés):

1. Futtasd: `~/bin/agent-do.sh "feladat"` — azonnal, kérdezés nélkül
2. Várd meg az eredményt
3. Foglald össze magyarul: mi készült el, milyen fájlok, review verdict
4. Ha `agent-do` nem elég (pl. beszélgetés, ötletelés) → válaszolj közvetlenül

Ha **kérdés** (mi/hogyan/miért): válaszolj közvetlenül, ne indíts pipeline-t.

## Egy parancs

```bash
agent-do.sh "bármi feladat"
```

Belső flow: classify → Codex implement → Claude review → auto-fix ha kell → összefoglaló.