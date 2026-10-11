#!/usr/bin/env bash
# Клетка И-8 «роль/модель/разрешённый fallback подтверждаются трассой» /
# «отсутствие свидетельства модели не считается успехом» (контракт 095, Выход
# п.6, круг 2). (а) без --model-trace — именованный отказ, НЕ пустая трасса и
# НЕ успех; (б) трасса без строки запрошенной роли — «свидетельство не той
# роли»; (в) честная трасса — TRACE-строка несёт модель/fallback дословно.
# Обман (s8: свидетельство подменяется умолчанием) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: svidetelstvo-modeli: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i8)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"

# (а) свидетельства нет — не успех
out="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: нет свидетельства модели: architect'; then
  printf 'КРАСНО: i8: отсутствие свидетельства не отказано именем (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq '=== make_task'; then
  printf 'КРАСНО: i8: без свидетельства выдан пак — отсутствие свидетельства засчитано успехом\n' >&2; exit 1
fi

# (б) трасса чужой роли
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 1 ] || ! printf '%s\n' "$out2" | grep -Fq 'ОТКАЗ: свидетельство не той роли: architect'; then
  printf 'КРАСНО: i8: трасса чужой роли не отказана именем (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi

# (в) честная трасса — TRACE-строка дословно из трассы
printf '' >"$W/trace2.tsv"
_t95_trace "$W/trace2.tsv" architect glm-5.3 denied
out3="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace2.tsv" 2>&1)"; rc3=$?
if [ "$rc3" -ne 0 ] || ! printf '%s\n' "$out3" | grep -Fxq 'TRACE: role=architect model=glm-5.3 fallback=denied'; then
  printf 'КРАСНО: i8: TRACE-строка не дословна из трассы (rc=%s, вывод: %s)\n' "$rc3" "$out3" >&2; exit 1
fi
exit 0
