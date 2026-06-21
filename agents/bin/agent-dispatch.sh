#!/usr/bin/env bash
# agent-dispatch.sh — legacy wrapper → agent-do.sh
# Használat: agent-dispatch.sh <task-id> "<feladat>" [ignored]
set -euo pipefail

_description="${2:?feladat kötelező: agent-dispatch.sh <id> \"feladat\"}"
exec "$(dirname "$0")/agent-do.sh" "$_description"