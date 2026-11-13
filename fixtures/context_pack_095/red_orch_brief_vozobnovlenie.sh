#!/usr/bin/env bash
# Клетка И-18 «новая версия не скрывается старым done; закрытое не заполняет
# обзор» (095, followup-1112). Оракул статуса — DAG, не часы: done закрывает
# предмет только если frozen-КОММИТ высшего тега содержится в done-коммите
# (merge-base --is-ancestor; семантика ЕДИНОГО plan_status lib_plan 084 —
# общий для ROADMAP/HANDOFF/brief, не третья копия). followup-1112 чинит
# дефект прежней клетки: frozen1/done1/frozen2 стояли НА ОДНОМ коммите и
# различались только датами тегов — она моделировала сдвиг часов, а не новую
# версию, и закрепляла timestamp бизнес-семантикой. Теперь — НАСТОЯЩИЕ
# последовательные коммиты, а даты тегов ВВОДЯТ В ЗАБЛУЖДЕНИЕ (готовность не
# определяется creatordate: статус по датам — ошибка, ловится стабом s26).
# Вход каждой ветви — СВОЙ (свой предмет и своя история коммитов):
#   (а) 222 возобновлённый: v1@A → frozen/1@A → done/1@B (B содержит A) →
#       v2-текст@C → frozen/2@C; C НЕ содержится в B → старый done НЕ
#       закрывает новую версию → 222 ПОКАЗАН строкой WORK с предметом v2;
#       даты: тег frozen/2 СТАРЕЕ тега done — статус-по-датам спрятал бы;
#   (б) 333 терминальный done: frozen/1@D → done/1@E (E содержит D) →
#       НЕТ строки WORK: 333; положительный контроль — 777 показан (иначе
#       негатив проходил бы на пустом обзоре); даты: тег frozen НОВЕЕ тега
#       done — статус-по-датам показал бы закрытое;
#   (г) 456 «закрыт без done» (registry/closed-without-done.tsv, без тегов) —
#       НЕТ строки WORK: 456.
# Свойства (проверяются ТОЛЬКО они; точных формулировок префиксов/счётных
# строк клетка не пинит): полнота GOAL, показ/скрытие работы, бюджет.
# Обманы (s26: статус по creatordate тегов; s27: done-ветвь статуса снята —
# терминальный показан) → клетка красна. Оракулы — в памяти ДО вызова
# (правило 8); сверки структурные.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: orch-brief-vozobnovlenie: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

red() { printf 'КРАСНО: И-18 %s\n' "$*" >&2; exit 1; }

W="$(_t95_world voz)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# ── мир: реальные последовательные коммиты; даты тегов лгут ────────────────
# 222: v1 (предмет-222-v1.) → frozen/1; реализация → done/1; v2-текст
# (предмет-222-v2.) → frozen/2. Тег done ПОМЕЧЕН ПОЗЖЕ тега frozen/2.
mkdir -p "$R/impl"
printf '# Контракт 222 — возобновлён toy\n\n## Предмет\n\nпредмет-222-v1.\n' >"$R/contracts/222-vozobnovlen-toy.md"
printf '222\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
printf '# Контракт 333 — терминальный toy\n\n## Предмет\n\nпредмет-333.\n' >"$R/contracts/333-terminal-toy.md"
printf '333\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
printf '# Контракт 456 — закрыт без done toy\n\n## Предмет\n\nпредмет-456.\n' >"$R/contracts/456-zakryt-toy.md"
printf '456\t1\tдо V-2\t-\ttoy\ttrack\n' >>"$R/registry/plan.tsv"
printf '456\ttoy-причина закрытия без done\n' >"$R/registry/closed-without-done.tsv"
git -C "$R" add -A && git -C "$R" commit -qm 'voz: 222 v1 + 333 + 456'
GIT_COMMITTER_DATE='@1700000100 +0000' git -C "$R" tag -a -m toy frozen/contracts/222/1
GIT_COMMITTER_DATE='@1700000800 +0000' git -C "$R" tag -a -m toy frozen/contracts/333/1   # ЛЖИВАЯ дата: новее done/333/1
printf 'impl 333\n' >"$R/impl/333.txt"
git -C "$R" add -A && git -C "$R" commit -qm 'voz: реализация 333 (done содержит frozen)'
GIT_COMMITTER_DATE='@1700000300 +0000' git -C "$R" tag -a -m toy done/contracts/333/1   # ЛЖИВАЯ дата: старее frozen/333/1
printf 'impl 222\n' >"$R/impl/222.txt"
git -C "$R" add -A && git -C "$R" commit -qm 'voz: реализация 222 v1 (done содержит frozen v1)'
GIT_COMMITTER_DATE='@1700000900 +0000' git -C "$R" tag -a -m toy done/contracts/222/1   # ЛЖИВАЯ дата: новее frozen/222/2
printf '# Контракт 222 — возобновлён toy\n\n## Предмет\n\nпредмет-222-v2.\n' >"$R/contracts/222-vozobnovlen-toy.md"
git -C "$R" add -A && git -C "$R" commit -qm 'voz: 222 v2 — новая версия предмета'
GIT_COMMITTER_DATE='@1700000400 +0000' git -C "$R" tag -a -m toy frozen/contracts/222/2   # ЛЖИВАЯ дата: старее done/222/1
# 333: done-коммит СОДЕРЖИТ frozen-коммит → терминальный. 222: frozen/2-коммит
# НЕ содержится в done-коммите → возобновлён. Обе пары дат тегов противоречат DAG.

# оракулы ДО вызова (правило 8): план и предметы — из файлов, которые мир только что записал
WANT_PLAN="$(cat "$R/registry/plan.tsv")"

out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>"$W/err.a")"; rc=$?
[ "$rc" -eq 0 ] || red "бриф не строится: rc=$rc, stderr: $(cat "$W/err.a")"

# (а) новая версия не скрывается старым done: 222 показан С ПРЕДМЕТОМ v2
w222="$(printf '%s\n' "$out" | grep '^WORK: 222 ::' | head -n 1)"
[ -n "$w222" ] || red "(а) возобновлённый 222 скрыт старым done (frozen/2-коммит не содержится в done-коммите) — WORK-строки нет"
printf '%s' "$w222" | grep -Fq 'предмет-222-v2.' || red "(а) 222 показан не предметом новой версии: «$w222»"

# (б) закрытое не заполняет обзор: терминальный done 333 и «закрыт без done» 456 опущены
printf '%s\n' "$out" | grep -q '^WORK: 333 ::' && red "(б) терминальный done показан WORK-строкой (333) — done-коммит содержит frozen, предмет закрыт"
printf '%s\n' "$out" | grep -q '^WORK: 456 ::' && red "(б) «закрыт без done» показан WORK-строкой (456)"
# положительный контроль негативов: незакрытый 777 виден (пустой обзор не проходит)
printf '%s\n' "$out" | grep -q '^WORK: 777 ::' || red "(б) положительный контроль: незакрытый 777 не показан — negatives (а)/(б) ничего не доказывают"

# полный GOAL: байты реестра плана дословно (оракул в памяти)
goal="$(printf '%s\n' "$out" | awk '/^=== GOAL ===$/{f=1;next} /^=== /{f=0} f{print}')"
[ "$goal" = "$WANT_PLAN" ] || red "GOAL не дословен из реестра плана"

# бюджет: BUDGET = пересчёт проверяющего (байты до === MANIFEST ===), ≤ 40000
vk="$(printf '%s\n' "$out" | sed -n 's/^BUDGET: vklejka=\([0-9]*\)\/40000$/\1/p')"
fact="$(printf '%s\n' "$out" | awk '/^=== MANIFEST ===$/{exit} {print}' | wc -c | tr -d ' ')"
{ [ -n "$vk" ] && [ "$vk" = "$fact" ] && [ "$fact" -le 40000 ]; } || red "BUDGET «$vk» != пересчёт «$fact» или > 40000"
exit 0
