#!/usr/bin/env bash
# Клетка И-16 «строка-маркер БРИФ НЕ СОБРАН вместо отказа брифа» (контракт 095
# v2, Н-439; слово владельца 2026-11-10 ~18:27 UTC «7. да»). Брифинг
# (`--kind brief`, оркестратор) на активном контракте (NNN в колонке id
# registry/plan.tsv) без `## Предмет` НЕ умирает: первой строкой stdout — по
# строке `БРИФ НЕ СОБРАН: контракт без предмета: <путь>` на каждый такой
# контракт, за ними заголовок пака; rc 0; пак собран целиком (GOAL дословно,
# WORK: у неисправного — `без-§Предмет (в plan.tsv)`, HEALTH, BUDGET по
# пересчёту проверяющего включает строки маркера). Вход каждой ветви — СВОЙ:
#   (а) мир с двумя активными без предмета (531, 532), предметным 777 и
#       legacy вне плана 666 — маркер ровно на два, первыми строками, rc 0,
#       пак не усечён;
#   (б) парный негатив: мир без активных без предмета — ни одной строки
#       `^БРИФ НЕ СОБРАН: `, stdout начинается с заголовка пака;
#   (в) `--kind task` в том же дефектном мире (заморозка 777): маркера в
#       задачном паке нет;
#   (г) отказы безопасности НЕ маркер, даже при дефектном плане: нет
#       --model-trace / трасса без строки роли / брифинг не оркестратору —
#       rc 1, stdout пуст, «ОТКАЗ: …» именем.
# Оракулы (строки маркера, план, WORK-строки) снимаются в память ДО вызова
# (правило 8); сверки структурные (grep -Fx, awk index()==1, побайтово).
# Каждая ветвь красна своим предъявлением: стаб-пак привязывает порчу к ветви
# по КОДУ (battery_stubs.sh, шапка).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: orch-brief-marker: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

PFX='БРИФ НЕ СОБРАН: '
red() { printf 'КРАСНО: И-16 %s\n' "$*" >&2; exit 1; }
# число строк, НАЧИНАЮЩИХСЯ с маркера (литерал, не подстрока где-угодно)
nmark() { printf '%s\n' "$1" | awk -v p="$PFX" 'index($0,p)==1' | wc -l | tr -d ' '; }
line() { printf '%s\n' "$1" | sed -n "${2}p"; }

W="$(_t95_world marker)" || exit 2
W2="$(_t95_world marker-clean)" || exit 2
trap '_t95_cleanup "$W"; _t95_cleanup "$W2"' EXIT
R="$W/repo"
R2="$W2/repo"
for t in "$W/trace.tsv" "$W2/trace.tsv"; do
  _t95_trace "$t" orchestrator glm-4.7 allowed
  _t95_trace "$t" implementer glm-4.7 allowed
  _t95_trace "$t" architect glm-4.7 allowed
done
# трасса без строки оркестратора (ветвь г2)
_t95_trace "$W/trace_noorch.tsv" architect glm-4.7 allowed

# мир (а): 531/532 — АКТИВНЫЕ (строки в plan.tsv) без «## Предмет»;
# 666 — legacy вне плана без предмета; 777 — штатный предметный.
for spec in '531:aktiv-a' '532:aktiv-b'; do
  n="${spec%%:*}"; s="${spec#*:}"
  cat >"$R/contracts/${n}-${s}-toy.md" <<EOF
# Контракт ${n} — актив без предмета

## Существующее

- активный контракт без секции предмета
EOF
  printf '%s\t1\tдо V-2\t-\ttoy\ttrack\n' "$n" >>"$R/registry/plan.tsv"
done
cat >"$R/contracts/666-legacy-toy.md" <<'EOF'
# Контракт 666 — legacy toy

## Существующее

- toy-код без секции предмета
EOF
git -C "$R" add -A && git -C "$R" commit -qm 'мир маркера: два активных без предмета'
# мир (б): только legacy 666 вне плана — активных без предмета НЕТ
cp "$R/contracts/666-legacy-toy.md" "$R2/contracts/666-legacy-toy.md"
git -C "$R2" add -A && git -C "$R2" commit -qm 'мир чистого брифа'

# оракулы ДО вызова (правило 8)
WANT_M1="${PFX}контракт без предмета: $R/contracts/531-aktiv-a-toy.md"
WANT_M2="${PFX}контракт без предмета: $R/contracts/532-aktiv-b-toy.md"
WANT_PLAN="$(cat "$R/registry/plan.tsv")"
WANT_W531='WORK: 531 :: без-§Предмет (в plan.tsv)'
WANT_W532='WORK: 532 :: без-§Предмет (в plan.tsv)'
WANT_W777='WORK: 777 :: toy-предмет.'
WANT_W666='WORK: 666 :: legacy-без-§Предмет (вне plan.tsv)'

# (а) дефектный план — маркер вместо отказа
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err.a")"; rc=$?
[ "$rc" -eq 0 ] || red "(а) активный контракт без предмета убил бриф вместо маркера: rc=$rc, stderr: $(cat "$W/err.a")"
for w in "$WANT_W531" "$WANT_W532" "$WANT_W777" "$WANT_W666"; do
  printf '%s\n' "$out" | grep -Fxq -- "$w" || red "(а) молчаливое сужение WORK-карты: нет строки «$w»"
done
[ "$(line "$out" 1)" = "$WANT_M1" ] || red "(а) первая строка stdout — не маркер контракта 531 с причиной: «$(line "$out" 1)»"
[ "$(line "$out" 2)" = "$WANT_M2" ] || red "(а) вторая строка stdout — не маркер контракта 532 с причиной: «$(line "$out" 2)»"
case "$(line "$out" 3)" in
  '=== make_task '*) ;;
  *) red "(а) за строками маркера нет заголовка пака: «$(line "$out" 3)»" ;;
esac
[ "$(nmark "$out")" = "2" ] || red "(а) строк-маркеров $(nmark "$out"), ожидалось ровно 2 (по числу активных без предмета)"
goal="$(printf '%s\n' "$out" | awk '/^=== GOAL ===$/{f=1;next} /^=== /{f=0} f{print}')"
[ "$goal" = "$WANT_PLAN" ] || red "(а) GOAL не дословен из реестра плана при маркере"
printf '%s\n' "$out" | grep -Fxq 'HEALTH: branch=main dirty=0' || red "(а) пак при маркере без здоровья (HEALTH)"
vk="$(printf '%s\n' "$out" | sed -n 's/^BUDGET: vklejka=\([0-9]*\)\/40000$/\1/p')"
fact="$(printf '%s\n' "$out" | awk '/^=== MANIFEST ===$/{exit} {print}' | wc -c | tr -d ' ')"
{ [ -n "$vk" ] && [ "$vk" = "$fact" ]; } || red "(а) BUDGET «$vk» != пересчёт вклейки проверяющим «$fact» (строки маркера входят в вклейку)"

# (б) парный негатив: нет активных без предмета — маркера нет, пак чист
out2="$(bash "$SUBJ" --repo "$R2" --role orchestrator --kind brief --model-trace "$W2/trace.tsv" 2>"$W2/err.b")"; rc2=$?
[ "$rc2" -eq 0 ] || red "(б) чистый бриф не строится: rc=$rc2, stderr: $(cat "$W2/err.b")"
[ "$(nmark "$out2")" = "0" ] || red "(б) ложный маркер на чистом брифе (активных без предмета нет): $(printf '%s\n' "$out2" | awk -v p="$PFX" 'index($0,p)==1')"
case "$(line "$out2" 1)" in
  '=== make_task '*) ;;
  *) red "(б) чистый бриф начинается не с заголовка пака: «$(line "$out2" 1)»" ;;
esac
printf '%s\n' "$out2" | grep -Fxq -- "$WANT_W777" || red "(б) чистый бриф без WORK 777"
printf '%s\n' "$out2" | grep -Fxq -- "$WANT_W666" || red "(б) чистый бриф без legacy-строки WORK 666"

# (в) --kind task в дефектном мире: маркер в задачном паке не допускается
_t95_freeze "$R" 'scripts/toy.sh' >/dev/null
out3="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>"$W/err.c")"; rc3=$?
[ "$rc3" -eq 0 ] || red "(в) задачный пак по замороженному 777 не строится: rc=$rc3, stderr: $(cat "$W/err.c")"
printf '%s\n' "$out3" | grep -Fxq '=== ZONES ===' || red "(в) задачный пак без ZONES — не задачный режим"
[ "$(nmark "$out3")" = "0" ] || red "(в) строка «БРИФ НЕ СОБРАН» в задачном паке (--kind task): маркер только у брифа"

# (г) отказы безопасности остаются отказами при том же дефектном плане
out4="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief 2>"$W/err.d1")"; rc4=$?
[ "$rc4" -eq 1 ] || red "(г1) без свидетельства модели: rc=$rc4, ожидался 1 (отказ безопасности не маркер)"
[ -z "$out4" ] || red "(г1) отказ без свидетельства модели несёт stdout: «$out4»"
grep -Fxq 'ОТКАЗ: нет свидетельства модели: orchestrator' "$W/err.d1" || red "(г1) отказ не именем «нет свидетельства модели: orchestrator»: $(cat "$W/err.d1")"
out5="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace_noorch.tsv" 2>"$W/err.d2")"; rc5=$?
[ "$rc5" -eq 1 ] || red "(г2) трасса без строки роли: rc=$rc5, ожидался 1"
[ -z "$out5" ] || red "(г2) отказ «не той роли» несёт stdout: «$out5»"
grep -Fxq 'ОТКАЗ: свидетельство не той роли: orchestrator' "$W/err.d2" || red "(г2) отказ не именем «свидетельство не той роли: orchestrator»: $(cat "$W/err.d2")"
out6="$(bash "$SUBJ" --repo "$R" --role architect --kind brief --model-trace "$W/trace.tsv" 2>"$W/err.d3")"; rc6=$?
[ "$rc6" -eq 1 ] || red "(г3) брифинг не оркестратору: rc=$rc6, ожидался 1"
[ -z "$out6" ] || red "(г3) отказ «только оркестратору» несёт stdout: «$out6»"
grep -Fxq 'ОТКАЗ: брифинг только оркестратору' "$W/err.d3" || red "(г3) отказ не именем «брифинг только оркестратору»: $(cat "$W/err.d3")"
exit 0
