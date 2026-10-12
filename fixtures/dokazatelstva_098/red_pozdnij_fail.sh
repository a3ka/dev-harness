#!/usr/bin/env bash
# Клетка Б-3(б) «поздний fail» (контракт 098, §Инварианты Б-3): accept записан
# событием судьи, затем БОЛЕЕ НОВОЕ событие — FAIL (вердикт-файл круга) —
# verdict-писатель обязан записать отказ следующим seq; publish отказывает
# «более новый отказ по предмету: T-1», target неизменен. Обман (s6: зелёный
# CI превращается в accept — писатель игнорирует событие файла) публикует →
# клетка красна. Положительный контроль: ещё более новый accept — публикация
# зелёная (последний применимый исход).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: pozdnij-fail: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world pozdnij)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: pozdnij-fail: писатель отказал (журнал неполон)\n' >&2; exit 1; }

# поздний fail — СОБЫТИЕ из вердикт-файла (не из CI: CI мира зелёный)
printf 'FAIL\n' >"$W/verdikt-fail.md"
out="$( _d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt-fail.md" 2>&1)"; rc=$?
n="$(awk -F'\t' -v t=T-1 -v o="$OID" '$1=="verdict" && $2==t && $3==o && $4=="fail"' "$J" | wc -l)"
if [ "$rc" -ne 0 ] || [ "$n" -ne 1 ]; then
  printf 'КРАСНО: pozdnij-fail: событие FAIL не записано строкой fail (rc=%s, строк=%s, вывод: %s)\n' "$rc" "$n" "$out" >&2; exit 1
fi

out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'более новый отказ по предмету: T-1'; then
  printf 'КРАСНО: pozdnij-fail: поздний fail не остановил публикацию (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
[ "$(git -C "$W/repo" rev-parse main)" = "$B" ] \
  || { printf 'КРАСНО: pozdnij-fail: отказ сдвинул main\n' >&2; exit 1; }
grep -Fq 'published' "$J" \
  && { printf 'КРАСНО: pozdnij-fail: отказ записал published\n' >&2; exit 1; }

# положительный контроль: ещё более новый accept — последний применимый исход
printf 'accept\n' >"$W/verdikt-ok.md"
_d98_zov "$W" "$W/prinyato/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt-ok.md" \
  || { printf 'КРАСНО: pozdnij-fail: verdict-писатель отказал на accept\n' >&2; exit 1; }
out="$( _d98_zov "$W" "$W/prinyato/scripts/accept_publish.sh" publish --repo "$W/repo" \
  --task T-1 --target main --base "$B" --candidate "$C" --merge "$M" \
  --candidate-ref kandidat --journal "$J" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq "PUBLISHED target=main merge=$M"; then
  printf 'КРАСНО: pozdnij-fail: новый accept не публикует (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
exit 0
