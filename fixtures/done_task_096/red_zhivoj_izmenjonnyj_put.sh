#!/usr/bin/env bash
# Клетка И-2 «живой изменённый путь — diff объекта публикации НЕ пустой»
# (контракт 096, П-2). Половина (а): published-строка есть в candidates.tsv,
# но merge M равен base (нет изменений) → отказ «пустой diff объекта
# публикации». Половина (б): published отсутствует в candidates.tsv →
# отказ «объект не опубликован» (И-7 упреждает И-2 в этой ситуации; оба
# сообщения должны различаться по существу, чтобы можно было судить).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: zhivoj-izmenjonnyj-put: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): merge равен base (нет изменений) → отказ «пустой diff» ────
W="$(_t96_world i2a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
# merge = base (пустой diff, но это валидно для git: merge --no-ff с одним родителем)
# Используем commit-tree с тем же деревом и base как первый родитель
TREE="$(git -C "$R" rev-parse "main^{tree}")"
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -m "empty merge")"
# Записать published-строку с этим M
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'пустой diff'; then
  printf 'КРАСНО: i2a: пустой diff не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): published отсутствует → отказ «объект не опубликован» ─────
W2="$(_t96_world i2b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
HEAD2="$(git -C "$R2" rev-parse HEAD)"
OID2="$(printf '%064d' 2)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --object-id "$OID2" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'объект не опубликован'; then
  printf 'КРАСНО: i2b: объект не опубликован не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
