#!/usr/bin/env bash
# Клетка И-4б-дерево «доказательство обязательной проверки несёт то, что
# реально исполнялось» (контракт 094, Б3-остаток арбитража 094, путь (а)):
# контрмодель «обязательная проверка исполнена на дереве C (зелена), на
# дереве M красна/не исполнялась; строка check записана под object_id M с
# ДОВЕРЕННЫМ wfsha». Мир: base ушла вперёд ПОСЛЕ ветвления кандидата — дерево
# объединения M ОТЛИЧАЕТСЯ от дерева кандидата C (world-готовность), строки
# check несут tree sha C. Честная дверь сверяет поле дерева литерально с
# MERGE^{tree}: «проверка не того дерева: ci-a», main не тронут. Положительный
# контроль: строки с деревом M публикуют (rc 0 PUBLISHED). Обман (s15: сверка
# дерева снята) публикует непроверенное объединение → клетка красна.
# Лгущий поставщик (записал дерево M, не исполняя) — доверенная сторона:
# НЕ ЗАЩИЩАЕТ (Модель угроз контракта).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t94_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: proverka-ne-togo-dereva: предмет отсутствует: scripts/accept_publish.sh\n' >&2; exit 1; }

W="$(_t94_world i4d)" || exit 2
trap '_t94_cleanup "$W"' EXIT
R="$W/repo"; J="$W/journal.tsv"
# base уходит вперёд ПОСЛЕ ветвления кандидата: merge-дерево ≠ дерево кандидата
printf 'base-own\n' | tee "$R/base-own.txt" >/dev/null
git -C "$R" add -A && git -C "$R" commit -qm 'base advances'
BASE="$(git -C "$R" rev-parse main)"
CAND="$(git -C "$R" rev-parse cand)"
M="$(bash "$SUBJ" prepare --repo "$R" --task T-1 --base "$BASE" --candidate "$CAND")" || exit 1
O="$(bash "$SUBJ" object --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M")" || exit 1
MT="$(_t94_tree "$R" "$M")"; CT="$(_t94_tree "$R" "$CAND")"
[ "$MT" != "$CT" ] || { printf 'КРАСНО: i4d: мир сломан — дерево merge совпало с деревом кандидата\n' >&2; exit 1; }
_t94_verdict "$J" 1 T-1 "$O" accept
# контрмодель Б3: прогон исполнен на ДЕРЕВЕ кандидата C (там зелена), строки
# записаны под object_id M с ДОВЕРЕННОЙ wfsha — «проверили C, записали для M»
_t94_check "$J" "$O" ci-a ok 1 "$(_t94_wfsha "$R" "$BASE" ci-a)" "$CT"
_t94_check "$J" "$O" ci-b ok 2 "$(_t94_wfsha "$R" "$BASE" ci-b)" "$CT"
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'проверка не того дерева: ci-a'; then
  printf 'КРАСНО: i4d: приписывание прогона другого дерева объекту M не отказано (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$BASE" ] || { printf 'КРАСНО: i4d: отказ сдвинул main\n' >&2; exit 1; }
# положительный контроль: строки с деревом ИМЕННО M — публикация проходит
_t94_check "$J" "$O" ci-a ok 3 "$(_t94_wfsha "$R" "$BASE" ci-a)" "$MT"
_t94_check "$J" "$O" ci-b ok 4 "$(_t94_wfsha "$R" "$BASE" ci-b)" "$MT"
out="$(bash "$SUBJ" publish --repo "$R" --task T-1 --target main --base "$BASE" --candidate "$CAND" --merge "$M" --candidate-ref cand --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'PUBLISHED target=main'; then
  printf 'КРАСНО: i4d: мир сломан — прогон дерева M не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$R" rev-parse main)" = "$M" ] || { printf 'КРАСНО: i4d: main не на merge\n' >&2; exit 1; }
exit 0
