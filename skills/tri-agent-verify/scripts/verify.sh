#!/usr/bin/env bash
# verify.sh — post-implement checks → agents/tasks/T-NNNN-verify.json
set -euo pipefail

id="${1:?usage: verify.sh T-NNNN}"
work="${BLVRG_WORKSPACE:-$HOME}"
out="$work/agents/tasks/${id}-verify.json"
ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

export PATH="$work/bin:$work/skills/tri-agent-verify/scripts:$HOME/bin:$HOME/.local/bin:$HOME/.local/venv/dev/bin:$PATH"

checks=()
overall="pass"

add_check() {
  local name="$1" status="$2" detail="$3"
  checks+=("$(jq -n --arg n "$name" --arg s "$status" --arg d "$detail" \
    '{name:$n, status:$s, detail:$d}')")
  if [[ "$status" == fail ]]; then
    overall="fail"
  elif [[ "$status" == warn && "$overall" == pass ]]; then
    overall="warn"
  fi
}

mapfile -t changed < <(
  {
    git -C "$work" diff --name-only 2>/dev/null
    git -C "$work" diff --cached --name-only 2>/dev/null
    git -C "$work" ls-files --others --exclude-standard 2>/dev/null
  } | sort -u | grep -v '^$' || true
)

if [[ ${#changed[@]} -eq 0 ]]; then
  add_check "git-diff" warn "Nincs módosított fájl a diff-ben"
else
  add_check "git-diff" pass "${#changed[@]} fájl módosult"
fi

sh_files=()
py_files=()
for f in "${changed[@]}"; do
  [[ -f "$work/$f" ]] || continue
  [[ "$f" == *.sh ]] && sh_files+=("$work/$f")
  [[ "$f" == *.py ]] && py_files+=("$work/$f")
done

if [[ ${#sh_files[@]} -gt 0 ]]; then
  if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck -S error "${sh_files[@]}" 2>&1 | head -c 4000 >"/tmp/tri-verify-sc-$$.txt"; then
      add_check "shellcheck" pass "${#sh_files[@]} shell fájl OK"
    else
      add_check "shellcheck" fail "$(head -c 2000 "/tmp/tri-verify-sc-$$.txt")"
    fi
    rm -f "/tmp/tri-verify-sc-$$.txt"
  else
    add_check "shellcheck" warn "shellcheck nincs telepítve"
  fi
fi

if [[ ${#py_files[@]} -gt 0 ]]; then
  if command -v ruff >/dev/null 2>&1; then
    if ruff check "${py_files[@]}" 2>&1 | head -c 2000 >"/tmp/tri-verify-ruff-$$.txt"; then
      add_check "ruff" pass "${#py_files[@]} python fájl OK"
    else
      add_check "ruff" fail "$(cat "/tmp/tri-verify-ruff-$$.txt")"
    fi
    rm -f "/tmp/tri-verify-ruff-$$.txt"
  else
    add_check "ruff" warn "ruff nincs telepítve"
  fi

  if command -v pytest >/dev/null 2>&1 && [[ -d "$work/tests" || -n "$(find "$work" -maxdepth 3 -name 'test_*.py' -print -quit 2>/dev/null)" ]]; then
    if (cd "$work" && pytest -q --tb=no 2>&1 | tail -5 >"/tmp/tri-verify-pytest-$$.txt"); then
      add_check "pytest" pass "$(tail -1 "/tmp/tri-verify-pytest-$$.txt" || echo OK)"
    else
      add_check "pytest" fail "$(cat "/tmp/tri-verify-pytest-$$.txt")"
    fi
    rm -f "/tmp/tri-verify-pytest-$$.txt"
  fi
fi

if [[ -f "$work/Makefile" ]]; then
  if make -C "$work" -n check >/dev/null 2>&1; then
    add_check "make-check-dry" pass "make check elérhető"
  else
    add_check "make-check-dry" warn "make check dry-run sikertelen vagy nincs target"
  fi
fi

checks_json=$(printf '%s\n' "${checks[@]}" | jq -s '.')

jq -n \
  --arg id "$id" \
  --arg status "$overall" \
  --arg ts "$ts" \
  --argjson checks "$checks_json" \
  '{id:$id, status:$status, checks:$checks, ts:$ts}' >"$out"

echo "[$id] Verify: $overall → $out"
cat "$out"