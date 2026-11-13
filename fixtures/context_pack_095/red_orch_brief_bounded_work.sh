#!/usr/bin/env bash
# Клетка И-17 «bounded WORK-обзор» (095, sol-1112; followup-1112 — только
# свойства, без пинирования формулировок): живой бриф недостижим — WORK всех
# контрактов ~99K против капа вклейки 40000. Бриф собирается СОДЕРЖАТЕЛЬНЫМ и
# ОГРАНИЧЕННЫМ: WORK-строки несут только незакрытые пункты плана; закрытое
# (терминальный done — done-коммит СОДЕРЖИТ frozen-коммит высшего тега,
# merge-base --is-ancestor; «закрыт без done» по реестру) и вне-планные
# контракты не заполняют обзор; при выходе хвоста за бюджет — показана часть,
# пак не умирает «режь задачу», BUDGET = пересчёту проверяющего и ≤ 40000.
# Лимит 40000 НЕ повышается (И-9 не трогается); RULES/MAP/GOAL не усекаются.
# followup-1112: терминальный done 121 строится НАСТОЯЩИМИ последовательными
# коммитами (frozen@A → done@B, B содержит A), а не тегами на одном коммите.
# Вход каждой ветви — СВОЙ:
#   (а) мир с терминальным done 121 и вне-планным 131: оба ОТСУТСТВУЮТ в
#       WORK-строках; активный 777 присутствует (положительный контроль);
#   (б) бюджет честен: BUDGET равен пересчёту проверяющим (байты до
#       === MANIFEST ===) и ≤ 40000;
#   (в) мир-толстяк: 81 незакрытый пункт (базовый 777 + 80 новых 500..579),
#       предметы длиннее выдержки 480 — суммарный обзор ЗА капом; rc 0 (не
#       «режь задачу»), обзор НЕ пуст (в т.ч. WORK-строки из НОВОГО набора —
#       ловит дефект самого мира: корпус, опущенный как вне-планный) и НЕ
#       полон (кап испытан), полный GOAL дословен, BUDGET = пересчёту ≤ 40000.
# Обманы (s29: кап снят) → клетка красна. Оракулы — в памяти ДО вызова
# (правило 8); сверки структурные (grep, awk, wc -c).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: orch-brief-bounded-work: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

red() { printf 'КРАСНО: И-17 %s\n' "$*" >&2; exit 1; }

W="$(_t95_world bounded)" || exit 2
WFAT="$(_t95_world bounded-fat)" || exit 2
trap '_t95_cleanup "$W"; _t95_cleanup "$WFAT"' EXIT
R="$W/repo"; RF="$WFAT/repo"
for t in "$W/trace.tsv" "$WFAT/trace.tsv"; do
  _t95_trace "$t" orchestrator glm-4.7 allowed
done

# ── мир (а)/(б): 121 — терминальный done (done-коммит содержит frozen);
# 131 — вне плана с предметом; 777/888 — база мира (незакрытые) ───────────
mkdir -p "$R/impl"
printf '# Контракт 121 — терминальный done toy\n\n## Предмет\n\nпредмет-121.\n' >"$R/contracts/121-done-toy.md"
printf '121\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
printf '# Контракт 131 — вне плана toy\n\n## Предмет\n\nпредмет-131.\n' >"$R/contracts/131-vneplana-toy.md"
git -C "$R" add -A && git -C "$R" commit -qm 'bounded: 121 frozen-коммит'
GIT_COMMITTER_DATE='@1700000100 +0000' git -C "$R" tag -a -m toy frozen/contracts/121/1
printf 'impl 121\n' >"$R/impl/121.txt"
git -C "$R" add -A && git -C "$R" commit -qm 'bounded: реализация 121 (done содержит frozen)'
GIT_COMMITTER_DATE='@1700000200 +0000' git -C "$R" tag -a -m toy done/contracts/121/1

# (а) закрытое и вне-планное не заполняют обзор; незакрытые — строкой WORK
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err.a")"; rc=$?
[ "$rc" -eq 0 ] || red "(а) бриф не строится: rc=$rc, stderr: $(cat "$W/err.a")"
printf '%s\n' "$out" | grep -q '^WORK: 777 ::' || red "(а) незакрытый пункт плана (777) без WORK-строки — положительный контроль"
printf '%s\n' "$out" | grep -q '^WORK: 121 ::' && red "(а) терминальный done показан WORK-строкой (121) — закрытое заполняет обзор"
printf '%s\n' "$out" | grep -q '^WORK: 131 ::' && red "(а) вне-планный контракт показан WORK-строкой (131)"

# (б) бюджет честен: BUDGET = пересчёт проверяющего, ≤ 40000
vk="$(printf '%s\n' "$out" | sed -n 's/^BUDGET: vklejka=\([0-9]*\)\/40000$/\1/p')"
fact="$(printf '%s\n' "$out" | awk '/^=== MANIFEST ===$/{exit} {print}' | wc -c | tr -d ' ')"
{ [ -n "$vk" ] && [ "$vk" = "$fact" ]; } || red "(б) BUDGET «$vk» != пересчёт вклейки проверяющим «$fact»"
[ "$fact" -le 40000 ] || red "(б) вклейка $fact > 40000 — лимит превышен"

# ── мир (в): 80 незакрытых пунктов 500..579 (предметы длиннее выдержки
# 480 симв.) + базовый 777 — 81 строка × ≥496 байт ЗА капом 40000 даже при
# пустой остальной вклейке (доступно < 39788); id в колонке id плана —
# НАСТОЯЩИЕ ($n), иначе новый набор опускается как вне-планный (дефект круга
# sol-1112: кап не испытан, shown=1) ────────────────────────────────────────
pad="$(printf '%*s' 1650 '' | tr ' ' x)"
FAT_FROM=500; FAT_TO=579
for n in $(seq "$FAT_FROM" "$FAT_TO"); do
  printf '# Контракт %s — толстяк\n\n## Предмет\n\n%s\n' "$n" "$pad" >"$RF/contracts/${n}-fat-toy.md"
  printf '%s\t1\tдо V-2\t-\ttoy\ttrack\n' "$n" >>"$RF/registry/plan.tsv"
done
git -C "$RF" add -A && git -C "$RF" commit -qm 'bounded: 80 жирных незакрытых'
n_fat=$(( FAT_TO - FAT_FROM + 1 ))
ORACLE_ACTIVE=$(( n_fat + 1 ))  # 500..579 + базовый 777 (все без done-тегов)
goal_want="$(cat "$RF/registry/plan.tsv")"  # полный GOAL — в памяти ДО вызова

outf="$(bash "$SUBJ" --repo "$RF" --role orchestrator --kind brief --model-trace "$WFAT/trace.tsv" 2>"$WFAT/err.c")"; rcf=$?
[ "$rcf" -eq 0 ] || red "(в) толстый бриф умер «режь задачу» вместо капа: rc=$rcf, stderr: $(cat "$WFAT/err.c")"
vkf="$(printf '%s\n' "$outf" | sed -n 's/^BUDGET: vklejka=\([0-9]*\)\/40000$/\1/p')"
factf="$(printf '%s\n' "$outf" | awk '/^=== MANIFEST ===$/{exit} {print}' | wc -c | tr -d ' ')"
{ [ -n "$vkf" ] && [ "$vkf" = "$factf" ]; } || red "(в) BUDGET «$vkf» != пересчёт «$factf»"
[ "$factf" -le 40000 ] || red "(в) вклейка $factf > 40000: кап не держит бюджет"
goal_got="$(printf '%s\n' "$outf" | awk '/^=== GOAL ===$/{f=1;next} /^=== /{f=0} f{print}')"
[ "$goal_got" = "$goal_want" ] || red "(в) GOAL брифа не дословен из plan.tsv — кап ужал план"
shown="$(printf '%s\n' "$outf" | grep -c '^WORK: [0-9]')"
newshown="$(printf '%s\n' "$outf" | grep -c '^WORK: 5[0-9][0-9] ::')"
[ "$newshown" -ge 1 ] || red "(в) из нового набора 500..579 нет ни одной WORK-строки — корпус опущен как вне-планный, кап не испытан (дефект мира)"
[ "$shown" -ge 1 ] || red "(в) обзор пуст — работа полностью скрыта капом"
[ "$shown" -lt "$ORACLE_ACTIVE" ] || red "(в) показаны все $ORACLE_ACTIVE — кап не испытан"
exit 0
