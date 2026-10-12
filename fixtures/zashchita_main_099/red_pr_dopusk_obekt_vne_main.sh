#!/usr/bin/env bash
# Клетка red_pr_dopusk_obekt_vne_main — инвариант З-3 контракта 099:
# объект слияния M, НЕ достижимый из origin/main, с полным зелёным обязательным
# набором → «ДОПУСК» rc 0; требования «sha ∈ origin/main» в допуске НЕТ (замена, не наслаивание).
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m3).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-vnemain-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT
z99_mir_repo "$W" 1

# теги в паритете: frozen-тег и на origin
git -C "$Z99_REPO" tag frozen/contracts/099/1 "$Z99_M"
git -C "$Z99_REPO" push -q origin refs/tags/frozen/contracts/099/1

# M вне origin/main по построению (origin/main = A, M = merge(A,B))
git -C "$Z99_REPO" merge-base --is-ancestor "$Z99_M" origin/main 2>/dev/null \
  && { printf 'КРАСНО: red_pr_dopusk_obekt_vne_main: мир построен неверно (M уже на origin/main)\n' >&2; exit 2; }

API="$(z99_api_dir "$W")"
mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$Z99_M"
z99_json_pr "$API/repos/o/r/pulls/7" 7 "$Z99_B" "$Z99_M"
z99_json_checkruns "$API/repos/o/r/commits/$Z99_M/check-runs" \
  l1:success l2:success l3:success l4:success l5:success l6:success \
  l7:success ap1:success ap2:success ap3:success ap4:success ap5:success
sv="$(z99_api_serve "$API")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z99_wait_api "$PORT" || { printf 'КРАСНО: red_pr_dopusk_obekt_vne_main: стаб API не поднялся\n' >&2; exit 1; }

if ! SUBJ="$(z99_subject pr_dopusk.sh)"; then
  printf 'КРАСНО: red_pr_dopusk_obekt_vne_main: предмет отсутствует: scripts/pr_dopusk.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='ДОПУСК'

out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_pr_dopusk_obekt_vne_main\n'
  exit 0
fi
printf 'КРАСНО: red_pr_dopusk_obekt_vne_main: ожидался допуск rc 0 вне origin/main со строкой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
