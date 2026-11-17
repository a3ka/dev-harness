#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа — предусловия мира входа строками с rc» (контракт
# 095 v2 Б3, слово владельца 2026-11-17). --kind brief несёт секцию
# === PRECOND === сразу после HEALTH: замкнутый перечень РОВНО трёх строк в
# фиксированном порядке (sync_main, plan_gate, plan_slice); rc строки —
# фактический rc пробы, хвост — измеренные факты (behind=/ahead=;
# origin/main=<12hex> из среза 182; rc≠0 — первая строка stderr пробы).
# Честный мир: все три строки зелёны. Красный мир (отставание HEAD от
# origin/main; сломанный план рабочего дерева): строки несут красные
# rc/факты, бриф НЕ отказывает и НЕ скрывает; plan_slice остаётся зелёной —
# её источник ОПУБЛИКОВАННЫЙ origin/main, не рабочее дерево. Задачный пак
# (--kind task) секции не несёт.
# Обманы: s50 «всегда ok» (красный мир выдан зелёным), s51 «пропуск строки»
# (строк < 3), s52 «rc из неверного источника» (rc plan_gate из rev-parse,
# не из стража 084) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond: %s\n' "$*" >&2; exit 1; }

W="$(_t95_world i16)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится (gen_plan/стражи 084)'
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# оракул ДО вызова (правило 8): честный мир — все три пробы зелёны
sha="$(git -C "$R" rev-parse origin/main)"
O_SYNC="PRECOND: sync_main rc=0 behind=0 ahead=0"
O_GATE="PRECOND: plan_gate rc=0"
O_SLICE="PRECOND: plan_slice rc=0 origin/main=${sha:0:12}"

out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "честный бриф rc=$rc: $out"
n="$(grep -c '^PRECOND: ' <<<"$out")"
[ "$n" -eq 3 ] || red "PRECOND-строк $n, ожидалось ровно 3 (замкнутый перечень)"
grep -Fxq "$O_SYNC"  <<<"$out" || red 'sync_main не зелёная дословно (behind/ahead из rev-list)'
grep -Fxq "$O_GATE"  <<<"$out" || red 'plan_gate не зелёная дословно (rc стража 084)'
grep -Fxq "$O_SLICE" <<<"$out" || red 'plan_slice не зелёная дословно (origin/main из среза 182)'
# порядок строк фиксирован; секция — сразу после HEALTH (мир входа, как HEALTH)
l_sync="$(grep -n '^PRECOND: sync_main'  <<<"$out" | cut -d: -f1)"
l_gate="$(grep -n '^PRECOND: plan_gate'  <<<"$out" | cut -d: -f1)"
l_slice="$(grep -n '^PRECOND: plan_slice' <<<"$out" | cut -d: -f1)"
l_health="$(grep -n '^=== HEALTH ===$' <<<"$out" | cut -d: -f1)"
l_precond="$(grep -n '^=== PRECOND ===$' <<<"$out" | cut -d: -f1)"
[ -n "$l_precond" ] || red 'нет секции PRECOND'
[ "$l_health" -lt "$l_precond" ] || red 'PRECOND стоит раньше HEALTH'
[ "$l_sync" -lt "$l_gate" ] && [ "$l_gate" -lt "$l_slice" ] \
  || red 'порядок PRECOND-строк не sync_main→plan_gate→plan_slice'

# задачный пак тем же субъектом секции не несёт
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
[ "$rc2" -eq 0 ] || red "task-пак rc=$rc2: $out2"
if grep -Fq '=== PRECOND ===' <<<"$out2"; then red 'задачный pak несёт PRECOND'; fi

# ── красный мир: коммит на origin мимо HEAD + сломанный ROADMAP рабочего дерева ──
git -C "$R" -c user.name=f -c user.email=f@local checkout -q -b ahead-tmp
git -C "$R" -c user.name=f -c user.email=f@local commit -q --allow-empty -m ahead
git -C "$R" push -q origin ahead-tmp:main
git -C "$R" checkout -q main
git -C "$R" branch -q -D ahead-tmp
git -C "$R" fetch -q origin
sed -i '$d' "$R/ROADMAP.md"
sha2="$(git -C "$R" rev-parse origin/main)"
O2_SYNC="PRECOND: sync_main rc=0 behind=1 ahead=0"
O2_SLICE="PRECOND: plan_slice rc=0 origin/main=${sha2:0:12}"
out3="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc3=$?
[ "$rc3" -eq 0 ] || red "красный мир роняет бриф (rc=$rc3): бриф обязан нести факты, не отказ"
[ "$(grep -c '^PRECOND: ' <<<"$out3")" -eq 3 ] || red 'красный мир: PRECOND-строк не 3'
grep -Fxq "$O2_SYNC" <<<"$out3" || red 'отставание HEAD от origin/main скрыто (behind=1)'
grep -Eq '^PRECOND: plan_gate rc=1 .+' <<<"$out3" || red 'сломанный план не показан (rc=1 с причиной)'
grep -Fxq "$O2_SLICE" <<<"$out3" || red 'plan_slice в красном мире не зелёная (источник origin, не рабочее дерево)'
exit 0
