#!/usr/bin/env bash
# Клетка И-16 «PRECOND брифа», часть 3 (контракт 095 v2 Б3; арбитраж
# 095-granica-v2, решение 4): истечение бюджета каждой из проб — честный
# NOT_RUN «бюджет <N>с», НЕ зелёное; задачный пак пробы предусловий НЕ
# запускает вовсе. Мир: локальный loose-ref origin/main заменён FIFO —
# ЧТЕНИЕ ref (сам источник пробы sync_main и стартовая rev-parse среза 182)
# висит; страж 084 ref-ов не читает и остаётся зелёным. Бюджет ограничивает
# ВЕСЬ путь пробы, включая подготовку ref: бриф завершается, а не висит.
# Обманы: s49 «тайм-аут среза выдан зелёным», s59 «тайм-аут sync выдан
# зелёным», s61 «задачный пак запускает пробы» → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: precond-budget: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }
red() { printf 'КРАСНО: precond-budget: %s\n' "$*" >&2; exit 1; }

W="$(_t95_world i16bud)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_plan_green "$R" || red 'план-зелёный мир не строится'
_t95_origin_bare "$W" "$R" || red 'bare-origin не строится'
_t95_trace "$W/trace.tsv" orchestrator glm-4.7 allowed
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed

# FIFO вместо локального loose-ref origin/main: чтение ref висит
mv "$R/.git/refs/remotes/origin/main" "$W/ref.bak"
mkfifo "$R/.git/refs/remotes/origin/main" || red 'fifo на ref не строится'

O_SYNC="PRECOND: sync_main rc=2 NOT_RUN бюджет 3с"
O_GATE="PRECOND: plan_gate rc=0"
O_SLICE="PRECOND: plan_slice rc=2 NOT_RUN бюджет 5с"
out="$(bash "$SUBJ" --repo "$R" --role orchestrator --kind brief --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
[ "$rc" -eq 0 ] || red "мир бюджета: бриф rc=$rc (весь путь пробы обязан быть под таймером, бриф не висит): $out"
[ "$(grep -c '^PRECOND: ' <<<"$out")" -eq 3 ] || red 'мир бюджета: PRECOND-строк не 3'
grep -Fxq "$O_SYNC"  <<<"$out" || red 'истечение бюджета sync_main обязано быть NOT_RUN бюджет 3с (НЕ зелёное)'
grep -Fxq "$O_GATE"  <<<"$out" || red 'plan_gate не зависит от чтения origin-ref (страж 084 их не читает)'
grep -Fxq "$O_SLICE" <<<"$out" || red 'истечение бюджета plan_slice обязано быть NOT_RUN бюджет 5с (НЕ зелёное)'

# задачный пак пробы предусловий не ЗАПУСКАЕТ: в мире висячего ref он
# завершается под timeout 2 (любая проба висела бы ≥3 с своего бюджета)
out2="$(timeout 2 bash "$SUBJ" --repo "$R" --role architect --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc2=$?
[ "$rc2" -eq 0 ] || red "task-пак rc=$rc2 в мире висячего ref: пробы предусловий исполняются и в task (запрещено): $out2"
if grep -Fq 'PRECOND: ' <<<"$out2"; then red 'задачный pak несёт PRECOND-строку'; fi

rm -f "$R/.git/refs/remotes/origin/main"
mv "$W/ref.bak" "$R/.git/refs/remotes/origin/main"
exit 0
