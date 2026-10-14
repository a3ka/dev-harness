#!/usr/bin/env bash
# Клетка И-1б «корневой contracts/ — НЕ источник» (контракт 103). Тот же
# toy-репо, но контракт 777 перенесён в корневой contracts/ (harness-layout),
# а профильный tasks/h ПУСТ. Субъект обязан отказать rc 1 именованной
# причиной «черновик контракта не найден: 777» (фраза 095 дословно) и НЕ
# печатать байты контракта. Обман (поиск по корню/двум путям) → rc 0 → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_make_task)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: koren-harnesa-ne-istochnik: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
W="$(_t103_world i1b)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
mkdir -p "$R/contracts"
git -C "$R" mv tasks/h/777-toy.md contracts/777-toy.md
git -C "$R" commit -qm 'контракт в harness-layout'
[ -z "$(ls -A "$R/tasks/h")" ] || { printf 'КРАСНО: i1b: мир сломан — tasks/h не пуст\n' >&2; exit 2; }
_t103_trace "$W/trace.tsv" architect glm-4.7 allowed
out="$(cd / && bash "$SUBJ" --repo "$R" --kind task --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ]; then
  printf 'КРАСНО: i1b: контракт из корневого contracts/ принят (rc=%s, ждали 1; вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if ! printf '%s\n' "$out" | grep -Fq 'черновик контракта не найден: 777'; then
  printf 'КРАСНО: i1b: отказ без имени «черновик контракта не найден: 777» (вывод: %s)\n' "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fxq -- "$T103_UNIQ"; then
  printf 'КРАСНО: i1b: байты контракта из корня попали в вывод\n' >&2; exit 1
fi
exit 0
