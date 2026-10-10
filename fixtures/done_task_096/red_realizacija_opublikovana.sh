#!/usr/bin/env bash
# Клетка И-7 «реализация предмета действительно опубликована — published-строка
# ЕСТЬ для object_id» (контракт 096, П-7, потребление 094). Половина (а):
# candidates.tsv без published-строки для object_id → отказ «объект не
# опубликован». Половина (б): candidates.tsv с двумя строками для одного
# OID — первая должна быть проигнорирована (И-7 на «ЕСТЬ»: достаточно
# наличия; на этом круге последняя; проверка — структурная по object_id;
# защита от подмены object_id задаётся И-1 структурным grep).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: realizacija-opublikovana: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): published-строки нет → отказ ──────────────────────────────
W="$(_t96_world i7a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
# Сделаем минимальное содержимое для прохода других ступеней
mkdir -p "$R/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
git -C "$R" add -A && git -C "$R" commit -qm 'cand: code'
OID="$(printf '%064d' 1)"
# Не пишем published-строку вообще
HEAD="$(git -C "$R" rev-parse HEAD)"
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'объект не опубликован'; then
  printf 'КРАСНО: i7a: отсутствующий published не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): published есть для ДРУГОГО OID, но не для моего ───────────
W2="$(_t96_world i7b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R2/scripts/$n.sh"
  chmod +x "$R2/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R2/CODING-STANDARDS.md"
printf 'code change\n' >>"$R2/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: code change'
B="$(git -C "$R2" rev-parse main)"
C="$(git -C "$R2" rev-parse cand)"
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i7b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
# published для ЧУЖОГО OID
OID_OTHER="$(printf '%064d' 9)"
printf 'published\t%s\t%s\t1\n' "$OID_OTHER" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
OID_MINE="$(printf '%064d' 1)"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --object-id "$OID_MINE" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'объект не опубликован'; then
  printf 'КРАСНО: i7b: чужой published не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
