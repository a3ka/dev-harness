#!/usr/bin/env bash
# Клетка red_samovnesenie_spiska — инвариант И-14 контракта 100 (круг 2, Б4):
# защищённый переход списка. Кандидат C1 расширяет СВОЙ
# registry/main-ci-exceptions.json дормантной записью (новое исключение,
# которым САМ не пользуется — его находки ровно подписанные, CI честен
# относительно ДЕЙСТВУЮЩЕГО списка). Без защиты после публикации C1 файл стал
# бы rmain и легализовал допуск следующего кандидата C2. Переходный допуск
# обязан отказать: список кандидата байт-неидентичен принятой ревизии.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-samovnes-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

AP2PH='check:skills: FAIL: нет положительного контроля'
L7DORM='check:contract-frozen: FAIL: 097 изменён без новой заморозки'
EV='1111222233334444555566667777888899990000'

ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
ex_dorm="$(z100_ex_json l7 'check:contract-frozen' contracts/097-vozobnovlyaemoe-sostoyanie-zadachi.md "$(z100_failsha "$L7DORM")" "$(z100_def_sha l7)" "$EV" 'дормантная запись кандидата' 2030-01-01)"
# принятая ревизия — узкий список; дерево кандидата — расширенный (дормант)
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
Z100_CANDIDATE_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_dorm")" \
  z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  case "$j" in
    ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
           "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/check_skills/ ;;
    *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
  esac
done
z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_samovnesenie_spiska: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_samovnesenie_spiska: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: список не из доверенной ревизии: registry/main-ci-exceptions.json'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" \
   && ! printf '%s' "$out" | grep -Fq 'PR-CI допуск'; then
  printf 'ЗЕЛЕНО: red_samovnesenie_spiska\n'
  exit 0
fi
printf 'КРАСНО: red_samovnesenie_spiska: предмет отсутствует: ожидался отказ rc 1 с фразой «%s» без строки допуска; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
