#!/usr/bin/env bash
# Клетка И-1г «корень тега — НЕ источник заморозки» (контракт 103, негатив
# И-1в). В дереве тега frozen/contracts/777/1 контракт лежит ТОЛЬКО в
# harness-layout contracts/777-toy.md (маркер K), профильный tasks/h в теге
# ПУСТ; в рабочем дереве после тега — черновик tasks/h/777-toy.md с маркером D
# (ловушка фолбэка на черновик). Субъект обязан отказать rc 1 фразой «ОТКАЗ:
# заморозка без контракта: frozen/contracts/777/1» (095 дословно) и не
# печатать ни K, ни D. Обман (ls-tree по корню / фолбэк) → rc 0 → красно.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t103_make_task)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: frozen-koren-ne-istochnik: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
W="$(_t103_world i1g)" || exit 2
trap '_t103_cleanup "$W"' EXIT
R="$W/repo"
K='- contracts/777-toy.md — koren-строка-103-k9z1'
D='- tasks/h/777-toy.md — draft-строка-103-d2w5'
marker() {
  awk -v u="$T103_UNIQ" -v m="$2" '$0==u{print m;next}{print}' "$R/$1" >"$R/$1.new" && mv "$R/$1.new" "$R/$1"
}
mkdir -p "$R/contracts"
git -C "$R" mv tasks/h/777-toy.md contracts/777-toy.md
marker contracts/777-toy.md "$K"
git -C "$R" add -A; git -C "$R" commit -qm 'заморозка 777 только в harness-layout'
git -C "$R" tag -a frozen/contracts/777/1 -m 'заморозка 777'
_t103_contract "$R/tasks/h/777-toy.md" 777; marker tasks/h/777-toy.md "$D"
git -C "$R" add -A; git -C "$R" commit -qm 'черновик после заморозки'
# самопроверка мира: в теге tasks/h пуст, contracts/777-toy.md есть
[ -z "$(git -C "$R" ls-tree --name-only frozen/contracts/777/1 tasks/h/)" ] || { printf 'КРАСНО: i1g: мир сломан — tasks/h в теге не пуст\n' >&2; exit 2; }
git -C "$R" ls-tree --name-only frozen/contracts/777/1 contracts/ | grep -Fxq 'contracts/777-toy.md' || { printf 'КРАСНО: i1g: мир сломан — тег без contracts/777-toy.md\n' >&2; exit 2; }
_t103_trace "$W/trace.tsv" implementer glm-4.7 allowed
WANT='ОТКАЗ: заморозка без контракта: frozen/contracts/777/1'
out="$(cd / && bash "$SUBJ" --repo "$R" --kind task --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ]; then
  printf 'КРАСНО: i1g: заморозка из корневого contracts/ тега принята (rc=%s, ждали 1; вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
if ! printf '%s\n' "$out" | grep -Fxq -- "$WANT"; then
  printf 'КРАСНО: i1g: отказ без фразы «%s» (вывод: %s)\n' "$WANT" "$out" >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq -- "$K"; then
  printf 'КРАСНО: i1g: байты приманки K из корня тега попали в вывод\n' >&2; exit 1
fi
if printf '%s\n' "$out" | grep -Fq -- "$D"; then
  printf 'КРАСНО: i1g: байты черновика D попали в вывод при пустой заморозке\n' >&2; exit 1
fi
exit 0
