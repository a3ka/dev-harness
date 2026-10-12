#!/usr/bin/env bash
# Клетка red_perehodnyj_gheit_perechen — инвариант З-6 контракта 099 (doc §3):
# переходный доверенный гейт допускает ТОЛЬКО точно перечисленные существующие дефекты.
# Шесть входов: (а) все зелёны → ДОПУСК; (б) отказ l7, совпадающий с базой (sha строк) → ДОПУСК;
# (в) неизвестный отказ l7 → блокировка; (г) skipped/нет результата → блокировка;
# (д) то же ЧИСЛО красных проверок, иное содержимое → блокировка;
# (е) дельта трогает config/transition_defects_099.tsv → «база исключений изменена кандидатом».
# До реализации красна «предмет отсутствует»; стаб-пак — battery_stubs.sh (t99-m1 вход в, t99-m5 вход д).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z99_BASE/zashchita-099-perechen-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; }
trap cleanup EXIT

if ! SUBJ="$(z99_subject pr_dopusk.sh)"; then
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: предмет отсутствует: scripts/pr_dopusk.sh\n' >&2
  exit 1
fi

command -v sha256sum >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет sha256sum\n' >&2; exit 2; }

ALLGREEN="l1:success l2:success l3:success l4:success l5:success l6:success l7:success ap1:success ap2:success ap3:success ap4:success ap5:success"
L='check_protected: конфликт 263/266 (известный дефект main)'
L2='check_protected: НОВЫЙ отказ'
LHOST='иная проверка: новый отказ'
# sha256 отсортированных строк отказа (каждая с завершающим \n) — формула контракта, единый источник
L_SHA="$(printf '%s\n' "$L" | LC_ALL=C sort | sha256sum | awk '{print $1}')"

# zpg <вход> <checks-строка> [Z99_BASE_DEFECTS]
zpg() {
  rm -rf "$W/api"
  Z99_BASE_DEFECTS="${3:-}" z99_mir_repo "$W" 1
  git -C "$Z99_REPO" tag frozen/contracts/099/1 "$Z99_M"
  git -C "$Z99_REPO" push -q origin refs/tags/frozen/contracts/099/1
  API="$(z99_api_dir "$W")"
  mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$Z99_M"
  z99_json_pr "$API/repos/o/r/pulls/7" 7 "$Z99_B" "$Z99_M"
  z99_json_checkruns "$API/repos/o/r/commits/$Z99_M/check-runs" $2
  if [ -z "${API_PID:-}" ]; then
    sv="$(z99_api_serve "$API")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
    z99_wait_api "$PORT" || { printf 'КРАСНО: red_perehodnyj_gheit_perechen: стаб API не поднялся\n' >&2; exit 2; }
  fi
}
vypolnit() { # вызов субъекта; кладёт out/rc в оболочку клетки
  out="$(PR_DOPUSK_API="http://127.0.0.1:$PORT" bash "$SUBJ" "$Z99_REPO" --pr 7 2>&1)"; rc=$?
}
zelyono() { # <вход>: ждём ДОПУСК rc 0
  vypolnit
  if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq 'ДОПУСК'; then return 0; fi
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход %s: ожидался ДОПУСК rc 0; факт rc=%s, вывод: %s\n' \
    "$1" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
  exit 1
}
krasno() { # <вход> <фраза>: ждём именованный отказ rc 1
  vypolnit
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$2"; then return 0; fi
  printf 'КРАСНО: red_perehodnyj_gheit_perechen: вход %s: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
    "$1" "$2" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
  exit 1
}

BASE_ENTRY="l7	$L_SHA"

# (а) все зелёны, база пуста → ДОПУСК
zpg а "$ALLGREEN" ""
zelyono а

# (б) отказ l7 точно совпадает с базой → ДОПУСК
zpg б "l1:success l2:success l3:success l4:success l5:success l6:success l7:failure:$L ap1:success ap2:success ap3:success ap4:success ap5:success" "$BASE_ENTRY"
zelyono б

# (в) отказ l7 с ИНЫМ содержимым → «неизвестный отказ»
zpg в "l1:success l2:success l3:success l4:success l5:success l6:success l7:failure:$L2 ap1:success ap2:success ap3:success ap4:success ap5:success" "$BASE_ENTRY"
krasno в 'неизвестный отказ: l7'

# (г) l7 skipped → «нет результата» (зелёная оболочка без фактического выполнения)
zpg г "l1:success l2:success l3:success l4:success l5:success l6:success l7:skipped ap1:success ap2:success ap3:success ap4:success ap5:success" "$BASE_ENTRY"
krasno г 'нет результата: l7'

# (д) то же ЧИСЛО красных (1), но красна ДРУГАЯ проверка с иным текстом → блокировка
zpg д "l1:success l2:success l3:success l4:success l5:success l6:success l7:success ap1:success ap2:failure:$LHOST ap3:success ap4:success ap5:success" "$BASE_ENTRY"
krasno д 'неизвестный отказ: ap2'

# (е) дельта объекта трогает базу исключений → «база исключений изменена кандидатом»
rm -rf "$W/api"
Z99_BASE_DEFECTS="" z99_mir_repo "$W" 1
printf 'l7	00000000000000000000000000000000000000000000000000000000000000ff\n' > "$Z99_REPO/config/transition_defects_099.tsv"
git -C "$Z99_REPO" add config/transition_defects_099.tsv
git -C "$Z99_REPO" -c user.name=demo -c user.email=demo@dev-harness.local \
  commit -q -m "кандидат правит базу исключений (toy)"
M2="$(git -C "$Z99_REPO" rev-parse HEAD)"
git -C "$Z99_REPO" tag frozen/contracts/099/1 "$M2"
git -C "$Z99_REPO" push -q origin refs/tags/frozen/contracts/099/1
API="$(z99_api_dir "$W")"
mkdir -p "$API/repos/o/r/pulls" "$API/repos/o/r/commits/$M2"
z99_json_pr "$API/repos/o/r/pulls/7" 7 "$Z99_B" "$M2"
z99_json_checkruns "$API/repos/o/r/commits/$M2/check-runs" $ALLGREEN
krasno е 'база исключений изменена кандидатом'

printf 'ЗЕЛЕНО: red_perehodnyj_gheit_perechen\n'
exit 0
