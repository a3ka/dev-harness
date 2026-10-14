#!/usr/bin/env bash
# Клетка И-1в «заморозка читается из блоба тега по профильному пути» (контракт
# 103). В дереве тега frozen/contracts/777/1 лежат ДВА контракта: профильный
# tasks/h/777-toy.md (маркер F) и приманка harness-layout contracts/777-toy.md
# (маркер K); рабочее дерево после тега несёт tasks/h/777-toy.md с маркером D ≠ F.
# Субъект (--role implementer → только заморозка) обязан дать rc 0 и байты F
# самостоятельной строкой; ни K (ls-tree по корневому contracts/), ни D
# (фолбэк на черновик рабочего дерева) в выводе быть не должно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_make_task)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: frozen-iz-profilnogo-puti: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
W="$(_t103_world i1v)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
F='- tasks/h/777-toy.md — frozen-строка-103-f4m8'
K='- contracts/777-toy.md — koren-строка-103-k9z1'
D='- tasks/h/777-toy.md — draft-строка-103-d2w5'
# marker <файл-в-репо> <старая строка> <новая строка> — замена строки-маркера целиком
marker() {
  awk -v u="$2" -v m="$3" '$0==u{print m;next}{print}' "$R/$1" >"$R/$1.new" && mv "$R/$1.new" "$R/$1"
}
marker tasks/h/777-toy.md "$T103_UNIQ" "$F"
mkdir -p "$R/contracts"; _t103_contract "$R/contracts/777-toy.md" 777; marker contracts/777-toy.md "$T103_UNIQ" "$K"
git -C "$R" add -A; git -C "$R" commit -qm 'заморозка 777: профильный + приманка'
git -C "$R" tag -a frozen/contracts/777/1 -m 'заморозка 777'
marker tasks/h/777-toy.md "$F" "$D"
git -C "$R" add -A; git -C "$R" commit -qm 'черновик после заморозки'
# самопроверка мира: в теге оба пути, в рабочем дереве — D
git -C "$R" ls-tree --name-only frozen/contracts/777/1 tasks/h/ | grep -Fxq 'tasks/h/777-toy.md' || { printf 'КРАСНО: i1v: мир сломан — тег без tasks/h/777-toy.md\n' >&2; exit 2; }
git -C "$R" ls-tree --name-only frozen/contracts/777/1 contracts/ | grep -Fxq 'contracts/777-toy.md' || { printf 'КРАСНО: i1v: мир сломан — тег без приманки contracts/777-toy.md\n' >&2; exit 2; }
grep -Fxq -- "$D" "$R/tasks/h/777-toy.md" || { printf 'КРАСНО: i1v: мир сломан — рабочее дерево без D\n' >&2; exit 2; }
_t103_trace "$W/trace.tsv" implementer glm-4.7 allowed
out="$(cd / && bash "$SUBJ" --repo "$R" --kind task --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i1v: пак по заморозке не строится (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq -- "$K"; then
  printf 'КРАСНО: i1v: байты приманки K из корневого contracts/ тега попали в вывод\n' >&2; exit 1
fi
if ! printf '%s\n' "$out" | grep -Fxq -- "$F"; then
  printf 'КРАСНО: i1v: пак не несёт байты заморозки из tasks/h (ждали строку: %s)\n' "$F" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq -- "$D"; then
  printf 'КРАСНО: i1v: байты черновика D рабочего дерева попали в вывод вместо заморозки\n' >&2; exit 1
fi
exit 0
