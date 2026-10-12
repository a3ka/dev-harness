#!/usr/bin/env bash
# Клетка red_podmena_kandidatom — инвариант И-7 контракта 100: подмена
# списка/workflow/скрипта/отчёта кандидатом не даёт допуска. Под-входы:
# (а) расширенный список в ДЕРЕВЕ кандидата при узком принятом;
# (б) посторонний check-run при отсутствующем l4 (переименование workflow);
# (в) посторонний def-sha256 в отчёте job; (г) отчёт без def-sha256.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check_skills: FAIL: нет положительного контроля'
AP2NEW='check_skills: FAIL: нет положительного контроля (новый случай case_9999)'
EV='1111222233334444555566667777888899990000'

itog=0
podmena_spisok() {  # (а)
  local W="$Z100_BASE/main-ci-100-podm-a-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  local ex_ap2 ex_new
  ex_ap2="$(z100_ex_json ap2 check_skills fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
  ex_new="$(z100_ex_json ap2 check_skills fixtures/check_skills/ "$(z100_failsha "$AP2NEW")" "$(z100_def_sha ap2)" "$EV" 'подменённая запись кандидата' 2030-01-01)"
  # принятая ревизия — узкий список; дерево кандидата — расширенный
  Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
  Z100_CANDIDATE_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2" "$ex_new")" \
    z100_mir_repo "$W"
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
             "def-sha256 $(z100_def_sha ap2)⏎$AP2NEW⏎check_scope_select: PASS" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_podmena/a: стаб API не поднялся\n' >&2; itog=1; trap - EXIT; cleanup; return; }
  z100_subject >/dev/null 2>&1 || { printf 'КРАСНО: red_podmena/a: предмет отсутствует\n' >&2; itog=1; trap - EXIT; cleanup; return; }
  local want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check_skills'
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_podmena/a (список из принятой ревизии)\n'
  else
    printf 'КРАСНО: red_podmena/a: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

podmena_job() {  # (б)
  local W="$Z100_BASE/main-ci-100-podm-b-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  z100_mir_repo "$W"
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    [ "$j" = "l4" ] && continue
    z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")"
  done
  # посторонний job (переименование workflow: l4 выпал, l4x пришёл)
  z100_cr_add "ci (l4x)" completed success "$(z100_green l4)"
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_podmena/b: стаб API не поднялся\n' >&2; itog=1; trap - EXIT; cleanup; return; }
  z100_subject >/dev/null 2>&1 || { printf 'КРАСНО: red_podmena/b: предмет отсутствует\n' >&2; itog=1; trap - EXIT; cleanup; return; }
  local w1='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 отсутствует'
  local w2='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: посторонний job: ci (l4x)'
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$w1" && printf '%s' "$out" | grep -Fq "$w2"; then
    printf 'ЗЕЛЕНО: red_podmena/b (посторонний job + отсутствующий)\n'
  else
    printf 'КРАСНО: red_podmena/b: предмет отсутствует: ожидались rc 1 и ОБЕ фразы «%s» и «%s»; факт rc=%s, вывод: %s\n' \
      "$w1" "$w2" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

podmena_defsha() {  # (в)/(г): <вариант wrong|missing>
  local variant="$1"
  local W="$Z100_BASE/main-ci-100-podm-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  local ex_ap2
  ex_ap2="$(z100_ex_json ap2 check_skills fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
  Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" z100_mir_repo "$W"
  z100_cr_reset
  local j sum
  if [ "$variant" = "wrong" ]; then
    sum="def-sha256 $(z100_def_sha ap5)⏎$AP2PH⏎check_scope_select: PASS"
  else
    sum="$AP2PH⏎check_scope_select: PASS"
  fi
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure "$sum" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_podmena/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  z100_subject >/dev/null 2>&1 || { printf 'КРАСНО: red_podmena/%s: предмет отсутствует\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  local want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: отчёт не из доверенного определения: ap2'
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_podmena/%s (отпечаток определения)\n' "$variant"
  else
    printf 'КРАСНО: red_podmena/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

podmena_spisok
podmena_job
podmena_defsha wrong
podmena_defsha missing
exit "$itog"
