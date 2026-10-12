#!/usr/bin/env bash
# Клетка red_smesch_zapuskov — инвариант И-13 контракта 100 (круг 2, Б3):
# судятся ТОЛЬКО check-runs выбранного запуска (связка check_suite.id) и
# последняя попытка имени. Под-входы:
# (а) на одном SHA старый полный зелёный запуск R1 (suite 11, строки ПЕРВЫЕ в
#     ответе) и новый отказавший R2 (suite 12, максимальный run id) с новой
#     находкой → судится R2 → «находка вне списка»; выборка строк «по имени,
#     первый попавшийся» берёт зелёные строки R1 и молча допускает;
# (б) в выбранном suite две строки одного имени ci (l4): старая попытка success
#     (меньший id) и новая failure с новой находкой (больший id) → судится
#     БОЛЬШИЙ id → «находка вне списка: l4/check:protected».
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2NEW='check:skills: FAIL: нет положительного контроля (новый случай case_9999)'
L4NEW='check:protected: FAIL: конфликт 263/266 (новая ветка case_8888)'

itog=0
sub() {  # <вариант a|b> <ожидаемая-фраза>
  local variant="$1" want="$2"
  local W="$Z100_BASE/main-ci-100-smesch-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  z100_mir_repo "$W"   # список пуст — строгий допуск
  z100_cr_reset
  local j
  # старый полный зелёный запуск R1: строки suite 11, добавлены ПЕРВЫМИ
  for j in $(z100_jobs); do
    z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" 11
  done
  # судимый запуск R2: suite 12
  for j in $(z100_jobs); do
    case "$j" in
      ap2) [ "$variant" = "a" ] \
             && z100_cr_add "antiplacebo (ap2)" completed failure \
                    "def-sha256 $(z100_def_sha ap2)⏎$AP2NEW⏎check:scope-select: PASS" 12 fixtures/check_skills/ \
             || z100_cr_add "antiplacebo (ap2)" completed success "$(z100_green ap2)" 12 ;;
      l4)  if [ "$variant" = "b" ]; then
             # старая попытка (меньший id) — зелёная; новая (больший id) — новая находка
             z100_cr_add "ci (l4)" completed success "$(z100_green l4)" 12
             z100_cr_add "ci (l4)" completed failure \
               "def-sha256 $(z100_def_sha l4)⏎$L4NEW⏎check:hooks: PASS" 12 forks/263-266-check-protected-content-changed-rename.md
           else
             z100_cr_add "ci (l4)" completed success "$(z100_green l4)" 12
           fi ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" 12 ;;
    esac
  done
  z100_api_write_runs "$W" "1,$Z100_P,completed,success,$Z100_A,11" \
                          "2,$Z100_P,completed,failure,$Z100_A,12"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_smesch_zapuskov/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_smesch_zapuskov/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_smesch_zapuskov/%s\n' "$variant"
  else
    printf 'КРАСНО: red_smesch_zapuskov/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub a 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check:skills'
sub b 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: l4/check:protected'
exit "$itog"
