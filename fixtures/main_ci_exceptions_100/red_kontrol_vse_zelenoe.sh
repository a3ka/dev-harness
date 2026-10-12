#!/usr/bin/env bash
# Клетка red_kontrol_vse_zelenoe — инвариант И-2 контракта 100: положительный
# контроль «всё зелёное». 12/12 job исполнены и зелёны, список пуст → rc 0 и
# именованная строка допуска (строгий допуск жив; молчания нет).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
W="$Z100_BASE/main-ci-100-zelenoe-$$-${RANDOM}"
API_PID=""
cleanup() { [ -n "$API_PID" ] && kill "$API_PID" 2>/dev/null; rm -rf "$W"; rm -f "${Z100_CR:-}"; }
trap cleanup EXIT
z100_mir_repo "$W"

z100_cr_reset
for j in $(z100_jobs); do
  z100_cr_add "$(z100_prefix "$j") ($j)" completed success "$(z100_green "$j")"
done
z100_api_write_runs "$W" "2,$Z100_P,completed,success,$Z100_A,2"
z100_api_write_crs "$W"
sv="$(z100_api_serve "$W/api")"; API_PID="${sv%%:*}"; PORT="${sv#*:}"
z100_wait_api "$PORT" || { printf 'КРАСНО: red_kontrol_vse_zelenoe: стаб API не поднялся\n' >&2; exit 1; }
if ! z100_subject >/dev/null 2>&1; then
  printf 'КРАСНО: red_kontrol_vse_zelenoe: предмет отсутствует: scripts/gitw_preflight_071.sh\n' >&2
  exit 1
fi

# Оракул в памяти ДО вызова (правило 8)
want1='gitw ПРЕДПОЛЁТ: PR-CI допуск: wip/100/demo'
want2='jobs 12/12 исполнено, находки 0/0'

out="$(z100_subject_run "$PORT")"; rc=$?
if [ "$rc" -eq 0 ] && printf '%s' "$out" | grep -Fq "$want1" \
   && printf '%s' "$out" | grep -Fq "$want2"; then
  printf 'ЗЕЛЕНО: red_kontrol_vse_zelenoe\n'
  exit 0
fi
printf 'КРАСНО: red_kontrol_vse_zelenoe: предмет отсутствует: ожидались rc 0 и строки «%s» + «%s»; факт rc=%s, вывод: %s\n' \
  "$want1" "$want2" "$rc" "$(printf '%s' "$out" | head -c 300)" >&2
exit 1
