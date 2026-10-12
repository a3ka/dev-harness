#!/usr/bin/env bash
# Клетка red_srok_i_versiya_zapisi — инвариант И-10 контракта 100: истёкший
# срок записи — отказ (не автопродление); версия определения в записи не
# совпадает с доверенным отпечатком — отказ. Соответствие по target/key/sha
# в обоих под-входах ЕСТЬ.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"

AP2PH='check_skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

itog=0
sub() {  # <вариант expired|version> <запись-список-json> <ожидаемая-фраза>
  local variant="$1" exlist="$2" want="$3"
  local W="$Z100_BASE/main-ci-100-srok-$variant-$$-${RANDOM}" API_PID="" out rc
  cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
  trap cleanup EXIT
  Z100_EXCEPTIONS_JSON="$exlist" z100_mir_repo "$W"
  z100_cr_reset
  local j
  for j in $(z100_jobs); do
    case "$j" in
      ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
             "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check_scope_select: PASS" ;;
      *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
    esac
  done
  z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A"
  z100_api_write_crs "$W"
  local sv PORT
  sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
  z100_wait_api "$PORT" || { printf 'КРАСНО: red_srok_i_versiya/%s: стаб API не поднялся\n' "$variant" >&2; itog=1; trap - EXIT; cleanup; return; }
  if ! z100_subject >/dev/null 2>&1; then
    printf 'КРАСНО: red_srok_i_versiya/%s: предмет отсутствует: scripts/gitw_preflight_071.sh\n' "$variant" >&2
    itog=1; trap - EXIT; cleanup; return
  fi
  out="$(z100_subject_run "$PORT")"; rc=$?
  if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
    printf 'ЗЕЛЕНО: red_srok_i_versiya/%s\n' "$variant"
  else
    printf 'КРАСНО: red_srok_i_versiya/%s: предмет отсутствует: ожидались rc 1 и фраза «%s»; факт rc=%s, вывод: %s\n' \
      "$variant" "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
    itog=1
  fi
  trap - EXIT; cleanup
}

ex_expired="$(z100_ex_json ap2 check_skills fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2000-01-01)"
ex_stalever="$(z100_ex_json ap2 check_skills fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(printf 'c%.0s' {1..64})" "$EV" 'положительный контроль добавлен' 2030-01-01)"

sub expired "$ex_expired" 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: срок исключения истёк: fixtures/check_skills/'
sub stalever "$ex_stalever" 'gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: определение проверки не совпадает с записью: fixtures/check_skills/'
exit "$itog"
