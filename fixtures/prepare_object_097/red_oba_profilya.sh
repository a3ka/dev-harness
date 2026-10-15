#!/usr/bin/env bash
# Клетка А-5 «оба профиля» (контракт 097, §Предмет): пробы подготовки проходят
# для ОБОИХ профилей — харнес (носитель — реестр+профиль на base, канонический
# текст выведен из них) И проектный слой (текст harness/policy + пин 054 И-5) —
# на КАЖДОМ профиле отдельно успешный prepare конформного входа даёт rc 0 И
# печатает merge sha ИМЕННО подготовленного M (родители base+cand, дерево =
# дерево независимого оракула merge-tree — не base, не cand, не чужой коммит),
# id равен оракулу своего профиля; rc-подмена успешной подготовки (rc 1 при
# корректных stdout/объектах/refs) красна на каждом профиле; на НЕКОНФОРМНОЙ
# политике оба профиля дают именованный отказ И-0 «политика: грамматика» rc 1
# (§Демаркация: пустой CSV-компонент — вне алфавита). Входы негативной
# половины, по профилю:
#   харнес: (1) ветка вне алфавита И-0 в конформном json-профиле — неконформность
#               попадает в выведенный текст; (2) реестр БЕЗ step-строк — выведенный
#               текст несёт пустой CSV-компонент «mandatory=»; (5) ключ
#               targetBranches с ПУСТЫМ массивом — выведенный текст несёт пустой
#               CSV-компонент «targetBranches=» (ключ ЕСТЬ — это не вход А-6
#               «ключа нет»);
#   проект: (3) чужая строка в политике; (4) пустой CSV-компонент «mandatory=»;
#           (6) пустой CSV-компонент «targetBranches=».
# Обман — t97-m8 (неизвестная строка политики принимается; вход 3), t97-m17
# (обёртка rc-подмены успешного проектного prepare — блокер критика круга 4),
# t97-m18 (успешный проектный prepare печатает base вместо M — вердикт
# адверсария v2 А-5), t97-m19 (пустой «mandatory=» принимается — вердикт
# адверсария v2 И-0; входы 2 и 4), t97-m23 (пустой «targetBranches=» принят
# при по-прежнему отвергаемом ОТСУТСТВИИ ключа — вердикт адверсария v3 И-0;
# входы 5 и 6; А-6 на m23 зелена — различают ТОЛЬКО эти входы).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t97_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: oba-profilya: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

WORLDS=()
cleanup_all() { local w; for w in "${WORLDS[@]}"; do _t97_cleanup "$w"; done; }
trap cleanup_all EXIT
WH="$(_t97_world_harness a5h)" || exit 2; WORLDS+=("$WH")
WP="$(_t97_world_project a5p)" || exit 2; WORLDS+=("$WP")
RH="$WH/repo"; RP="$WP/repo"

BH="$(git -C "$RH" rev-parse main)"; CH="$(git -C "$RH" rev-parse cand)"
BP="$(git -C "$RP" rev-parse main)"; CP="$(git -C "$RP" rev-parse cand)"
MH="$(_t97_merge "$RH" "$BH" "$CH" a5h)" || { printf 'КРАСНО: a5: оракул merge (харнес) не строится\n' >&2; exit 1; }
MP="$(_t97_merge "$RP" "$BP" "$CP" a5p)" || { printf 'КРАСНО: a5: оракул merge (проект) не строится\n' >&2; exit 1; }
OH="$(_t97_expected_id "$RH" "$BH" T-97 main "$BH" "$CH" "$MH")"
OP="$(_t97_expected_id "$RP" "$BP" T-97 main "$BP" "$CP" "$MP")"
[ "$OH" != "$OP" ] || { printf 'КРАСНО: a5: профили не различимы в id\n' >&2; exit 1; }

# положительные пробы: на каждом профиле prepare даёт rc 0 + sha ИМЕННО M
# (родители base+cand, дерево = дерево оракула — снято в память ДО вызова);
# id своего профиля
for probe in h p; do
  if [ "$probe" = h ]; then RR="$RH"; BB="$BH"; CC="$CH"; MM="$MH"; OO="$OH"; NAME=харнес; else RR="$RP"; BB="$BP"; CC="$CP"; MM="$MP"; OO="$OP"; NAME=проект; fi
  otree="$(git -C "$RR" rev-parse "$MM^{tree}")" || exit 2
  _t97_refs_arm "$RR" || exit 2
  refs_before="$(_t97_refs_snap "$RR")" || exit 2
  out="$(bash "$SUBJ" prepare --repo "$RR" --task T-97 --base "$BB" --candidate "$CC")"; rc=$?
  _t97_refs_check "$RR" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
  [ "$rc" -eq 0 ] || { printf 'КРАСНО: a5: успешный prepare профиля %s вернул rc=%s — rc-подмена подготовки (stdout/refs корректны; стаб m17)\n' "$NAME" "$rc" >&2; exit 1; }
  case "$out" in ''|*[!0-9a-f]*)
    printf 'КРАСНО: a5: prepare профиля %s не напечатал merge sha (rc=%s, вывод=%s)\n' "$NAME" "$rc" "$out" >&2; exit 1 ;; esac
  [ "${#out}" -eq 40 ] || { printf 'КРАСНО: a5: prepare профиля %s напечатал не 40 hex: %s\n' "$NAME" "$out" >&2; exit 1; }
  pp="$(git -C "$RR" show -s --format=%P "$out" 2>/dev/null)"
  [ "$pp" = "$BB $CC" ] || { printf 'КРАСНО: a5: prepare профиля %s напечатал не M: %s — родители «%s», ждали «%s %s» (стаб m18)\n' "$NAME" "$out" "$pp" "$BB" "$CC" >&2; exit 1; }
  stree="$(git -C "$RR" rev-parse "$out^{tree}" 2>/dev/null)"
  [ "$stree" = "$otree" ] || { printf 'КРАСНО: a5: prepare профиля %s напечатал не M: дерево %s, оракул merge-tree %s\n' "$NAME" "$stree" "$otree" >&2; exit 1; }
done
oid="$(bash "$SUBJ" object --repo "$RH" --task T-97 --target main --base "$BH" --candidate "$CH" --merge "$MH")" || exit 1
[ "$oid" = "$OH" ] || { printf 'КРАСНО: a5: id профиля харнес не по выведенной политике base (%s, ждали %s)\n' "$oid" "$OH" >&2; exit 1; }
oid="$(bash "$SUBJ" object --repo "$RP" --task T-97 --target main --base "$BP" --candidate "$CP" --merge "$MP")" || exit 1
[ "$oid" = "$OP" ] || { printf 'КРАСНО: a5: id проектного слоя не по политике base (%s, ждали %s)\n' "$oid" "$OP" >&2; exit 1; }

# негативные пробы: неконформная политика на base → именованный отказ И-0
# rc 1 «политика: грамматика», refs не тронуты, main на месте.
# neg_probe <repo> <имя-профиля> <описание-входа> — base = текущий main мира
neg_probe() {
  local r="$1" name="$2" vhod="$3" b c m0 o rc crc refs_before
  b="$(git -C "$r" rev-parse main)"; c="$(git -C "$r" rev-parse cand)"
  m0="$(git -C "$r" rev-parse refs/heads/main)"
  _t97_refs_arm "$r" || exit 2
  refs_before="$(_t97_refs_snap "$r")" || exit 2
  o="$(bash "$SUBJ" prepare --repo "$r" --task T-97 --base "$b" --candidate "$c" 2>&1)"; rc=$?
  _t97_refs_check "$r" "$refs_before"; crc=$?; [ "$crc" -eq 0 ] || exit "$crc"
  { [ "$rc" -eq 1 ] && printf '%s' "$o" | grep -Fq 'политика: грамматика'; } || {
    printf 'КРАСНО: a5: неконформная политика профиля %s (%s) не отказана именованно (rc=%s, вывод=%s)\n' "$name" "$vhod" "$rc" "$o" >&2; exit 1; }
  [ "$(git -C "$r" rev-parse refs/heads/main)" = "$m0" ] || { printf 'КРАСНО: a5: отказ (%s, %s) двинул main\n' "$name" "$vhod" >&2; exit 1; }
}

# харнес, вход 1: ветка вне алфавита И-0 в конформном json-профиле → выведенный текст неконформен
WH2="$(_t97_world_harness a5hb)" || exit 2; WORLDS+=("$WH2")
git -C "$WH2/repo" checkout -q main
printf '{\n  "repoId": "toy-harness-097",\n  "targetBranches": ["main", "feat+x"]\n}\n' >"$WH2/repo/harness.project.json"
_t97_regen "$WH2/repo"
git -C "$WH2/repo" add -A && git -C "$WH2/repo" commit -qm 'branch outside alphabet'
neg_probe "$WH2/repo" харнес 'ветка вне алфавита'

# харнес, вход 2: реестр без step-строк → выведенный текст несёт «mandatory=» (пустой CSV-компонент)
WH3="$(_t97_world_harness a5hm)" || exit 2; WORLDS+=("$WH3")
git -C "$WH3/repo" checkout -q main
printf '# toy-реестр шагов (семья 097): step-строк нет\n' >"$WH3/repo/registry/ci-steps.tsv"
_t97_regen "$WH3/repo"
grep -Fxq 'mandatory=' "$WH3/repo/harness/policy" || { printf 'КРАСНО: a5: выведенный текст харнеса без step-строк не несёт «mandatory=» — вход не построен\n' >&2; exit 1; }
git -C "$WH3/repo" add -A && git -C "$WH3/repo" commit -qm 'registry without steps'
neg_probe "$WH3/repo" харнес 'пустой mandatory='

# проект, вход 3: чужая строка в политике на base
WP2="$(_t97_world_project a5pb)" || exit 2; WORLDS+=("$WP2")
git -C "$WP2/repo" checkout -q main
printf 'repoId=toy-proj-097\nmandatory=p-a,p-b\ntargetBranches=main\nbogus=1\n' >"$WP2/repo/harness/policy"
git -C "$WP2/repo" add -A && git -C "$WP2/repo" commit -qm 'unknown policy line'
neg_probe "$WP2/repo" проект 'чужая строка'

# проект, вход 4: пустой CSV-компонент «mandatory=» на base
WP3="$(_t97_world_project a5pm)" || exit 2; WORLDS+=("$WP3")
git -C "$WP3/repo" checkout -q main
printf 'repoId=toy-proj-097\nmandatory=\ntargetBranches=main\n' >"$WP3/repo/harness/policy"
git -C "$WP3/repo" add -A && git -C "$WP3/repo" commit -qm 'empty mandatory'
neg_probe "$WP3/repo" проект 'пустой mandatory='

# харнес, вход 5: ключ targetBranches с пустым массивом → выведенный текст несёт «targetBranches=»
WH4="$(_t97_world_harness a5ht)" || exit 2; WORLDS+=("$WH4")
git -C "$WH4/repo" checkout -q main
printf '{\n  "repoId": "toy-harness-097",\n  "targetBranches": []\n}\n' >"$WH4/repo/harness.project.json"
_t97_regen "$WH4/repo"
grep -Fxq 'targetBranches=' "$WH4/repo/harness/policy" || { printf 'КРАСНО: a5: выведенный текст харнеса с пустым массивом targetBranches не несёт «targetBranches=» — вход не построен\n' >&2; exit 1; }
git -C "$WH4/repo" add -A && git -C "$WH4/repo" commit -qm 'empty targetBranches array'
neg_probe "$WH4/repo" харнес 'пустой targetBranches='

# проект, вход 6: пустой CSV-компонент «targetBranches=» на base
WP4="$(_t97_world_project a5pt)" || exit 2; WORLDS+=("$WP4")
git -C "$WP4/repo" checkout -q main
printf 'repoId=toy-proj-097\nmandatory=p-a,p-b\ntargetBranches=\n' >"$WP4/repo/harness/policy"
git -C "$WP4/repo" add -A && git -C "$WP4/repo" commit -qm 'empty targetBranches'
neg_probe "$WP4/repo" проект 'пустой targetBranches='
exit 0
