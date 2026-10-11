#!/usr/bin/env bash
# Клетка И-6 «самовольное ослабление политики кандидатом не проходит»
# (контракт 094, Выход п.6; Astra §1.5 дословно: «сам проверяемый не должен
# определять, чем его проверять»). Вход: кандидат ЗАМЕНИЛ harness/policy на
# mandatory=deploy-docs, зелёные строки есть ТОЛЬКО по ослабленному перечню;
# доверенная политика base SHA требует ci-a,ci-b. Честная дверь судит по base:
# «нет обязательной проверки: ci-a». Обман (s6: политика читается из кандидата)
# публикует → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: oslablenie-politiki-kandidatom: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i6)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
BASE="$(git -C "$R" rev-parse main)"
# кандидат правит СВОЮ политику: убирает обязательные ci-a/ci-b
git -C "$R" checkout -q cand
printf 'repoId=toy-094\nmandatory=deploy-docs\ntargetBranches=main\n' | tee "$R/harness/policy" >/dev/null
git -C "$R" add -A && git -C "$R" commit -qm 'weaken policy'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"
# доверенная политика base не тронута: mandatory=ci-a,ci-b
trust="$(git -C "$R" show "$BASE:harness/policy")"
printf '%s' "$trust" | grep -Fq 'mandatory=ci-a,ci-b' || { printf 'КРАСНО: i6: мир сломан — base-политика не исходная\n' >&2; exit 1; }

MERGE="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
OID="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1
_t94_verdict "$J" 1 T-1 "$OID" accept
_t94_check "$J" "$OID" deploy-docs ok 1 "$(_t94_anysha oslablennyj-deploy-docs)" "$(_t94_tree "$R" "$MERGE")"   # зелёное по ОСЛАБЛЕННОМУ перечню кандидата

out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE" --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'нет обязательной проверки: ci-a'; then
  printf 'КРАСНО: i6: ослабленная политика кандидата принята (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i6: отказ сдвинул main\n' >&2; exit 1; }
exit 0
