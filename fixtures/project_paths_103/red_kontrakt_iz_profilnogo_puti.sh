#!/usr/bin/env bash
# Клетка И-1а «контракт берётся по workflowPaths.contracts» (контракт 103).
# Toy-репо: workflowPaths.contracts=tasks/h, контракт 777 ТОЛЬКО в tasks/h,
# корневого contracts/ НЕТ. Субъект make_task --kind task --role architect
# → rc 0 и пак несёт уникальную строку §Существующее контракта самостоятельной
# строкой (grep -Fx; оракул — константа T103_UNIQ, снята в память ДО вызова).
# Обман (путь контрактов зашит «contracts/») → «черновик не найден» → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_make_task)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: kontrakt-iz-profilnogo-puti: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
W="$(_t103_world i1a)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
[ ! -e "$R/contracts" ] || { printf 'КРАСНО: i1a: мир сломан — в корне есть contracts/\n' >&2; exit 2; }
WANT="$T103_UNIQ"
_t103_trace "$W/trace.tsv" architect glm-4.7 allowed
out="$(cd / && bash "$SUBJ" --repo "$R" --kind task --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i1a: пак по профильному пути не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if ! printf '%s\n' "$out" | grep -Fxq -- "$WANT"; then
  printf 'КРАСНО: i1a: пак не несёт байты контракта из tasks/h (ждали строку: %s)\n' "$WANT" >&2; exit 1
fi
exit 0
