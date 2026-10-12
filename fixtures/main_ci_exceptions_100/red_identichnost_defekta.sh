#!/usr/bin/env bash
# Клетка red_identichnost_defekta — инвариант И-11 контракта 100 (круг 2, Б1):
# идентичность дефекта — не только текст FAIL-строки. Запись подписана по
# sha256 текста T с object=fixtures/check_skills/; отчёт несёт в ТОЧНОСТИ тот
# же текст T (sha совпадает), но структурированная failure-аннотация указывает
# ДРУГОЙ точный объект (fixtures/skills-drugoy-case/ — иная фикстура/причина).
# Совпадение диагностического текста не может быть единственным свидетельством:
# отказ «находка вне списка».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-ident-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

AP2PH='check:skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  case "$j" in
    # ТОТ ЖЕ текст FAIL (sha записи совпадает), но аннотация — другой объект
    ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
           "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/skills-drugoy-case/ ;;
    *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
  esac
done
z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_identichnost_defekta: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_identichnost_defekta: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check:skills'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_identichnost_defekta\n'
  exit 0
fi
printf 'КРАСНО: red_identichnost_defekta: предмет отсутствует: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
