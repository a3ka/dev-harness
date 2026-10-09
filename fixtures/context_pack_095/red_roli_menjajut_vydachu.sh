#!/usr/bin/env bash
# Клетка И-4 «смена роли меняет релевантную выдачу» (контракт 095, Выход п.4).
# Замороженный мир: (а) architect видит процедуру grilling, implementer — НЕТ
# (матрица видимости 13.4), implementer видит tdd; (б) выдачи двух ролей
# различаются; (в) TASK-секция — только у reviewer (фактически выданное).
# Обман (s4: матрица скилов не зависит от роли) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: roli-menjajut-vydachu: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i4)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed
_t95_trace "$W/trace.tsv" reviewer glm-4.7 allowed

pa="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)" || { printf 'КРАСНО: i4: architect-пак не строится\n' >&2; exit 1; }
pi="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)" || { printf 'КРАСНО: i4: implementer-пак не строится\n' >&2; exit 1; }
pr="$(bash "$SUBJ" --repo "$R" --role reviewer --contract 777 --task-file "$W/task.md" --model-trace "$W/trace.tsv" 2>&1)" || { printf 'КРАСНО: i4: reviewer-пак не строится\n' >&2; exit 1; }

printf '%s\n' "$pa" | grep -Fxq 'SKILL: grilling' || { printf 'КРАСНО: i4: architect не видит grilling\n' >&2; exit 1; }
if printf '%s\n' "$pi" | grep -Fq 'grilling'; then
  printf 'КРАСНО: i4: implementer видит grilling — выдача не зависит от роли\n' >&2; exit 1
fi
printf '%s\n' "$pi" | grep -Fxq 'SKILL: tdd' || { printf 'КРАСНО: i4: implementer не видит tdd\n' >&2; exit 1; }
if [ "$pa" = "$pi" ]; then
  printf 'КРАСНО: i4: выдачи architect и implementer байт-в-байт равны\n' >&2; exit 1
fi
if printf '%s\n' "$pa" | grep -Fq '=== TASK ==='; then
  printf 'КРАСНО: i4: TASK-секция у не-reviewer роли\n' >&2; exit 1
fi
printf '%s\n' "$pr" | grep -Fq '=== TASK ===' || { printf 'КРАСНО: i4: reviewer без TASK-секции\n' >&2; exit 1; }
exit 0
