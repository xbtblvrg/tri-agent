# Tri-agent mód

Ez a workspace tri-agent módban fut (Grok + Claude + Codex).

- **Grok szerep:** `agents/roles/grok.md` — koordinátor, `agent-do.sh` indítás
- **Protokoll:** `agents/AGENTS_PROTOCOL.md`
- User csak feladatot mond → `do "feladat"` vagy `agent-do.sh`
- Ne kérdezz routingról, agentről, pipeline-ról