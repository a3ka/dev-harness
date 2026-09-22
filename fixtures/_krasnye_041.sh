#!/usr/bin/env bash
# Раннер красной/зелёной пачки 041 (check_threat_model): каждый
# fixtures/check_threat_model/case_*.sh — само-верифицирующий (не
# passthrough), обязан завершиться rc 0. Итог печатает таблицу и агрегат.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bad=0; total=0
for f in "$HERE/check_threat_model"/case_*.sh; do
  [ -f "$f" ] || continue
  total=$((total + 1))
  out="$(bash "$f" 2>&1)"; rc=$?
  printf 'check_threat_model/%s rc=%s\n' "$(basename "$f")" "$rc"
  if [ "$rc" -ne 0 ]; then
    bad=$((bad + 1))
    printf '  FAIL:\n%s\n' "$out"
  fi
done
printf 'итог: %s файлов, провалов %s\n' "$total" "$bad" >&2
[ "$total" -gt 0 ] || { printf 'пустая выборка — не проверено ничего\n' >&2; exit 1; }
[ "$bad" -eq 0 ]
