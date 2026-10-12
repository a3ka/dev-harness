#!/usr/bin/env bash
# Клетка А-5 «оба профиля» (контракт 097, §Предмет): пробы подготовки проходят
# для ОБОИХ профилей — харнес (носитель — реестр+профиль на base, канонический
# текст выведен из них) И проектный слой (текст harness/policy + пин 054 И-5) —
# обе ветки prepare зелены, id равен оракулу своего профиля; на НЕКОНФОРМНОЙ
# политике оба профиля дают именованный отказ И-0 «политика: грамматика» rc 1
# (харнес: конформный json-профиль с веткой вне алфавита И-0 — неконформность
# попадает в выведенный текст; проект: чужая строка в политике).
# Обман — t97-m8 (неизвестная строка политики принимается).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: oba-profilya: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

WH="$(_t97_world_harness a5h)" || exit 2
WP="$(_t97_world_project a5p)" || exit 2
trap '_t97_cleanup "$WH"; _t97_cleanup "$WP"' EXIT
RH="$WH/repo"; RP="$WP/repo"

BH="$(git -C "$RH" rev-parse main)"; CH="$(git -C "$RH" rev-parse cand)"
BP="$(git -C "$RP" rev-parse main)"; CP="$(git -C "$RP" rev-parse cand)"
MH="$(_t97_merge "$RH" "$BH" "$CH" a5h)" || { printf 'КРАСНО: a5: оракул merge (харнес) не строится\n' >&2; exit 1; }
MP="$(_t97_merge "$RP" "$BP" "$CP" a5p)" || { printf 'КРАСНО: a5: оракул merge (проект) не строится\n' >&2; exit 1; }
OH="$(_t97_expected_id "$RH" "$BH" T-97 main "$BH" "$CH" "$MH")"
OP="$(_t97_expected_id "$RP" "$BP" T-97 main "$BP" "$CP" "$MP")"
[ "$OH" != "$OP" ] || { printf 'КРАСНО: a5: профили не различимы в id\n' >&2; exit 1; }

# положительные пробы: обе ветки prepare зелены + id своего профиля
for probe in h p; do
  if [ "$probe" = h ]; then RR="$RH"; BB="$BH"; CC="$CH"; OO="$OH"; NAME=харнес; else RR="$RP"; BB="$BP"; CC="$CP"; OO="$OP"; NAME=проект; fi
  _t97_refs_arm "$RR" || exit 2
  refs_before="$(_t97_refs_snap "$RR")" || exit 2
  out="$(bash "$SUBJ" prepare --repo "$RR" --task T-97 --base "$BB" --candidate "$CC")"; rc=$?
  _t97_refs_check "$RR" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
  case "$out" in ''|*[!0-9a-f]*)
    printf 'КРАСНО: a5: prepare профиля %s не напечатал merge sha (rc=%s, вывод=%s)\n' "$NAME" "$rc" "$out" >&2; exit 1 ;; esac
  [ "${#out}" -eq 40 ] || { printf 'КРАСНО: a5: prepare профиля %s напечатал не 40 hex: %s\n' "$NAME" "$out" >&2; exit 1; }
done
oid="$(bash "$SUBJ" object --repo "$RH" --task T-97 --target main --base "$BH" --candidate "$CH" --merge "$MH")" || exit 1
[ "$oid" = "$OH" ] || { printf 'КРАСНО: a5: id профиля харнес не по выведенной политике base (%s, ждали %s)\n' "$oid" "$OH" >&2; exit 1; }
oid="$(bash "$SUBJ" object --repo "$RP" --task T-97 --target main --base "$BP" --candidate "$CP" --merge "$MP")" || exit 1
[ "$oid" = "$OP" ] || { printf 'КРАСНО: a5: id проектного слоя не по политике base (%s, ждали %s)\n' "$oid" "$OP" >&2; exit 1; }

# негативные пробы: неконформная политика на base → именованный отказ И-0, refs не тронуты
WH2="$(_t97_world_harness a5hb)" || exit 2
WP2="$(_t97_world_project a5pb)" || exit 2
trap '_t97_cleanup "$WH"; _t97_cleanup "$WP"; _t97_cleanup "$WH2"; _t97_cleanup "$WP2"' EXIT
# харнес: ветка вне алфавита И-0 в конформном json-профиле → выведенный текст неконформен
git -C "$WH2/repo" checkout -q main
printf '{\n  "repoId": "toy-harness-097",\n  "targetBranches": ["main", "feat+x"]\n}\n' >"$WH2/repo/harness.project.json"
_t97_regen "$WH2/repo"
git -C "$WH2/repo" add -A && git -C "$WH2/repo" commit -qm 'branch outside alphabet'
BH2="$(git -C "$WH2/repo" rev-parse main)"; CH2="$(git -C "$WH2/repo" rev-parse cand)"
B2H="$(git -C "$WH2/repo" rev-parse refs/heads/main)"
_t97_refs_arm "$WH2/repo" || exit 2
refs_before="$(_t97_refs_snap "$WH2/repo")" || exit 2
o="$(bash "$SUBJ" prepare --repo "$WH2/repo" --task T-97 --base "$BH2" --candidate "$CH2" 2>&1)"; rc=$?
_t97_refs_check "$WH2/repo" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
{ [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'политика: грамматика'; } || {
  printf 'КРАСНО: a5: неконформная политика профиля харнес не отказана именованно (rc=%s, вывод=%s)\n' "$rc" "$o" >&2; exit 1; }
[ "$(git -C "$WH2/repo" rev-parse refs/heads/main)" = "$B2H" ] || { printf 'КРАСНО: a5: отказ (харнес) двинул main\n' >&2; exit 1; }

# проект: чужая строка в политике на base
git -C "$WP2/repo" checkout -q main
printf 'repoId=toy-proj-097\nmandatory=p-a,p-b\ntargetBranches=main\nbogus=1\n' >"$WP2/repo/harness/policy"
git -C "$WP2/repo" add -A && git -C "$WP2/repo" commit -qm 'unknown policy line'
BP2="$(git -C "$WP2/repo" rev-parse main)"; CP2="$(git -C "$WP2/repo" rev-parse cand)"
B2P="$(git -C "$WP2/repo" rev-parse refs/heads/main)"
_t97_refs_arm "$WP2/repo" || exit 2
refs_before="$(_t97_refs_snap "$WP2/repo")" || exit 2
o="$(bash "$SUBJ" prepare --repo "$WP2/repo" --task T-97 --base "$BP2" --candidate "$CP2" 2>&1)"; rc=$?
_t97_refs_check "$WP2/repo" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
{ [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'политика: грамматика'; } || {
  printf 'КРАСНО: a5: неконформная политика проектного слоя не отказана именованно (rc=%s, вывод=%s)\n' "$rc" "$o" >&2; exit 1; }
[ "$(git -C "$WP2/repo" rev-parse refs/heads/main)" = "$B2P" ] || { printf 'КРАСНО: a5: отказ (проект) двинул main\n' >&2; exit 1; }
exit 0
