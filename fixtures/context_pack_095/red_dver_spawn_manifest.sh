#!/usr/bin/env bash
# Клетка И-15 «обязательность пака на двери spawn_agent» (контракт 095, Решение
# 5, круг 2; закрытие Б1 вердикта критика круга 1; II-3 дословно: spawn_agent
# отказывает без манифеста make_task). (а) спавн исполнительской роли без
# построенного пака — rc 1 «ОТКАЗ: нет манифеста make_task: <NNN>» (нога стоит
# РАНЬШЕ сверок реестра/тегов 023); (б) make_task построил пак → манифест-файл
# .omp/context/<NNN>.tsv непуст и дверь НЕ отказывает этой причиной.
# Реальная дверь судится до/после landing; в режиме --model грамматику ноги
# несёт model/dver_spawn.sh. Обман (s15: нога снята с двери) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: dver-spawn-manifest: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
DOOR="$(_t95_door)"
[ -f "$DOOR" ] || { printf 'КРАСНО: dver-spawn-manifest: предмет отсутствует: scripts/spawn_agent.sh\n' >&2; exit 1; }

W="$(_t95_world i15)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed

# (а) манифеста нет — дверь отказывает именем ДО сверок 023
out="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'нет манифеста make_task: 777'; then
  printf 'КРАСНО: i15: спавн без пака не отказан «нет манифеста make_task» (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# (б) субъект построил пак — манифест-файл непуст, дверь не отказывает этой причиной
outp="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rcp=$?
if [ "$rcp" -ne 0 ]; then
  printf 'КРАСНО: i15: пак для двери не строится (rc=%s, вывод: %s)\n' "$rcp" "$outp" >&2; exit 1
fi
MAN="$R/.omp/context/777.tsv"
[ -s "$MAN" ] || { printf 'КРАСНО: i15: субъект не оставил манифест-файл пака: %s\n' "$MAN" >&2; exit 1; }
grep -Fq '=== MANIFEST ===' "$MAN" || { printf 'КРАСНО: i15: манифест-файл без секции манифеста\n' >&2; exit 1; }
out2="$(bash "$DOOR" --author implementer --nnn 777 --root "$R" 2>&1)"; rc2=$?
if printf '%s\n' "$out2" | grep -Fq 'нет манифеста make_task'; then
  printf 'КРАСНО: i15: дверь отказала «нет манифеста» при построенном паке (rc=%s, вывод: %s)\n' "$rc2" "$out2" >&2; exit 1
fi
exit 0
