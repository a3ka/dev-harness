#!/usr/bin/env bash
# Клетка red_kontrol_tolyko_razreshennye — инвариант И-3 контракта 100:
# положительный контроль «только разрешённые». Находки ровно две подписанные
# (ap2/check:skills, l4/check:protected); третья запись (l7) без находки —
# дефект исчез; равенство множеств не требуется → rc 0, находки 2/2.
# Аннотации обеих находок несут точные object записей (Решение 3, круг 2).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-razreshennye-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

AP2PH='check:skills: FAIL: нет положительного контроля'
L4PH='check:protected: FAIL: конфликт 263/266 (известный дефект main)'
L7PH='check:contract-frozen: FAIL: 097 изменён без новой заморозки'
EV='1111222233334444555566667777888899990000'

ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
ex_l4="$(z100_ex_json l4 'check:protected' forks/263-266-check-protected-content-changed-rename.md "$(z100_failsha "$L4PH")" "$(z100_def_sha l4)" "$EV" 'форк 263/266 закрыт владельцем' 2030-01-01)"
ex_l7="$(z100_ex_json l7 'check:contract-frozen' contracts/097-vozobnovlyaemoe-sostoyanie-zadachi.md "$(z100_failsha "$L7PH")" "$(z100_def_sha l7)" "$EV" 'land 097 прошёл' 2030-01-01)"
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_l4" "$ex_l7")" z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  case "$j" in
    ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
           "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/check_skills/ ;;
    l4)  z100_cr_add "ci (l4)" completed failure \
           "def-sha256 $(z100_def_sha l4)⏎$L4PH⏎check:hooks: PASS" 2 forks/263-266-check-protected-content-changed-rename.md ;;
    *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
  esac
done
z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_kontrol_tolyko_razreshennye: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_kontrol_tolyko_razreshennye: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want1='gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo'
want2='jobs 12/12 исполнено, находки 2/2'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq "$want1" \
   && printf '%s' "$out" | grep -Fq "$want2"; then
  printf 'ЗЕЛЕНО: red_kontrol_tolyko_razreshennye\n'
  exit 0
fi
printf 'КРАСНО: red_kontrol_tolyko_razreshennye: предмет отсутствует: ожидались rc 0 и строки «%s» + «%s»; факт rc=%s, вывод: %s\n' \
  "$want1" "$want2" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
