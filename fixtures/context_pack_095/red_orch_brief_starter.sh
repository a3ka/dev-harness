#!/usr/bin/env bash
# Клетка И-12 «orch_brief — стартовый контекст отдельным режимом» (контракт
# 095, состав п.2). --kind brief: (а) только оркестратору, чужой роли —
# именованный отказ; (б) брифинг несёт карту/правила/бюджет и НЕ несёт секций
# контракта (ЗОНЫ/CONTEXT/TASK); (в) положительный контроль: kind=task тем же
# субъектом несёт секции контракта (различие режимов не декоративно).
# Обман (s12: брифинг = задачный пак) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: orch-brief-starter: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i12)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# (а) брифинг чужой роли — отказ
out0="$(bash "$SUBJ" --repo "$R" --role architect --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc0=$?
if [ "$rc0" -ne 1 ] || ! printf '%s\n' "$out0" | grep -Fq 'ОТКАЗ: брифинг только оркестратору'; then
  printf 'КРАСНО: i12: брифинг чужой роли не отказан именем (rc=%s, вывод: %s)\n' "$rc0" "$out0" >&2; exit 1
fi

# (б) брифинг: карта/правила есть, секций контракта нет
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i12: брифинг не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
printf '%s\n' "$out" | grep -Fxq 'MAP: PROJECT.md :: карта проекта' || { printf 'КРАСНО: i12: брифинг без карты проекта\n' >&2; exit 1; }
for sec in '=== ZONES ===' '=== CONTEXT ===' '=== TASK ===' '=== LESSONS ==='; do
  if printf '%s\n' "$out" | grep -Fq "$sec"; then
    printf 'КРАСНО: i12: брифинг несёт задачную секцию %s\n' "$sec" >&2; exit 1
  fi
done
printf '%s\n' "$out" | grep -Fq 'BUDGET: vklejka=' || { printf 'КРАСНО: i12: брифинг без бюджета\n' >&2; exit 1; }

# (в) задачный режим тем же субъектом — секции контракта есть
out2="$(bash "$SUBJ" --repo "$R" --role orchestrator --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
if [ "$rc2" -ne 0 ] || ! printf '%s\n' "$out2" | grep -Fq '=== ZONES ==='; then
  printf 'КРАСНО: i12: задачный режим не несёт секции контракта (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
exit 0
