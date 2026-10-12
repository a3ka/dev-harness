#!/usr/bin/env bash
# Клетка А-4 «состав объекта различим весь» (контракт 097, И-1б в объёме
# подготовки): изменение КАЖДОЙ составляющей отдельно — repoId, задача,
# target, base, candidate, merge, policyVersion — даёт ДРУГОЙ id. Каждый id
# дополнительно сверен ЗНАЧЕНИЕМ оракула (каноническая строка объекта по
# грамматике dover.sh) — порча формулы (t97-m6: задача не входит в id)
# ловится и расхождением вариантов, и значением.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: sostav-obekta-razlichim: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t97_world_project a4)" || exit 2
W2="$(_t97_world_project a4v2)" || exit 2
trap '_t97_cleanup "$W"; _t97_cleanup "$W2"' EXIT
R="$W/repo"; R2="$W2/repo"

BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
P0="$(git -C "$R" rev-list --max-parents=0 HEAD | sed -n 1p)"
# sibling-кандидат C0 (другой sha, та же политика)
git -C "$R" checkout -q main
git -C "$R" checkout -qb cand2
printf 'three\n' >>"$R/file.txt"
git -C "$R" commit -qam 'sibling candidate'
C0="$(git -C "$R" rev-parse cand2)"
git -C "$R" checkout -q main
MERGE="$(_t97_merge "$R" "$BASE" "$CAND" a4-ref)" || { printf 'КРАСНО: a4: оракул merge не строится\n' >&2; exit 1; }
M0="$(_t97_merge "$R" "$BASE" "$CAND" a4-alt)" || { printf 'КРАСНО: a4: оракул merge-alt не строится\n' >&2; exit 1; }
[ "$MERGE" != "$M0" ] || { printf 'КРАСНО: a4: мир не различает merge-коммиты\n' >&2; exit 1; }

obj() { bash "$SUBJ" object --repo "$R" --task "$1" --target "$2" --base "$3" --candidate "$4" --merge "$5"; }
razlichim() {  # <имя-поля> <факт-id> <эталон-id>
  [ "$2" != "$3" ] || { printf 'КРАСНО: a4: изменение поля %s не меняет id (коллапс идентичности)\n' "$1" >&2; exit 1; }
}
sveren() {  # <имя-поля> <факт-id> <эталон-id>
  [ "$2" = "$3" ] || { printf 'КРАСНО: a4: id не по канонической строке объекта (поле %s: %s, ждали %s)\n' "$1" "$2" "$3" >&2; exit 1; }
}

id0="$(obj T-97 main "$BASE" "$CAND" "$MERGE")" || exit 1
sveren канон-строка "$id0" "$(_t97_expected_id "$R" "$BASE" T-97 main "$BASE" "$CAND" "$MERGE")"

v="$(obj T-97-x main "$BASE" "$CAND" "$MERGE")" || exit 1
razlichim задача "$v" "$id0"; sveren задача "$v" "$(_t97_expected_id "$R" "$BASE" T-97-x main "$BASE" "$CAND" "$MERGE")"

v="$(obj T-97 feature "$BASE" "$CAND" "$MERGE")" || exit 1
razlichim target "$v" "$id0"; sveren target "$v" "$(_t97_expected_id "$R" "$BASE" T-97 feature "$BASE" "$CAND" "$MERGE")"

v="$(obj T-97 main "$P0" "$CAND" "$MERGE")" || exit 1
razlichim base "$v" "$id0"; sveren base "$v" "$(_t97_expected_id "$R" "$P0" T-97 main "$P0" "$CAND" "$MERGE")"

v="$(obj T-97 main "$BASE" "$C0" "$MERGE")" || exit 1
razlichim candidate "$v" "$id0"; sveren candidate "$v" "$(_t97_expected_id "$R" "$BASE" T-97 main "$BASE" "$C0" "$MERGE")"

v="$(obj T-97 main "$BASE" "$CAND" "$M0")" || exit 1
razlichim merge "$v" "$id0"; sveren merge "$v" "$(_t97_expected_id "$R" "$BASE" T-97 main "$BASE" "$CAND" "$M0")"

# второй мир: repoId+policyVersion другие (оба конформны) — id обязан отличаться
# и совпасть со значением оракула второго мира (поля repoId/policyVersion
# изоляции по sha не поддаются — их несёт ЗНАЧЕНИЕ оракула)
B2="$(git -C "$R2" rev-parse main)"
C2="$(git -C "$R2" rev-parse cand)"
M2="$(_t97_merge "$R2" "$B2" "$C2" a4v2)" || { printf 'КРАСНО: a4: оракул merge мира-2 не строится\n' >&2; exit 1; }
v="$(bash "$SUBJ" object --repo "$R2" --task T-97 --target main --base "$B2" --candidate "$C2" --merge "$M2")" || exit 1
razlichim repoId/policyVersion "$v" "$id0"
sveren repoId/policyVersion "$v" "$(_t97_expected_id "$R2" "$B2" T-97 main "$B2" "$C2" "$M2")"
exit 0
