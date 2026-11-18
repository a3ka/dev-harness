#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа — отсутствие стража check_plan» (контракт 095
# v2 Б3; блок К-08 вердикта Crit095V4): замкнутый перечень причин NOT_RUN
# (арбитраж 095-granica-v2, решение 2) содержит «нет scripts/check_plan.sh» —
# отсутствие инструмента обязано различаться от ЗАПУСКА отсутствующего файла:
# мутант с удалённой ветвью проверки исполняет bash по несуществующему пути и
# выдаёт rc=127 с диагностикой bash вместо rc=2 NOT_RUN — атака К-08 оставляла
# зелёными все пять клеток red_orch_brief_precond*.sh.
# Мир: план-зелёный toy-репозиторий + bare-origin; КОРЕНЬ субъекта — копия
# scripts/ настоящего корня БЕЗ scripts/check_plan.sh (срез 182, генераторы и
# ЕДИНЫЙ резолвер 996 в копии остаются — удалён ТОЛЬКО страж 084).
# Ожидания — из контракта И-16 и грамматики модели (dover.sh:253-255), НЕ из
# ответа субъекта (правило 8): sync_main rc=0 behind/ahead (свой rev-list),
# plan_gate rc=2 NOT_RUN нет scripts/check_plan.sh, plan_slice rc=0
# origin/main=<12hex> (свой rev-parse; оракул сам прогоняет срез 182 из копии
# ДО субъекта). Красная проба не роняет бриф. Обман s62 «ветвь проверки
# отсутствия check_plan снята» → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-net-check-plan: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-net-check-plan: %s\n' "$*" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"
[ -f "$ROOT/scripts/check_plan.sh" ] || red 'в настоящем корне нет scripts/check_plan.sh — мир клетки не строится'

W="$(_t95_world i16ncp)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится (gen_plan/стражи 084)'
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# корень субъекта: копия scripts/ без стража 084; резолвер 996 и срез 182 остаются
NG="$W/root-net-check-plan"
mkdir -p "$NG" || red 'корень без стража не строится'
cp -a "$ROOT/scripts" "$NG/scripts" || red 'копия scripts/ не строится'
rm -f "$NG/scripts/check_plan.sh"
[ ! -e "$NG/scripts/check_plan.sh" ] || red 'страж 084 не удалён из копии корня'
[ -f "$NG/scripts/orch_plan_slice.sh" ] || red 'срез 182 потерян из копии корня'
[ -f "$NG/scripts/next_id.sh" ] || red 'резолвер 996 потерян из копии корня'

# оракул ДО вызова (правило 8): срез из копии зелёен, стража в копии нет
s_rc=0
bash "$NG/scripts/orch_plan_slice.sh" --repo "$R" >/dev/null 2>&1 || s_rc=$?
[ "$s_rc" -eq 0 ] || red "оракул среза 182 из копии корня: rc=$s_rc (мир построен неверно)"
sha="$(git -C "$R" rev-parse origin/main)"
ab="$(git -C "$R" rev-list --left-right --count origin/main...HEAD)"
O_SYNC="PRECOND: sync_main rc=0 behind=${ab%%$'\t'*} ahead=${ab#*$'\t'}"
O_GATE="PRECOND: plan_gate rc=2 NOT_RUN нет scripts/check_plan.sh"
O_SLICE="PRECOND: plan_slice rc=0 origin/main=${sha:0:12}"

out="$(CP095_ROOT="$NG" bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир без стража 084: бриф rc=$rc (красная проба НЕ роняет бриф): $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'PRECOND-строк не 3 (замкнутый перечень)'
grep -Fxq "$O_SYNC"  <<<"$out" || red 'sync_main не дословна (behind/ahead из своего rev-list)'
grep -Fxq "$O_GATE"  <<<"$out" || red 'нет scripts/check_plan.sh → plan_gate обязана rc=2 NOT_RUN с названием инструмента, а не запуск отсутствующего файла (rc=127/bash)'
grep -Fxq "$O_SLICE" <<<"$out" || red 'plan_slice не зелёная дословно (срез 182 в копии корня есть)'
exit 0
