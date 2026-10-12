#!/usr/bin/env bash
# Клетка red_rannee_zavershenie — инвариант И-5 контракта 100 (круг 2: полнота
# у ЛЮБОГО исполненного job, не только FAIL-job): известная ошибка плюс раннее
# завершение, скрывшее остальные проверки. FAIL-job l7 несёт известную
# FAIL-строку check:contract-frozen, но терминальной строки второго
# обязательного ключа (check:skills) нет → «нет результата».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-rannee-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

L7PH='check:contract-frozen: FAIL: 097 изменён без новой заморозки'
EV='1111222233334444555566667777888899990000'

ex_l7="$(z100_ex_json l7 'check:contract-frozen' contracts/097-vozobnovlyaemoe-sostoyanie-zadachi.md "$(z100_failsha "$L7PH")" "$(z100_def_sha l7)" "$EV" 'land 097 прошёл' 2030-01-01)"
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_l7")" z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  case "$j" in
    # раннее завершение: известный ключ красен, второй ключ результата не имеет
    l7)  z100_cr_add "ci (l7)" completed failure "def-sha256 $(z100_def_sha l7)⏎$L7PH" 2 contracts/097-vozobnovlyaemoe-sostoyanie-zadachi.md ;;
    *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
  esac
done
z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_rannee_zavershenie: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_rannee_zavershenie: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: нет результата: l7/check:skills'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_rannee_zavershenie\n'
  exit 0
fi
printf 'КРАСНО: red_rannee_zavershenie: предмет отсутствует: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
