#!/usr/bin/env bash
# Переиспользование bounded WORK из 660d6d24; статусы — frozen084, без DAG.
# Публичный CLI: только WORK сокращается, остальные секции и кап неизменны.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: bounded: предмет отсутствует\n' >&2; exit 1; }
red() { printf 'КРАСНО: bounded: %s\n' "$*" >&2; exit 1; }
W="$(_t95_world bounded)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
# done-тег достаточен даже без frozen; closed-without-done — второй закрытый.
for n in 121 122 131; do
  printf '# Контракт %s\n\n## Предмет\n\nпредмет-%s.\n' "$n" "$n" >"$R/contracts/$n-toy.md"
done
printf '121\t1\tдо V-2\t-\ttoy\ttrack\n122\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
printf '122\tзакрыт решением владельца\n' >"$R/registry/closed-without-done.tsv"
git -C "$R" add -A && git -C "$R" commit -qm 'bounded: закрытые и вне плана'
git -C "$R" tag done/contracts/121/1
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 0 ] || red "малый бриф rc=$rc: $(cat "$W/err")"
grep -q '^WORK: 777 ::' <<<"$out" || red 'открытый 777 скрыт'
if grep -Eq '^WORK: (121|122|131) ::' <<<"$out"; then red 'закрытые или вне-планные попали в WORK'; fi
grep -Fxq 'WORK: опущено: закрытых 2, вне плана 1' <<<"$out" || red 'неверный счёт опущенных'
# Толстый мир — настоящие plan-id, не вне-планный шум.
pad="$(printf '%*s' 1650 '' | tr ' ' x)"
for n in $(seq 500 579); do
  printf '# Контракт %s\n\n## Предмет\n\n%s\n' "$n" "$pad" >"$R/contracts/$n-fat.md"
  printf '%s\t1\tдо V-2\t-\ttoy\ttrack\n' "$n" >>"$R/registry/plan.tsv"
done
# Нормы/карта видимы orchestrator в ЭТОМ входе, а не только architect.
jq '.contextPack.rows += [{kind:"rules",path:"DEVELOPMENT.md",roles:"orchestrator",mandatory:true,why:"нормы"}]' "$R/harness.project.json" >"$W/profile"
mv "$W/profile" "$R/harness.project.json"
goal_want="$(cat "$R/registry/plan.tsv")"
map_want='MAP: PROJECT.md :: карта проекта'
rules_want='RULES: DEVELOPMENT.md'
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 0 ] || red "толстый бриф rc=$rc: $(cat "$W/err")"
section() { awk -v name="$1" '$0=="=== "name" ===" {f=1;next} /^=== / {f=0} f {print}' <<<"$out"; }
[ "$(section GOAL)" = "$goal_want" ] || red 'GOAL усечён'
[ "$(section MAP)" = "$map_want" ] || red 'MAP усечена'
[ "$(section RULES)" = "$rules_want" ] || red 'RULES усечены'
vk="$(sed -n 's/^BUDGET: vklejka=\([0-9]*\)\/40000$/\1/p' <<<"$out")"
# Дочитываем stdin целиком: никакого раннего exit/SIGPIPE под pipefail.
fact="$(awk '/^=== MANIFEST ===$/ {stop=1} !stop {print}' <<<"$out" | wc -c | tr -d ' ')"
[ "$vk" = "$fact" ] && [ "$fact" -le 40000 ] || red "нечестный бюджет $vk/$fact"
shown="$(grep -c '^WORK: [0-9]' <<<"$out")"
newshown="$(grep -c '^WORK: 5[0-9][0-9] ::' <<<"$out")"
[ "$newshown" -gt 0 ] && [ "$shown" -lt 81 ] || red 'кап не испытан или обзор пуст'
omitted="$(sed -n 's/^WORK: за бюджетом брифа: \([0-9]*\) строк;.*/\1/p' <<<"$(section WORK)")"
[[ "$omitted" =~ ^[0-9]+$ ]] || red 'нет явного счётчика сокращённого хвоста'
[ "$((shown + omitted))" -eq 81 ] || red 'счётчик сокращения не соответствует обзору'
rm "$R/PROJECT.md"
no="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
[ "$rc" -eq 1 ] && [ -z "$no" ] || red 'mandatory-потеря не отказала без пака'
grep -Fxq 'ОТКАЗ: источник недоступен: PROJECT.md' "$W/err" || red 'не та причина mandatory-отказа'
exit 0
