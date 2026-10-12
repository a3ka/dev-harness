#!/usr/bin/env bash
# Клетка red_pr_dopusk_tegi_reestr — инвариант З-5 контракта 099:
# целостность реестра в переходе: строка реестра «NNN → <sha>» без живого тега NNN
# на origin → именованный отказ; id/* судится наравне с frozen/*|done/*.
# До реализации красна «предмет отсутствует».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-reestr-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT
z99_mir_repo "$W" 1

git -C "$Z99_REPO" tag frozen/contracts/099/1 "$Z99_M"
git -C "$Z99_REPO" push -q origin refs/tags/frozen/contracts/099/1

# строка реестра на объекте ссылается на тег, которого на origin НЕТ (40-hex мимо всех тегов)
mkdir -p "$Z99_REPO/registry"
printf '099 → 00000000000000000000000000000000000000ff\n' > "$Z99_REPO/registry/contracts.tsv"
git -C "$Z99_REPO" add registry/contracts.tsv
git -C "$Z99_REPO" -c user.name=orchestrator -c user.email=orchestrator@dev-harness.local \
  commit -q -m "реестр: ссылка на невыданный тег (toy)"
M2="$(git -C "$Z99_REPO" rev-parse HEAD)"

API="$(z99_api_dir "$W")"
mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$M2"
z99_json_pr "$API/repos/o/r/pulls/7" 7 "$Z99_B" "$M2"
z99_json_checkruns "$API/repos/o/r/commits/$M2/check-runs" \
  l1:success l2:success l3:success l4:success l5:success l6:success \
  l7:success ap1:success ap2:success ap3:success ap4:success ap5:success
sv="$(z99_api_serve "$API")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z99_wait_api "$PORT" || { printf 'КРАСНО: red_pr_dopusk_tegi_reestr: стаб API не поднялся\n' >&2; exit 1; }

if ! SUBJ="$(z99_subject pr_dopusk.sh)"; then
  printf 'КРАСНО: red_pr_dopusk_tegi_reestr: предмет отсутствует: scripts/pr_dopusk.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='реестр: тег не выдан авторитетом: 099'

out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_pr_dopusk_tegi_reestr\n'
  exit 0
fi
printf 'КРАСНО: red_pr_dopusk_tegi_reestr: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
