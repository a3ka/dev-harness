#!/usr/bin/env bash
# Клетка red_vozvrat_posle_snyatiya — инвариант И-9 контракта 100: возврат
# дефекта после снятия исключения — отказ. Запись ap2/check:skills снята из
# списка (список сократился), находка вернулась тем же текстом → «находка вне
# списка». До снятия тот же вход допускался (контроль И-3).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-vozvrat-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

AP2PH='check:skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

# запись ap2 СНЯТА: в списке остаётся только l4 (список сокращается)
ex_l4="$(z100_ex_json l4 'check:protected' forks/263-266-check-protected-content-changed-rename.md "$(z100_failsha 'check:protected: FAIL: конфликт 263/266 (известный дефект main)')" "$(z100_def_sha l4)" "$EV" 'форк 263/266 закрыт владельцем' 2030-01-01)"
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_l4")" z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  case "$j" in
    ap2) z100_cr_add "antiplacebo (ap2)" completed failure \
           "def-sha256 $(z100_def_sha ap2)⏎$AP2PH⏎check:scope-select: PASS" 2 fixtures/check_skills/ ;;
    *)   z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")" ;;
  esac
done
z100_api_write_runs "$W" "2,$Z100_P,completed,failure,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_vozvrat_posle_snyatiya: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_vozvrat_posle_snyatiya: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: находка вне списка: ap2/check:skills'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_vozvrat_posle_snyatiya\n'
  exit 0
fi
printf 'КРАСНО: red_vozvrat_posle_snyatiya: предмет отсутствует: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
