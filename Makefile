# Makefile — fejlesztői környezet rövidítések
# Használat: make check | make setup | make do TASK="feladat"

.PHONY: check setup status do refresh env help

TASK ?=

help:
	@echo "Fejlesztői parancsok:"
	@echo "  make setup          Környezet telepítés/javítás"
	@echo "  make check          Health check (dev-check.sh)"
	@echo "  make status         Git + tri-agent állapot"
	@echo "  make refresh        Dev context frissítés"
	@echo "  make do TASK=\"...\"  Feladat futtatás (agent-do)"
	@echo "  make env            Shell env betöltés útmutató"

setup:
	@./bin/dev-setup.sh

check:
	@./bin/dev-check.sh

status:
	@./bin/agent-dev.sh status

refresh:
	@./bin/agent-context-refresh.sh

do:
	@test -n "$(TASK)" || (echo "TASK kötelező: make do TASK=\"feladat\"" && exit 1)
	@./bin/agent-do.sh "$(TASK)"

env:
	@echo 'source ~/.config/blvrg/dev-env.sh'