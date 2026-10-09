#!/usr/bin/env bash
# Клетка И-15 «повтор завершает оставшиеся действия без повторной поставки +
# отчёт содержит обязательные поля с маркером «unknown» для неизвестных
# метрик» (контракт 096, В-5 сводная, И-15+И-16 объединены: повтор +
# отчётность). Половина (а): два прогона — spend одна запись, candidates.tsv
# без добавок (дверь 094 не вызывается из гарда 096). Половина (б): stdout DONE
# содержит все обязательные ключи (Result, Commit, ObjectId, IssueUrl, PR,
# Tags[…], Class, StartedAt, DurationMin, CIMin, Cost, Interventions, Notes);
# неизвестные метрики помечены `unknown` (а не «», «null», «None»).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t96_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: povtor-dopisyvaet-ostatki: предмет отсутствует: scripts/done_project.sh\n' >&2; exit 1; }

# ── половина (а): два прогона без повторной поставки/записи ──────────────────
W="$(_t96_world i15a)" || exit 2
trap '_t96_cleanup "$W"' EXIT
R="$W/repo"
git -C "$R" checkout -q cand
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
TREE="$(git -C "$R" merge-tree --write-tree "$B" "$C" 2>/dev/null)" || { printf 'КРАСНО: i15a: merge-tree\n' >&2; exit 1; }
M="$(git -C "$R" commit-tree "$TREE" -p "$B" -p "$C" -m "cand merge")"
OID="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID" "$M" >>"$R/registry/candidates.tsv"
HEAD="$(git -C "$R" rev-parse HEAD)"
git -C "$R" tag -f done/contracts/096/1 "HEAD^{}"

# Первый прогон
bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --object-id "$OID" --commit-sha "$HEAD" --notes "toy-1" >/dev/null 2>&1
spent_after_1="$(grep -F "096	$HEAD" "$R/registry/spend.tsv" | wc -l)"
pub_after_1="$(grep -c '^published' "$R/registry/candidates.tsv")"

# Второй прогон (идемпотентность по 094 — повтор spend НЕ должен создать новой
# строки; candidates.tsv — без добавок)
bash "$SUBJ" --repo "$R" --task 96 --class code --project-id toy \
  --object-id "$OID" --commit-sha "$HEAD" --notes "toy-2" >/dev/null 2>&1
spent_after_2="$(grep -F "096	$HEAD" "$R/registry/spend.tsv" | wc -l)"
pub_after_2="$(grep -c '^published' "$R/registry/candidates.tsv")"

if [ "$spent_after_2" -ne "$spent_after_1" ]; then
  printf 'КРАСНО: i15a: повтор создал новую spend-строку (было=%s, стало=%s)\n' "$spent_after_1" "$spent_after_2" >&2
  exit 1
fi
if [ "$pub_after_2" -ne "$pub_after_1" ]; then
  printf 'КРАСНО: i15a: повтор создал новую published-строку (было=%s, стало=%s)\n' "$pub_after_1" "$pub_after_2" >&2
  exit 1
fi
_t96_cleanup "$W"

# ── половина (б): stdout DONE содержит обязательные ключи + unknown для пустых
W2="$(_t96_world i15b)" || exit 2
trap '_t96_cleanup "$W2"' EXIT
R2="$W2/repo"
git -C "$R2" checkout -q cand
mkdir -p "$R2/scripts"
for n in lint build secrets; do
  printf '#!/usr/bin/env bash\nexit 0\n' >"$R2/scripts/$n.sh"
  chmod +x "$R2/scripts/$n.sh"
done
printf '# CODING-STANDARDS\n' >"$R2/CODING-STANDARDS.md"
printf 'change\n' >>"$R2/fixtures/_krasnye_096.sh" 2>/dev/null || true
git -C "$R2" add -A && git -C "$R2" commit -qm 'cand: change'
B2="$(git -C "$R2" rev-parse main)"
C2="$(git -C "$R2" rev-parse cand)"
TREE2="$(git -C "$R2" merge-tree --write-tree "$B2" "$C2" 2>/dev/null)" || { printf 'КРАСНО: i15b: merge-tree\n' >&2; exit 1; }
M2="$(git -C "$R2" commit-tree "$TREE2" -p "$B2" -p "$C2" -m "cand merge")"
OID2="$(printf '%064d' 1)"
printf 'published\t%s\t%s\t1\n' "$OID2" "$M2" >>"$R2/registry/candidates.tsv"
HEAD2="$(git -C "$R2" rev-parse HEAD)"
git -C "$R2" tag -f done/contracts/096/1 "HEAD2^{}" 2>/dev/null || git -C "$R2" tag -f done/contracts/096/1 "HEAD^{}"
ISS="https://example.com/issue/15b"
printf '%s\t%s\t%s\t%s\n' "$ISS" "closed:complete" "doneStatus" "completed" >>"$R2/harness/issue-state.tsv"
out="$(bash "$SUBJ" --repo "$R2" --task 96 --class code --project-id toy \
  --issue "$ISS" --object-id "$OID2" --commit-sha "$HEAD2" --notes "i15b notes" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ]; then
  printf 'КРАСНО: i15b: гард зелёный сценарий не зелёный (rc=%s, out: %s)\n' "$rc" "$out" >&2; exit 1
fi
# Все обязательные ключи
for key in Result Commit ObjectId IssueUrl PR Class StartedAt DurationMin CIMin Cost Interventions Notes; do
  printf '%s\n' "$out" | grep -Eq "^$key[: ]" || {
    printf 'КРАСНО: i15b: в отчёте нет ключа %s\n--out--\n%s\n--/out--\n' "$key" "$out" >&2; exit 1; }
done
# Без метрик → DurationMin/CIMin/Cost/Interventions все `unknown`
for key in DurationMin CIMin Cost Interventions; do
  v="$(printf '%s\n' "$out" | grep -E "^$key:" | head -1)"
  case "$v" in *unknown) : ;; *) printf 'КРАСНО: i15b: %s не «unknown»: %s\n' "$key" "$v" >&2; exit 1 ;; esac
done
exit 0
