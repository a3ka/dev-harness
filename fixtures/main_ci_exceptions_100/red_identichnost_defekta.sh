#!/usr/bin/env bash
# Клетка red_identichnost_defekta — инвариант И-11 контракта 100 (круг 3, Б1
# по арбитражу verdicts/arbitration/contracts-100-b1b2-v1.md; круг 4, Б9 по
# арбитражу verdicts/arbitration/contracts-100-b9-v1.md): идентичность
# дефекта структурна — message КАЖДОЙ FAIL-строки судится побайтно, не числом
# и не одной позицией порядка. Запись подписана по sha256 текста T с
# object=fixtures/check_skills/; отчёт несёт ТОТ ЖЕ текст T. Под-входы:
# (а) failure-аннотация указывает другой точный объект
#     (fixtures/skills-drugoy-case/ — иная фикстура/причина) → отказ;
# (б) аннотация с правильным path, но message ≠ FAIL-строке побайтно (число
#     аннотаций равно числу FAIL-строк) → тот же отказ;
# (в) при двух FAIL-строках T1,T2 (порядок отчёта ≠ порядку LC_ALL=C) — две
#     аннотации с правильным path, чужой message у аннотации, парной ПЕРВОЙ
#     строке отчёта → тот же отказ;
# (г) те же две строки, чужой message у аннотации, парной ВТОРОЙ строке
#     отчёта → тот же отказ;
# (д) ПОЗИТИВ: те же две строки, обе аннотации с правильным path и
#     message = парной FAIL-строке побайтно → строка допуска, находки 1/1.
# Совпадение диагностического текста не может быть единственным свидетельством.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check:skills: FAIL: нет положительного контроля'
AP2VTO='check:skills: FAIL: иная причина case_77 (чужой message)'
AP2DVA='check:skills: FAIL: второй случай case_42'
EV='1111222233334444555566667777888899990000'

itog=0
sub() {  # <вариант a|b|v|g|d> [позитив 1]
  local variant="$1" positive="${2:-0}"
  local W="$Z100_BASE/main-ci-100-ident-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  # запись подписана по sha256 FAIL-строк с object=fixtures/check_skills/;
  # ann — по одной на FAIL-строку summary по порядку (запись «path~message»
  # переопределяет message аннотации, число аннотаций равно числу FAIL-строк):
  # (а) чужой path; (б) правильный path, чужой message; (в) правильные path×2,
  # чужой message у парной ПЕРВОЙ строке отчёта; (г) те же, чужой message у
  # парной ВТОРОЙ строке отчёта; (д) обе аннотации честные
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
    g) ex="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH" "$AP2DVA")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
       sum="def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎$AP2DVA⏎check:scope-select: PASS"
       ann="fixtures/check_skills/,fixtures/check_skills/~$AP2VTO" ;;
    d) ex="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH" "$AP2DVA")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
       sum="def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎$AP2DVA⏎check:scope-select: PASS"
       ann="fixtures/check_skills/,fixtures/check_skills/" ;;
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
  local admit='gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo'
  out="$(z100_subject_run "$PORT")"; rc=$?
  local ok=0
  if [ "$positive" = "1" ]; then
    # (д) ПОЗИТИВ (образец позитивной ветки — red_ci_proiskhozhdenie.sh:96–101):
    # rc 0 ∧ строка допуска ∧ находки 1/1
    [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq "$admit" \
      && printf '%s' "$out" | grep -Fq 'находки 1/1' && ok=1
  else
    [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" && ok=1
  fi
  if [ "$ok" -eq 1 ]; then
    printf 'ЗЕЛЕНО: red_identichnost/%s\n' "$variant"
  else
    printf 'КРАСНО: red_identichnost/%s: предмет отсутствует: ожидались rc %s и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$([ "$positive" = "1" ] && printf 0 || printf 1)" \
      "$([ "$positive" = "1" ] && printf '%s ∧ находки 1/1' "$admit" || printf '%s' "$want")" \
      "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub a
sub b
sub v
sub g
sub d 1
exit "$itog"
