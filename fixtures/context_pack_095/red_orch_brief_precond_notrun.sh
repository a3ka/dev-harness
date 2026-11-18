#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа», часть 2 (контракт 095 v2 Б3; арбитраж
# 095-granica-v2, решения 2–3): семантика NOT_RUN против фактического отказа и
# эффективные пути 996. Стражи 084/182 читают канонические корневые
# registry/plan.tsv, ROADMAP.md и HANDOFF.md; применимость проб — по
# ЭФФЕКТИВНОМУ результату ЕДИНОГО project_paths_resolve (слияние слоёв
# 054/103 + state 996), не по сырому ключу репо-JSON.
# Мир A (нет origin вовсе): sync_main — rc=2 NOT_RUN нет origin/main (своей
# пробы нечем исполнять); plan_slice ИСПОЛНИЛСЯ и вернул именованный отказ об
# источнике — фактический rc=1 и первая строка stderr среза
# (PLAN_SOURCE_UNAVAILABLE), НЕ NOT_RUN; plan_gate зелёная по рабочему дереву.
# Мир E1 (наследуемый registry слоя проекта): репо-слой без workflowPaths,
# defaults несут registry=reg — корневые станционные файлы НЕ становятся
# источником готовности: plan_gate/plan_slice rc=2 NOT_RUN проектные
# workflowPaths вне стража; sync_main честная.
# Мир E2 (state вне корня): registry канонический, state=.harness — стражи
# читают корневые ROADMAP/HANDOFF, эффективные живут под .harness/:
# plan_gate/plan_slice rc=2 NOT_RUN проектные workflowPaths вне стража.
# Мир E3 (сломанный профиль): workflowPaths.registry абсолютный — отказ
# ЕДИНОГО резолвера = отказ двери «workflowPaths вне репо» ДО пака, НЕ
# выдуманная станционная зелёная строка PRECOND.
# Обманы: s54 «именованный отказ спрятан в NOT_RUN», s55 «сырой ключ репо-JSON
# вместо эффективного слияния», s56 «state не судится», s57 «отказ резолвера
# выдан станционной зеленью» → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-notrun: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-notrun: %s\n' "$*" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"

W="$(_t95_world i16nr)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# ── мир A: origin нет вовсе ─────────────────────────────────────────────────
s_rc=0; s_err=""
s_err="$(bash "$ROOT/scripts/orch_plan_slice.sh" --repo "$R" 2>&1 >/dev/null)" || s_rc=$?
[ "$s_rc" -eq 1 ] || red "оракул среза 182 без origin: rc=$s_rc (мир построен неверно)"
a_tail="$(_t95_tail120 "$s_err")"
OA_SYNC="PRECOND: sync_main rc=2 NOT_RUN нет origin/main"
OA_GATE="PRECOND: plan_gate rc=0"
OA_SLICE="PRECOND: plan_slice rc=1 $a_tail"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир без origin: бриф rc=$rc: $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир A: PRECOND-строк не 3'
grep -Fxq "$OA_SYNC"  <<<"$out" || red 'нет origin → sync_main обязана NOT_RUN, не «ok»'
grep -Fxq "$OA_GATE"  <<<"$out" || red 'plan_gate не зелёная по рабочему дереву'
grep -Fxq "$OA_SLICE" <<<"$out" || red 'срез исполнился и отказал именованно → фактический rc=1 и его stderr, НЕ NOT_RUN'

# ── мир E1: наследуемый registry слоя проекта (эффективный reg) ─────────────
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится'
jq 'del(.workflowPaths)' "$R/harness.project.json" >"$W/hj.new" && mv "$W/hj.new" "$R/harness.project.json"
jq '.defaults.workflowPaths.registry = "reg"' "$R/registry/harness-project.json" >"$W/pj.new" && mv "$W/pj.new" "$R/registry/harness-project.json"
git -C "$R" add -A && git -C "$R" -c user.name=f -c user.email=f@l commit -qm 'наследуемый registry=reg'
ab="$(git -C "$R" rev-list --left-right --count origin/main...HEAD)"
OE1_SYNC="PRECOND: sync_main rc=0 behind=${ab%%$'\t'*} ahead=${ab#*$'\t'}"
OE1_PC="PRECOND: plan_gate rc=2 NOT_RUN проектные workflowPaths вне стража"
OE1_PS="PRECOND: plan_slice rc=2 NOT_RUN проектные workflowPaths вне стража"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир наследуемого registry: бриф rc=$rc: $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир E1: PRECOND-строк не 3'
grep -Fxq "$OE1_SYNC" <<<"$out" || red 'sync_main не зависит от workflowPaths (эффективный reg)'
grep -Fxq "$OE1_PC"  <<<"$out" || red 'наследуемый registry обязан увести plan_gate в NOT_RUN (корневые файлы — не источник)'
grep -Fxq "$OE1_PS"  <<<"$out" || red 'наследуемый registry обязан увести plan_slice в NOT_RUN'

# ── мир E2: registry канонический, state вне корня ──────────────────────────
jq '.workflowPaths = {contracts:"contracts",verdicts:"verdicts",registry:"registry",fixtures:"fixtures",state:".harness"}' "$R/harness.project.json" >"$W/hj.new" && mv "$W/hj.new" "$R/harness.project.json"
git -C "$R" add -A && git -C "$R" -c user.name=f -c user.email=f@l commit -qm 'state вне корня'
ab="$(git -C "$R" rev-list --left-right --count origin/main...HEAD)"
OE2_SYNC="PRECOND: sync_main rc=0 behind=${ab%%$'\t'*} ahead=${ab#*$'\t'}"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир state вне корня: бриф rc=$rc: $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир E2: PRECOND-строк не 3'
grep -Fxq "$OE2_SYNC" <<<"$out" || red 'sync_main не зависит от state'
grep -Fxq "$OE1_PC"  <<<"$out" || red 'state вне корня обязан увести plan_gate в NOT_RUN (страж читает корневые ROADMAP/HANDOFF)'
grep -Fxq "$OE1_PS"  <<<"$out" || red 'state вне корня обязан увести plan_slice в NOT_RUN'

# ── мир E3: сломанный профиль — отказ резолвера = отказ двери ───────────────
jq '.workflowPaths.registry = "/etc"' "$R/harness.project.json" >"$W/hj.new" && mv "$W/hj.new" "$R/harness.project.json"
git -C "$R" add -A && git -C "$R" -c user.name=f -c user.email=f@l commit -qm 'сломанный workflowPaths'
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 1 ] || red "сломанный профиль: дверь обязана отказать (rc=$rc), не строить пак: $out"
printf '%s\n' "$out" | grep -Fq 'workflowPaths вне репо' || red 'отказ двери не несёт каноническую фразу резолвера'
if grep -Fq '^PRECOND: ' <<<"$out"; then red 'сломанный профиль: пак с PRECOND-строками выдан вопреки отказу резолвера'; fi
if grep -Fq '=== MAP ===' <<<"$out"; then red 'сломанный профиль: пак выдан вопреки отказу резолвера'; fi
exit 0
