#!/usr/bin/env bash
# Раннер 043: без аргументов — вся семья; --b10 — только дельта Б-10.
# --model — честная модель Б-10; --stabs — модель и адресные обманки Б-10.
# red_/green_ — само-верифицирующиеся клетки, ожидаемый rc каждой = 0.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
FAMILY="$HERE/check_precision_gate"
MODE="${1:---all}"
case "$MODE" in --all|--b10|--model|--stabs) ;; *) printf 'NOT_IMPLEMENTED: режим %s\n' "$MODE" >&2; exit 2 ;; esac
[ "$#" -le 1 ] || exit 2
TMP=""
if [ "$MODE" = --model ] || [ "$MODE" = --stabs ]; then
  TMP="$(mktemp -d "${TMPDIR:-/tmp}/pg_b10_models.XXXXXX")"
  trap 'rm -rf "$TMP"' EXIT
  python3 "$FAMILY/_b10_models.py" "$HERE/../scripts/check_precision_gate.sh" "$TMP/model.sh" model || exit 2
  export BARRIER="$TMP/model.sh"
fi
bad=0; total=0
for f in "$FAMILY"/red_*.sh "$FAMILY"/green_*.sh; do
  [ -f "$f" ] || continue
  if [ "$MODE" != --all ]; then
    case "${f##*/}" in *_b10_*) ;; *) continue ;; esac
  fi
  total=$((total + 1))
  out="$(bash "$f" 2>&1)"; rc=$?
  printf 'check_precision_gate/%s rc=%s\n' "$(basename "$f")" "$rc"
  if [ "$rc" -ne 0 ]; then
    bad=$((bad + 1))
    printf '  FAIL:\n%s\n' "$out"
  fi
done
printf 'итог: %s файлов, провалов %s\n' "$total" "$bad" >&2
[ "$total" -gt 0 ] || { printf 'пустая выборка — не проверено ничего\n' >&2; exit 1; }
if [ "$MODE" = --stabs ]; then
  # Н-39: привязки по коду, только входы, где дефект различим от честного.
  # S2 предъявляется отдельно на вчерашнем долге И на календаре после срока.
  bindings=('S1:a' 'S2:b' 'S2:z' 'S3:c' 'S4:a' 'S5:d' 'S6:e' 'S7:zh')
  live=0; caught=0
  for binding in "${bindings[@]}"; do
    stab="${binding%%:*}"; cell="${binding#*:}"
    python3 "$FAMILY/_b10_models.py" "$HERE/../scripts/check_precision_gate.sh" "$TMP/$stab.sh" "$stab" || exit 2
    out="$(BARRIER="$TMP/$stab.sh" bash "$FAMILY/_b10.sh" "$cell" 2>&1)"; rc=$?
    if [ "$rc" -eq 1 ]; then
      caught=$((caught + 1))
      printf 'STAB %s @ %s CAUGHT rc=%s\n' "$stab" "$cell" "$rc"
    else
      live=$((live + 1)); bad=$((bad + 1))
      printf 'STAB %s @ %s LIVE rc=%s\n%s\n' "$stab" "$cell" "$rc" "$out"
    fi
  done
  printf 'STABS=7 BINDINGS=%s CAUGHT=%s LIVE=%s\n' "${#bindings[@]}" "$caught" "$live"
fi
[ "$bad" -eq 0 ]
