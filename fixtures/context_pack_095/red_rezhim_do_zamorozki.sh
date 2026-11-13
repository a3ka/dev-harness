#!/usr/bin/env bash
# Публичная пара: architect/critic/arbiter по draft; implementer и
# implementer-glm до freeze отказаны, после freeze — только frozen-зоны.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_toy.sh"
SUBJ="$(_t95_subject)"
[ -f "$SUBJ" ] || { printf 'КРАСНО: rezhim-do-zamorozki: предмет отсутствует: scripts/make_task.sh\n' >&2; exit 1; }

W="$(_t95_world i6)" || exit 2
trap '_t95_cleanup "$W"' EXIT
R="$W/repo"
_t95_trace "$W/trace.tsv" architect glm-4.7 allowed
_t95_trace "$W/trace.tsv" critic qwen-3.5 allowed
_t95_trace "$W/trace.tsv" implementer glm-4.7 allowed
_t95_trace "$W/trace.tsv" implementer-glm zai/glm-5.3 allowed
_t95_trace "$W/trace.tsv" arbiter qwen-3.5 allowed

for ro in architect critic arbiter; do
  out="$(bash "$SUBJ" --repo "$R" --role "$ro" --contract 777 --model-trace "$W/trace.tsv" 2>&1)"; rc=$?
  if [ "$rc" -ne 0 ] || ! grep -Fxq 'ЗОНА implementer: scripts/toy.sh' <<<"$out"; then
    printf 'КРАСНО: i6: %s не собрался по черновику до заморозки (rc=%s, вывод: %s)\n' "$ro" "$rc" "$out" >&2; exit 1
  fi
  grep -Fxq $'context\tcontracts/777-toy.md\tmandatory\tdraft' <<<"$out" || {
    printf 'КРАСНО: i6: %s без draft-происхождения\n' "$ro" >&2; exit 1; }
done

for ro in implementer implementer-glm; do
  out="$(bash "$SUBJ" --repo "$R" --role "$ro" --contract 777 --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
  if [ "$rc" -ne 1 ] || [ -n "$out" ] || ! grep -Fxq 'ОТКАЗ: контракт не заморожен: 777' "$W/err"; then
    printf 'КРАСНО: i6: %s до freeze: rc=%s, stdout=%s, stderr=%s\n' "$ro" "$rc" "$out" "$(cat "$W/err")" >&2; exit 1
  fi
done
_t95_freeze "$R" 'scripts/frozen.sh' >/dev/null
printf '\nЗОНА implementer: scripts/draft-only.sh\n' >>"$R/contracts/777-toy.md"
for ro in implementer implementer-glm; do
  out="$(bash "$SUBJ" --repo "$R" --role "$ro" --contract 777 --model-trace "$W/trace.tsv" 2>"$W/err")"; rc=$?
  if [ "$rc" -ne 0 ] || ! grep -Fxq 'ЗОНА implementer: scripts/frozen.sh' <<<"$out"; then
    printf 'КРАСНО: i6: %s после freeze без frozen-зоны: rc=%s\n' "$ro" "$rc" >&2; exit 1
  fi
  if grep -Fq 'scripts/draft-only.sh' <<<"$out"; then printf 'КРАСНО: i6: draft-зона после freeze\n' >&2; exit 1; fi
  grep -Fxq $'zones\tcontracts/777-toy.md\tmandatory\tfrozen' <<<"$out" || {
    printf 'КРАСНО: i6: %s без frozen-происхождения\n' "$ro" >&2; exit 1; }
done
exit 0
