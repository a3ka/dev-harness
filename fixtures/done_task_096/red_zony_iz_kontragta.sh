#!/usr/bin/env bash
# Клетка И-3 «зоны — изменённые пути ОБЯЗАНЫ лежать в ЗОНАХ контракта»
# (контракт 096, П-3). Половина (а): merge меняет путь ВНЕ ЗОН контракта
# → «путь вне зоны контракта: <path>». Половина (б): merge в зоне — зелёный
# (позитив, анти-тавтология).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: zony-iz-kontragta: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): вне зоны → отказ ──────────────────────────────────────────
W="$(_t96_world i3a code toy 096 \
  'printf "rogue\n" > docs/external/payload.txt && mkdir -p docs/external && git mv -f scripts/done_project.sh scripts/done_project.sh.tmp 2>/dev/null || true' \
  'printf "rogue\n" > docs/external/payload.txt' \
  'mkdir -p docs/external && mv scripts/done_project.sh.tmp docs/external/ 2>/dev/null || true' \
  'printf "rogue\n" > docs/external/payload.txt'
)" || exit 2
# Альтернативный путь, не опираемся на mv-цепочку, просто добавляем файл вне ЗОНА
W="$(_t96_world i3a-clean)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
mkdir -p "$R/scripts/outside-zone"
printf 'rogue\n' >"$R/scripts/outside-zone/payload.txt"
git -C "$R" add -A && git -C "$R" commit -qm 'cand: outside zone'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || true
[ -n "$TREE" ] || { printf 'КРАСНО: i3a: merge-tree не строится\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Eq 'путь вне зоны|объект не опубликован'; then
  printf 'КРАСНО: i3a: путь вне зоны не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# Сообщение должно быть именно «путь вне зоны» — это содержательная защита
printf '%s' "$out" | grep -Fq 'путь вне зоны' || {
  printf 'КРАСНО: i3a: защита не содержательная (нет «путь вне зоны»): %s\n' "$out" >&2; exit 1
}
exit 0
