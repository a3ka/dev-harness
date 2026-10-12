#!/usr/bin/env bash
# Клетка red_zamena_predikata — инвариант И-1 контракта 100: замена, не
# наслаивание. Run conclusion=success при 11 исполненных job (l4 отсутствует) —
# старый предикат «≥1 успешный PR-workflow» этот вход пропускает, новый обязан
# отказать; старая фраза «land без зелёного PR-CI» в выводе отсутствует.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-zamena-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT
z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  [ "$j" = "l4" ] && continue
  z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")"
done
z100_api_write_runs "$W" "2,$Z100_P,completed,success,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_zamena_predikata: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_zamena_predikata: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want='gitw ПРЕДПОЛЁТ-ОТКАЗ: PR-CI: job не выполнен: l4 отсутствует'
old='land без зелёного PR-CI'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -Fq "$want" \
   && ! printf '%s' "$out" | grep -Fq "$old"; then
  printf 'ЗЕЛЕНО: red_zamena_predikata\n'
  exit 0
fi
printf 'КРАСНО: red_zamena_predikata: предмет отсутствует: ожидался отказ rc 1 с фразой «%s» без «%s»; факт rc=%s, вывод: %s\n' \
  "$want" "$old" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
