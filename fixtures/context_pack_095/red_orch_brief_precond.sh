#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа — фактические rc трёх проб» (контракт 095 v2 Б3,
# слово владельца 2026-11-17; арбитраж 095-granica-v2, решение 2). --kind brief
# несёт секцию === PRECOND === сразу после HEALTH: замкнутый перечень РОВНО
# трёх строк в фиксированном порядке (sync_main, plan_gate, plan_slice).
# Мир 1 (честный): все три строки зелёны дословно; задачный пак секции не несёт.
# Мир 2 (красное РАБОЧЕЕ дерево: отставание HEAD от origin/main + сломанный
# ROADMAP): sync_main несёт behind=1, plan_gate — ФАКТИЧЕСКИЙ rc стража 084 и
# первую строку ЕГО stderr (оракул клетки запускает стража сам ДО вызова
# субъекта), plan_slice остаётся зелёной — её источник ОПУБЛИКОВАННЫЙ
# origin/main, не рабочее дерево; бриф НЕ отказывает.
# Мир 3 (красный ОПУБЛИКОВАННЫЙ срез: ROADMAP сломан на origin/main, рабочее
# дерево зелёное): plan_slice — фактический rc=1 и дословная первая строка
# stderr среза 182 (PLAN_ROADMAP_RASHOZHDENIE), plan_gate зелёная по рабочему
# дереву; красный срез НЕ обрывает бриф.
# Обманы: s50 «всегда ok» (красный мир выдан зелёным), s51 «пропуск хвоста»,
# s52 «rc из неверного источника» (rc plan_gate не из стража 084) → клетка
# красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond: %s\n' "$*" >&2; exit 1; }
ROOT="${CP095_ROOT:-$(cd "$HERE/../.." && pwd)}"

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
# порядок строк фиксирован; секция — СЛЕДУЮЩИЙ заголовок после HEALTH (мир входа)
l_sync="$(grep -n '^PRECOND: sync_main'  <<<"$out" | cut -d: -f1)"
l_gate="$(grep -n '^PRECOND: plan_gate'  <<<"$out" | cut -d: -f1)"
l_slice="$(grep -n '^PRECOND: plan_slice' <<<"$out" | cut -d: -f1)"
l_health="$(grep -n '^=== HEALTH ===$' <<<"$out" | cut -d: -f1)"
l_precond="$(grep -n '^=== PRECOND ===$' <<<"$out" | cut -d: -f1)"
[ -n "$l_precond" ] || red 'нет секции PRECOND'
[ "$l_health" -lt "$l_precond" ] || red 'PRECOND стоит раньше HEALTH'
next_hdr="$(printf '%s\n' "$out" | awk -v h="$l_health" 'NR>h && /^=== /{print NR; exit}')"
[ "$next_hdr" = "$l_precond" ] || red 'секция PRECOND не непосредственно после HEALTH (чужая секция между ними)'
[ "$l_sync" -lt "$l_gate" ] && [ "$l_gate" -lt "$l_slice" ] \
  || red 'порядок PRECOND-строк не sync_main→plan_gate→plan_slice'

# задачный пак тем же субъектом секции не несёт
out2="$(bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
[ "$rc2" -eq 0 ] || red "task-пак rc=$rc2: $out2"
if grep -Fq '=== PRECOND ===' <<<"$out2"; then red 'задачный pak несёт PRECOND'; fi
if grep -Fq 'PRECOND: ' <<<"$out2"; then red 'задачный pak несёт PRECOND-строку'; fi

# ── мир 2: красное РАБОЧЕЕ дерево ────────────────────────────────────────────
# коммит на origin мимо HEAD (behind=1) + сломанный ROADMAP рабочего дерева;
# оракул запускает стража 084 сам ДО субъекта: rc и первая строка stderr канон
git -C "$R" -c user.name=f -c user.email=f@local checkout -q -b ahead-tmp
git -C "$R" -c user.name=f -c user.email=f@local commit -q --allow-empty -m ahead
git -C "$R" push -q origin ahead-tmp:main
git -C "$R" checkout -q main
git -C "$R" branch -q -D ahead-tmp
git -C "$R" fetch -q origin
head -n -1 "$R/ROADMAP.md" >"$W/rm.short" && cp "$W/rm.short" "$R/ROADMAP.md"
g_rc=0; g_err=""
g_err="$(bash "$ROOT/scripts/check_plan.sh" --root "$R" 2>&1 >/dev/null)" || g_rc=$?
[ "$g_rc" -eq 1 ] || red "оракул стража 084 на сломанном плане: rc=$g_rc (мир построен неверно)"
g_tail="$(_t95_tail120 "$g_err")"
sha2="$(git -C "$R" rev-parse origin/main)"
O2_SYNC="PRECOND: sync_main rc=0 behind=1 ahead=0"
O2_GATE="PRECOND: plan_gate rc=1 $g_tail"
O2_SLICE="PRECOND: plan_slice rc=0 origin/main=${sha2:0:12}"
out3="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc3=$?
[ "$rc3" -eq 0 ] || red "красный мир роняет бриф (rc=$rc3): бриф обязан нести факты, не отказ"
[ "$(grep -c '^PRECOND: ' <<<"$out3")" -eq 3 ] || red 'красный мир: PRECOND-строк не 3'
grep -Fxq "$O2_SYNC" <<<"$out3" || red 'отставание HEAD от origin/main скрыто (behind=1)'
grep -Fxq "$O2_GATE" <<<"$out3" || red 'plan_gate несёт не фактический rc/хвост стража 084 (первая строка stderr дословно)'
grep -Fxq "$O2_SLICE" <<<"$out3" || red 'plan_slice в красном мире не зелёная (источник origin, не рабочее дерево)'

# ── мир 3: красный ОПУБЛИКОВАННЫЙ срез, рабочее дерево зелёное ──────────────
# сначала выравниваемся с опубликованным ahead-коммитом, затем сломанный
# ROADMAP коммитится и публикуется; рабочее дерево восстанавливается локально;
# оракул запускает срез 182 сам ДО субъекта
git -C "$R" add -A
git -C "$R" -c user.name=f -c user.email=f@local commit -qm 'сломанный ROADMAP'
git -C "$R" pull --rebase -q origin main || red 'мир 3: rebase на опубликованный ahead не строится'
git -C "$R" push -q origin main || red 'мир 3: публикация сломанного ROADMAP не строится'
printf '# ROADMAP toy\n\n<!-- BEGIN GENERATED PLAN -->\n<!-- END GENERATED PLAN -->\n' >"$R/ROADMAP.md"
bash "$ROOT/scripts/gen_plan.sh" --write --root "$R" >/dev/null 2>&1
git -C "$R" add -A
git -C "$R" -c user.name=f -c user.email=f@local commit -qm 'рабочее дерево восстановлено'
s_rc=0; s_err=""
s_err="$(bash "$ROOT/scripts/orch_plan_slice.sh" --repo "$R" 2>&1 >/dev/null)" || s_rc=$?
[ "$s_rc" -eq 1 ] || red "оракул среза 182 на опубликованном расхождении: rc=$s_rc (мир построен неверно)"
s_tail="$(_t95_tail120 "$s_err")"
ab="$(git -C "$R" rev-list --left-right --count origin/main...HEAD)"
O3_SYNC="PRECOND: sync_main rc=0 behind=${ab%%$'\t'*} ahead=${ab#*$'\t'}"
O3_GATE="PRECOND: plan_gate rc=0"
O3_SLICE="PRECOND: plan_slice rc=1 $s_tail"
out4="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc4=$?
[ "$rc4" -eq 0 ] || red "красный срез роняет бриф (rc=$rc4): бриф обязан нести факты, не отказ"
[ "$(grep -c '^PRECOND: ' <<<"$out4")" -eq 3 ] || red 'мир 3: PRECOND-строк не 3'
grep -Fxq "$O3_SYNC" <<<"$out4" || red 'sync_main в мире 3 не дословна (behind/ahead из rev-list)'
grep -Fxq "$O3_GATE" <<<"$out4" || red 'plan_gate в мире 3 не зелёная (рабочее дерево зелёное)'
grep -Fxq "$O3_SLICE" <<<"$out4" || red 'plan_slice прячет опубликованное расхождение (rc=1 + первая строка stderr среза дословно)'
exit 0
