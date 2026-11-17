#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа», часть 2 (контракт 095 v2 Б3): недоступная
# проверка — NOT_RUN с именованной причиной, НЕ «ok»; бюджет пробы (timeout)
# и граница проектных workflowPaths (996: стражи 084/182 читают канонические
# registry/ и ROADMAP/HANDOFF корня — проектные пути вне их домена).
# Мир 1 (нет origin вовсе): sync_main и plan_slice — rc=2 NOT_RUN нет
# origin/main; plan_gate зелёная по рабочему дереву.
# Мир 2 (бюджет): packed-refs bare-origin — FIFO, ls-remote среза 182
# зависает → plan_slice rc=2 NOT_RUN бюджет 8с; sync_main/plan_gate зелёные.
# Мир 3 (проектные workflowPaths ≠ registry): plan_gate и plan_slice —
# rc=2 NOT_RUN проектные workflowPaths вне стража; sync_main не зависит от
# путей и остаётся честной.
# Обман s49 «бюджет без NOT_RUN» (тайм-аут выдан зелёным) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-notrun: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-notrun: %s\n' "$*" >&2; exit 1; }
fini() { command -v pkill >/dev/null 2>&1 && pkill -f "$1/origin.git" 2>/dev/null; _t95_cleanup "$1"; }

W="$(_t95_world i16nr)" || exit 2
trap 'fini "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed

# ── мир 1: origin нет вовсе ─────────────────────────────────────────────────
O1_SYNC="PRECOND: sync_main rc=2 NOT_RUN нет origin/main"
O1_GATE="PRECOND: plan_gate rc=0"
O1_SLICE="PRECOND: plan_slice rc=2 NOT_RUN нет origin/main"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир без origin: бриф rc=$rc: $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир 1: PRECOND-строк не 3'
grep -Fxq "$O1_SYNC"  <<<"$out" || red 'нет origin → sync_main обязана NOT_RUN, не «ok»'
grep -Fxq "$O1_GATE"  <<<"$out" || red 'plan_gate не зелёная по рабочему дереву'
grep -Fxq "$O1_SLICE" <<<"$out" || red 'нет origin → plan_slice обязана NOT_RUN'

# ── мир 2: бюджет — packed-refs origin как FIFO (ls-remote зависает) ────────
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится'
rm -f "$W/origin.git/packed-refs"
mkfifo "$W/origin.git/packed-refs" || red 'fifo не строится'
O2_SYNC="PRECOND: sync_main rc=0 behind=0 ahead=0"
O2_GATE="PRECOND: plan_gate rc=0"
O2_SLICE="PRECOND: plan_slice rc=2 NOT_RUN бюджет 5с"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир бюджета: бриф rc=$rc: $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир 2: PRECOND-строк не 3'
grep -Fxq "$O2_SYNC"  <<<"$out" || red 'локальная sync_main не должна зависеть от origin-IO'
grep -Fxq "$O2_GATE"  <<<"$out" || red 'plan_gate не должна зависеть от origin-IO'
grep -Fxq "$O2_SLICE" <<<"$out" || red 'превышение бюджета не показано NOT_RUN (НЕ зелёное)'

# ── мир 3: проектные workflowPaths вне стража (996) ─────────────────────────
rm -f "$W/origin.git/packed-refs"
jq '.workflowPaths.registry = "reg"' "$R/harness.project.json" >"$W/profile"
mv "$W/profile" "$R/harness.project.json"
git -C "$R" add -A && git -C "$R" commit -qm 'workflowPaths вне стража'
O3_SYNC="PRECOND: sync_main rc=0 behind=0 ahead=1"
O3_GATE="PRECOND: plan_gate rc=2 NOT_RUN проектные workflowPaths вне стража"
O3_SLICE="PRECOND: plan_slice rc=2 NOT_RUN проектные workflowPaths вне стража"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир проектных путей: бриф rc=$rc: $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир 3: PRECOND-строк не 3'
grep -Fxq "$O3_SYNC"  <<<"$out" || red 'sync_main не зависит от workflowPaths'
grep -Fxq "$O3_GATE"  <<<"$out" || red 'plan_gate обязана NOT_RUN на проектных путях (страж 084 читает канон)'
grep -Fxq "$O3_SLICE" <<<"$out" || red 'plan_slice обязана NOT_RUN на проектных путях (срез 182 читает канон)'
exit 0
