#!/usr/bin/env bash
# Клетка А-2 «красная подмена источника» (контракт 097, §Инварианты): стаб,
# читающий профиль кандидата вместо принятой версии base, различим на
# КОНФОРМНОМ входе, где base и кандидат несут РАЗНЫЕ политики. Проектный слой:
# кандидат сменил repoId (оба значения в алфавите И-0) — честная реализация
# даёт id принятой версии base, стаб — кандидатной; клетка красна.
# Обман — t97-m2 (политика читается из CAND).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: podmena-istochnika-politiki: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t97_world_project a2)" || exit 2
trap '_t97_cleanup "$W"' EXIT
R="$W/repo"
BASE="$(git -C "$R" rev-parse main)"
MAIN_BEFORE="$(git -C "$R" rev-parse refs/heads/main)"

# кандидат меняет СВОЮ политику: repoId-v2 (конформен), профиль-пин согласован
git -C "$R" checkout -q cand
printf 'repoId=toy-proj-097-v2\nmandatory=p-a,p-b\ntargetBranches=main\n' >"$R/harness/policy"
printf '{\n  "repoId": "toy-proj-097-v2",\n  "projectLayer": { "version": "1", "profilePath": "registry/harness-project.json" }\n}\n' >"$R/harness.project.json"
printf '{\n  "version": "1",\n  "repoId": "toy-proj-097-v2"\n}\n' >"$R/registry/harness-project.json"
git -C "$R" add -A && git -C "$R" commit -qm 'candidate changes own repoId'
git -C "$R" checkout -q main
CAND="$(git -C "$R" rev-parse cand)"

# оракул в памяти ДО вызова субъекта (правило 8)
MERGE="$(_t97_merge "$R" "$BASE" "$CAND" a2)" || { printf 'КРАСНО: a2: оракул merge не строится\n' >&2; exit 1; }
OID_BASE="$(_t97_expected_id "$R" "$BASE" T-97 main "$BASE" "$CAND" "$MERGE")"
OID_CAND="$(_t97_expected_id "$R" "$CAND" T-97 main "$BASE" "$CAND" "$MERGE")"
[ "$OID_BASE" != "$OID_CAND" ] || { printf 'КРАСНО: a2: мир не различает политики base и кандидата\n' >&2; exit 1; }

_t97_refs_arm "$R" || exit 2
refs_before="$(_t97_refs_snap "$R")" || exit 2
out="$(bash "$SUBJ" prepare --repo "$R" --task T-97 --base "$BASE" --candidate "$CAND")"; rc=$?
_t97_refs_check "$R" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
case "$out" in ''|*[!0-9a-f]*)
  printf 'КРАСНО: a2: prepare не напечатал merge sha (rc=%s, вывод=%s)\n' "$rc" "$out" >&2; exit 1 ;; esac
[ "${#out}" -eq 40 ] || { printf 'КРАСНО: a2: prepare напечатал не 40 hex: %s\n' "$out" >&2; exit 1; }

oid="$(bash "$SUBJ" object --repo "$R" --task T-97 --target main --base "$BASE" --candidate "$CAND" --merge "$MERGE")" || exit 1
[ "$oid" = "$OID_BASE" ] || {
  printf 'КРАСНО: a2: источник политики подменён на кандидата (oid=%s, ждали по base=%s)\n' "$oid" "$OID_BASE" >&2; exit 1; }

[ "$(git -C "$R" rev-parse refs/heads/main)" = "$MAIN_BEFORE" ] || { printf 'КРАСНО: a2: prepare сдвинул main\n' >&2; exit 1; }
exit 0
