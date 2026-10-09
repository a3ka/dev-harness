#!/usr/bin/env bash
# Клетка И-6 «отдельный корректный режим архитектора/критика до заморозки»
# (контракт 095, состав п.5). Контракт НЕ заморожен: architect и critic
# собираются по черновику (origin=draft); исполнительские роли на
# незамороженном контракте — именованный отказ «контракт не заморожен»
# (зоны по памяти — Н-71 — не воспроизводятся механизмом).
# Обман (s6: implementer пускается по черновику) → клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: rezhim-do-zamorozki: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i6)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed
_t95_trace "$W/trace.tsv" critic glm-4.7 allowed
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed

for ro in architect critic; do
  out="$(bash "$SUBJ" --repo "$R" --role "$ro" --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || ! printf '%s\n' "$out" | grep -Fq 'ЗОНА implementer: scripts/toy.sh'; then
    printf 'КРАСНО: i6: %s не собрался по черновику до заморозки (rc=%s, вывод: %s)\n' "$ro" "$rc" "$out" >&2; exit 1
  fi
done

out="$(bash "$SUBJ" --repo "$R" --role implementer --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s\n' "$out" | grep -Fq 'ОТКАЗ: контракт не заморожен: 777'; then
  printf 'КРАСНО: i6: implementer пущен по незамороженному контракту (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ -z "$(printf '%s\n' "$out" | grep -v 'ОТКАЗ:')" ] || { printf 'КРАСНО: i6: отказ выдал частичный пак\n' >&2; exit 1; }
exit 0
