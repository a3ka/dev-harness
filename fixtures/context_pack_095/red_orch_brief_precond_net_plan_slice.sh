#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа — отсутствие среза orch_plan_slice» (контракт
# 095 v2 Б3; блок К-08 вердикта Crit095V4): замкнутый перечень причин NOT_RUN
# (арбитраж 095-granica-v2, решение 2) содержит «нет
# scripts/orch_plan_slice.sh» — отсутствие инструмента обязано различаться
# от ЗАПУСКА отсутствующего файла: мутант с удалённой ветвью проверки
# исполняет bash по несуществующему пути и выдаёт rc=127 с диагностикой bash
# вместо rc=2 NOT_RUN — атака К-08 оставляла зелёными все пять клеток
# red_orch_brief_precond*.sh. Отдельная клетка от net_check_plan: удаление
# КАЖДОЙ проверки краснеет отдельно (Н-39 — привязка по входу, где дефект
# наблюдаем).
# Мир: план-зелёный toy-репозиторий + bare-origin; КОРЕНЬ субъекта — копия
# scripts/ настоящего корня БЕЗ scripts/orch_plan_slice.sh (страж 084,
# генераторы и ЕДИНЫЙ резолвер 996 в копии остаются).
# Ожидания — из контракта И-16 и грамматики модели (dover.sh:272-274), НЕ из
# ответа субъекта (правило 8): sync_main rc=0 behind/ahead (свой rev-list),
# plan_gate rc=0 (оракул сам прогоняет стража 084 из копии ДО субъекта),
# plan_slice rc=2 NOT_RUN нет scripts/orch_plan_slice.sh. Красная проба не
# роняет бриф. Обман s63 «ветвь проверки отсутствия plan_slice снята» →
# клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-net-plan-slice: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-net-plan-slice: %s\n' "$*" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"
[ -f "$ROOT/scripts/orch_plan_slice.sh" ] || red 'в настоящем корне нет scripts/orch_plan_slice.sh — мир клетки не строится'

W="$(_t95_world i16nps)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится (gen_plan/стражи 084)'
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# корень субъекта: копия scripts/ без среза 182; резолвер 996 и страж 084 остаются
NG="$W/root-net-plan-slice"
mkdir -p "$NG" || red 'корень без среза не строится'
cp -a "$ROOT/scripts" "$NG/scripts" || red 'копия scripts/ не строится'
rm -f "$NG/scripts/orch_plan_slice.sh"
[ ! -e "$NG/scripts/orch_plan_slice.sh" ] || red 'срез 182 не удалён из копии корня'
[ -f "$NG/scripts/check_plan.sh" ] || red 'страж 084 потерян из копии корня'
[ -f "$NG/scripts/next_id.sh" ] || red 'резолвер 996 потерян из копии корня'

# оракул ДО вызова (правило 8): страж 084 из копии зелёен, среза в копии нет
g_rc=0
bash "$NG/scripts/check_plan.sh" --root "$R" >/dev/null 2>&1 || g_rc=$?
[ "$g_rc" -eq 0 ] || red "оракул стража 084 из копии корня: rc=$g_rc (мир построен неверно)"
ab="$(git -C "$R" rev-list --left-right --count origin/main...HEAD)"
O_SYNC="PRECOND: sync_main rc=0 behind=${ab%%$'\t'*} ahead=${ab#*$'\t'}"
O_GATE="PRECOND: plan_gate rc=0"
O_SLICE="PRECOND: plan_slice rc=2 NOT_RUN нет scripts/orch_plan_slice.sh"

out="$(CP095_ROOT="$NG" bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир без среза 182: бриф rc=$rc (красная проба НЕ роняет бриф): $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'PRECOND-строк не 3 (замкнутый перечень)'
grep -Fxq "$O_SYNC"  <<<"$out" || red 'sync_main не дословна (behind/ahead из своего rev-list)'
grep -Fxq "$O_GATE"  <<<"$out" || red 'plan_gate не зелёная дословно (страж 084 в копии корня есть)'
grep -Fxq "$O_SLICE" <<<"$out" || red 'нет scripts/orch_plan_slice.sh → plan_slice обязана rc=2 NOT_RUN с названием инструмента, а не запуск отсутствующего файла (rc=127/bash)'
exit 0
