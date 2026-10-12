#!/usr/bin/env bash
# Клетка red_ci_proiskhozhdenie — инвариант И-12 контракта 100 (круг 2, Б2):
# происхождение проверяющего кода/определений — из принятой ревизии, не из
# самодекларации job. Кандидат изменил СЛОЙ ОПРЕДЕЛЕНИЙ CI (package.json —
# разрешение команд шагов), отчёты несут ПРАВИЛЬНЫЙ def-sha256 и честные
# терминальные строки, находка — ровно подписанная. Байт-идентичность слоя
# определений p↔rmain нарушена → отказ «CI-код не из доверенной ревизии»;
# правильный хеш НЕ легализует подмену.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-cipro-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT

AP2PH='check:skills: FAIL: нет положительного контроля'
EV='1111222233334444555566667777888899990000'

ex_ap2="$(z100_ex_json ap2 'check:skills' fixtures/check_skills/ "$(z100_failsha "$AP2PH")" "$(z100_def_sha ap2)" "$EV" 'положительный контроль добавлен' 2030-01-01)"
# дерево кандидата несёт ИЗМЕНЁННЫЙ package.json (слой определений CI)
Z100_EXCEPTIONS_JSON="$(z100_ex_list "$ex_ap2")" \
Z100_CANDIDATE_CI_FILE="package.json" \
Z100_CANDIDATE_CI_CONTENT="$(z100_pkgjson | sed 's/toy-mir-100/toy-mir-100-podmena/')" \
  z100_mir_repo "$W"

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
z100_wait_api "$PORT" || { printf 'КРАСНО: red_ci_proiskhozhdenie: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_ci_proiskhozhdenie: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: CI-код не из доверенной ревизии: package.json'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want"; then
  printf 'ЗЕЛЕНО: red_ci_proiskhozhdenie\n'
  exit 0
fi
printf 'КРАСНО: red_ci_proiskhozhdenie: предмет отсутствует: ожидался отказ rc 1 с фразой «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
