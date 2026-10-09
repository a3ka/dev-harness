#!/usr/bin/env bash
# Клетка И-10 «опубликованный done-тег» (контракт 096, П-10). Половина (а):
# нет тега done/contracts/<NNN>/1 на 38-канале → «нет done-тега». Половина
# (б): нет тега done/project/<projectId>/1 (заранее удалён ДО вызова) →
# отказ от простановки (тег ИМЕННО ставится, НО при условии, что
# done/contracts/<NNN>/1 есть — иначе И-10 отказывает до простановки;
# проверка упрощена: модель ставит project-тег + контрактный тег должен
# существовать).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: done-tegi: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): нет done/contracts/<NNN>/1 → отказ ─────────────────────────
W="$(_t96_world i10a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
# Helper ставит done/contracts/096/1 — зачищаем его, чтобы 038-канал был пуст
git -C "$R" tag -d done/contracts/096/1 2>/dev/null || true
mkdir -p "$R/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R/scripts/$n.sh"
  chmod +x "$R/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R/CODING-STANDARDS.md"
printf 'code change\n' >>"$R/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R" add -A && git -C "$R" commit -qm 'cand: code change'
B="$(git -C "$R" rev-parse main)"
C="$(git -C "$R" rev-parse cand)"
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i10a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
# Не ставим done/contracts/096/1
out="$(bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет done-тега: done/contracts/096/1'; then
  printf 'КРАСНО: i10a: отсутствующий контрактный тег не отказан (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
_t96_cleanup "$W"

# ── половина (б): done/contracts/096/1 есть, после гарда done/project/.../1
# тоже ставится — это зелёный сценарий (анти-тавтология) ──────────────────────
W2="$(_t96_world i10b)" || exit 2
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
TREE="$(git -C "$R2" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i10b: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R2" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
# Ставим done/contracts/096/1 как 038
git -C "$R2" tag -f done/contracts/096/1 "HEAD^{}"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue https://example.com/issue/096 --object-id "$OID" --commit-sha "$HEAD2" --notes "toy" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i10b: со всеми тегами не зелёный (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# Проверяем, что оба тега на месте
git -C "$R2" rev-parse --verify --quiet done/contracts/096/1 >/dev/null || {
  printf 'КРАСНО: i10b: done/contracts/096/1 не остался\n' >&2; exit 1; }
git -C "$R2" rev-parse --verify --quiet done/project/toy/1 >/dev/null || {
  printf 'КРАСНО: i10b: done/project/toy/1 не поставлен\n' >&2; exit 1; }
exit 0
