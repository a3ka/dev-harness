#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа», часть 4 (контракт 095 v2 Б3; арбитраж
# 095-granica-v2, решение 4): истечение бюджета plan_gate — страж 084 на
# тяжёлом рабочем плане (750 валидных строк с docs-источником, заголовок
# раздела в конце 200-тысячной простыни: каждая строка платит полный проход,
# суммарно ~150 млн построчных чтений) не укладывается в 5 с →
# PRECOND: plan_gate rc=2 NOT_RUN бюджет 5с, НЕ зелёное и НЕ фактический
# отказ. plan_slice остаётся зелёной по ОПУБЛИКОВАННОМУ зелёному плану
# (тяжёлый коммит не публиковался) — источники рабочего и опубликованного
# дерева различаются; sync_main честная (ahead=1). Тяжёлый план (~33 КБ)
# укладывается в кап вклейки: бриф не отказывает «режь задачу».
# Обман s58 «тайм-аут стража выдан зелёным» → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-budget-gate: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-budget-gate: %s\n' "$*" >&2; exit 1; }

W="$(_t95_world i16bgate)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится'
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится (зелёный published план)'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# тяжёлый РАБОЧИЙ план: 750 валидных строк, docs-источник с заголовком в
# конце 200k-строчной простыни (заголовок НАЙДЕН — строки валидны, страж не
# отказывает именованно, а именно не укладывается); публиковать НЕ надо
yes 'заполнение раздела.' | head -n 200000 >"$R/docs/owner/B.md"
printf '\n## Контур\n' >>"$R/docs/owner/B.md"
{
  head -n 1 "$R/registry/plan.tsv"
  i=100; while [ "$i" -lt 850 ]; do printf '%s\t1\tдо V-2\t-\tdocs/owner/B.md#Контур\ttrack\n' "$i"; i=$((i+1)); done
} >"$W/plan.heavy"
cp "$W/plan.heavy" "$R/registry/plan.tsv"
sha="$(git -C "$R" rev-parse HEAD)"
{
  i=100; while [ "$i" -lt 850 ]; do printf '%s → %s\n' "$i" "$sha"; i=$((i+1)); done
} >"$R/registry/contracts.tsv"
git -C "$R" add -A && git -C "$R" -c user.name=f -c user.email=f@l commit -qm 'тяжёлый рабочий план'

ab="$(git -C "$R" rev-list --left-right --count origin/main...HEAD)"
pub="$(git -C "$R" rev-parse origin/main)"
O_SYNC="PRECOND: sync_main rc=0 behind=${ab%%$'\t'*} ahead=${ab#*$'\t'}"
O_GATE="PRECOND: plan_gate rc=2 NOT_RUN бюджет 5с"
O_SLICE="PRECOND: plan_slice rc=0 origin/main=${pub:0:12}"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир тяжёлого плана: бриф rc=$rc (бюджет держит путь пробы, план в капе): $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир тяжёлого плана: PRECOND-строк не 3'
grep -Fxq "$O_SYNC"  <<<"$out" || red 'sync_main на тяжёлом плане не дословна (behind/ahead из rev-list)'
grep -Fxq "$O_GATE"  <<<"$out" || red 'истечение бюджета plan_gate обязано быть NOT_RUN бюджет 5с (НЕ зелёное)'
grep -Fxq "$O_SLICE" <<<"$out" || red 'plan_slice обязана зелёной по ОПУБЛИКОВАННОМУ плану (тяжёлый коммит не публиковался)'
exit 0
