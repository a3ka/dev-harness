#!/usr/bin/env bash
# Клетка red_pr_dopusk_soderzhatelnye_cheki — инвариант З-2 контракта 099:
# содержательные проверки перенесены ДО серверного слияния: локальный тег
# frozen/contracts/099/1 вне origin → допуск ОТКАЗАН ДО слияния именованной фразой;
# контроль тегов и дерева не потерян (замена чека 3 «зелёный PR-workflow»).
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m4).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-tegi-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT
z99_mir_repo "$W" 1

# локальный frozen-тег на объекте, на origin его нет
git -C "$Z99_REPO" tag frozen/contracts/099/1 "$Z99_M"

API="$(z99_api_dir "$W")"
mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$Z99_M"
z99_json_pr "$API/repos/o/r/pulls/7" 7 "$Z99_B" "$Z99_M"
z99_json_checkruns "$API/repos/o/r/commits/$Z99_M/check-runs" \
  l1:success l2:success l3:success l4:success l5:success l6:success \
  l7:success ap1:success ap2:success ap3:success ap4:success ap5:success
sv="$(z99_api_serve "$API")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z99_wait_api "$PORT" || { printf 'КРАСНО: red_pr_dopusk_soderzhatelnye_cheki: стаб API не поднялся\n' >&2; exit 1; }

if ! SUBJ="$(z99_subject pr_dopusk.sh)"; then
  printf 'КРАСНО: red_pr_dopusk_soderzhatelnye_cheki: предмет отсутствует: scripts/pr_dopusk.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='локальный тег не на origin: frozen/contracts/099/1'

out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_pr_dopusk_soderzhatelnye_cheki\n'
  exit 0
fi
printf 'КРАСНО: red_pr_dopusk_soderzhatelnye_cheki: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
