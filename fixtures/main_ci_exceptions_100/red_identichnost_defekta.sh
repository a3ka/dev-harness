#!/usr/bin/env bash
# Клетка red_identichnost_defekta — инвариант И-11 контракта 100 (круг 3, Б1
# по арбитражу verdicts/arbitration/contracts-100-b1b2-v1.md): идентичность
# дефекта структурна — message failure-аннотации судится побайтно, не числом.
# Запись подписана по sha256 текста T с object=fixtures/check_skills/;
# отчёт несёт ТОТ ЖЕ текст T. Под-входы:
# (а) failure-аннотация указывает другой точный объект
#     (fixtures/skills-drugoy-case/ — иная фикстура/причина) → отказ;
# (б) аннотация с правильным path, но message ≠ FAIL-строке побайтно (число
#     аннотаций равно числу FAIL-строк) → тот же отказ;
# (в) при двух FAIL-строках — две аннотации с правильным path, одна с чужим
#     message → тот же отказ.
# Совпадение диагностического текста не может быть единственным свидетельством.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check:skills: FAIL: нет положительного контроля'
AP2VTO='check:skills: FAIL: иная причина case_77 (чужой message)'
AP2DVA='check:skills: FAIL: второй случай case_42'
EV='1111222233334444555566667777888899990000'

itog=0
sub() {  # <вариант a|b|v>
  local variant="$1"
  local W="$Z100_BASE/main-ci-100-ident-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  # запись подписана по sha256 FAIL-строк с object=fixtures/check_skills/;
  # ann: (а) чужой path; (б) правильный path, чужой message; (в) правильные
  # path×2, один чужой message (запись «path~message» в _mir.sh переопределяет
  # message аннотации, число аннотаций равно числу FAIL-строк)
  local ex sum ann
  case "$variant" in
    a) ex="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
       sum="def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS"
       ann="fixtures/skills-drugoy-case/" ;;
    b) ex="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
       sum="def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS"
       ann="fixtures/check_skills/~$AP2VTO" ;;
    v) ex="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH" "$AP2DVA")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
       sum="def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎$AP2DVA⏎check:scope-select: PASS"
       ann="fixtures/check_skills/~$AP2VTO,fixtures/check_skills/" ;;
  esac
  Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex")" z100_mir_repo "$W"
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure "$sum" 2 "$ann" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_identichnost/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_identichnost/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  # Оракул в памяти ДО вызова (правило 8)
  local want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check:skills'
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_identichnost/%s\n' "$variant"
  else
    printf 'КРАСНО: red_identichnost/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub a
sub b
sub v
exit "$itog"
