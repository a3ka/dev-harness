#!/usr/bin/env bash
# Клетка red_poluta_nevedomy_otkaz — инвариант И-15 контракта 100 (круг 2, Б5):
# полнота и согласованность ЛЮБОГО исполненного job, не только FAIL-job.
# Под-входы (оба обязаны отказывать, не давать «находки 0/0»):
# (а) success-job l4: def-sha256 верен, но терминальной строки второго
#     обязательного ключа check:hooks нет → «нет результата: l4/check:hooks»;
# (б) completed/failure job ap2: def-sha256 верен, ВСЕ ключи PASS (FAIL-строк
#     нет), отказ неизвестной природы (setup/публикация) → «job не выполнен:
#     ap2 отказ без находки».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

itog=0
sub() {  # <вариант green-missing-key|red-no-finding> <ожидаемая-фраза>
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
      ap2) [ "$variant" = "red-no-finding" ] \
             && z100_cr_add "antiplacebo (ap2)" completed failure \
                    "def-sha256 $(z100_def_sha ap2)⏎check:skills: PASS⏎check:scope-select: PASS" \
             || z100_cr_add "antiplacebo (ap2)" completed success "$(z100_green ap2)" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  if [ "$variant" = "green-missing-key" ]; then
    z100_api_write_runs "$W" "2,$Z100_P,completed,success,$Z100_A,2"
  else
    z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
  fi
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_poluta/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_poluta/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
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
exit "$itog"
