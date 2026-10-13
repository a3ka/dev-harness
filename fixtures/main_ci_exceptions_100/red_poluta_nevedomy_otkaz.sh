#!/usr/bin/env bash
# Клетка red_poluta_nevedomy_otkaz — инвариант И-15 контракта 100 (круг 3,
# Б5): полнота и согласованность ЛЮБОГО наблюдаемого результата, не только
# FAIL-job. Под-входы (все — отказ, не «находки 0/0»):
# (а) success-job l4 без терминальной строки второго обязательного ключа →
#     «нет результата: l4/check:hooks»;
# (б) completed/failure job ap2 со всеми PASS и без FAIL-строк → «job не
#     выполнен: ap2 отказ без находки» (отказ неизвестной природы);
# (в) completed/success job ap2 (замаскированный код возврата проверяющего
#     шага) с НОВОЙ FAIL-строкой вне списка → «находка вне списка: ap2/
#     check:skills» — находки читаются из отчёта ЛЮБОГО job, success тоже
#     (живой обход круга 2: success-job с FAIL-строкой давал 0/0);
# (г) все 12 job completed/success с полными PASS, но conclusion запуска =
#     failure → «запуск отказал без находок» (неразобранный отказ workflow:
#     setup/публикация/сбой раннера; живой обход круга 2 давал 0/0).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2NEW='check:skills: FAIL: нет положительного контроля (новый случай case_9999)'

itog=0
sub() {  # <вариант> <ожидаемая-фраза>
  local variant="$1" want="$2"
  local W="$Z100_BASE/main-ci-100-poluta-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  z100_mir_repo "$W"   # список пуст — строгий допуск
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      l4)  [ "$variant" = "green-missing-key" ] \
             && z100_cr_add "ci (l4)" completed success \
                    "def-sha256 $(z100_def_sha l4)⏎check:protected: PASS" \
             || z100_cr_add "ci (l4)" completed success "$(z100_green l4)" ;;
      ap2) case "$variant" in
             red-no-finding) \
               z100_cr_add "antiplacebo (ap2)" completed failure \
                    "def-sha256 $(z100_def_sha ap2)⏎check:skills: PASS⏎check:scope-select: PASS" ;;
             success-with-fail) \
               z100_cr_add "antiplacebo (ap2)" completed success \
                    "def-sha256 $(z100_def_sha ap2)⏎$AP2NEW⏎check:scope-select: PASS" ;;
             *) z100_cr_add "antiplacebo (ap2)" completed success "$(z100_green ap2)" ;;
           esac ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  case "$variant" in
    green-missing-key|success-with-fail) z100_api_write_runs "$W" "2,$Z100_P,completed,success,$Z100_A,2" ;;
    *)                                   z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2" ;;
  esac
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_poluta/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_poluta/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  # Оракул в памяти ДО вызова (правило 8)
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_poluta/%s\n' "$variant"
  else
    printf 'КРАСНО: red_poluta/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub green-missing-key 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: нет результата: l4/check:hooks'
sub red-no-finding   'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: ap2 отказ без находки'
sub success-with-fail 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check:skills'
sub run-failure-only 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: запуск отказал без находок'
exit "$itog"
