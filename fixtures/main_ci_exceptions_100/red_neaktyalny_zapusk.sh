#!/usr/bin/env bash
# Клетка red_neaktyalny_zapusk — инвариант И-8 контракта 100: судится только
# актуальный запуск этого SHA. Под-входы: (а) чужой head_sha; (б) старый
# успешный запуск + новый с неизвестной находкой; (в) база запуска ≠ принятой
# вершине main (движение базы).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2NEW='check_skills: FAIL: нет положительного контроля (новый случай case_9999)'

itog=0
sub() {  # <вариант> <ожидаемая-фраза>
  local variant="$1" want="$2"
  local W="$Z100_BASE/main-ci-100-zapusk-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  z100_mir_repo "$W"
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) [ "$variant" = "b" ] \
             && z100_cr_add "antiplacebo (ap2)" completed failure \
                    "def-sha256 $(z100_def_sha ap2)⏎$AP2NEW⏎check_scope_select: PASS" \
             || z100_cr_add "antiplacebo (ap2)" completed success "$(z100_green ap2)" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  case "$variant" in
    a) z100_api_write_runs "$W" "3,$Z100_A,completed,success,$Z100_A" ;;          # чужой SHA
    b) z100_api_write_runs "$W" "1,$Z100_P,completed,success,$Z100_A" \
                            "2,$Z100_P,completed,failure,$Z100_A" ;;              # старый + новый
    c) z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_B" ;;          # база двинулась
  esac
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_neaktyalny_zapusk/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_neaktyalny_zapusk/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_neaktyalny_zapusk/%s\n' "$variant"
  else
    printf 'КРАСНО: red_neaktyalny_zapusk/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

sub a 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: запусков PR-CI нет: wip/100/demo'
sub b 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check_skills'
sub c 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: движение базы: запуск не актуален'
exit "$itog"
