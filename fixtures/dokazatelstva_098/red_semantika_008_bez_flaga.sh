#!/usr/bin/env bash
# Клетка Б-7 «семантика 008 без флага» (контракт 098, приёмка 7 — поведенческая
# проба вместо прозы, совет критика :31): judge_gate <sha> БЕЗ
# --verdict-row/--policy-row — гейт CI-сигнала семантики 008: на зелёном base
# rc 0 с «OK», на неподпушенном M — именованный отказ 087 «не на origin/main»;
# ЖУРНАЛ байт-в-байт неизменен до и после обоих вызовов (отсутствие записи без
# флага). Парные стороны: с флагом --verdict-row строка пишется (положительная)
# и нераспознанное событие отвергается именованно (негативная). Обман (s7:
# запись журнала просачивается в бесфлаговый режим) — клетка красна.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: semantika-008: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world semantika008)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
J="$W/prinyato/registry/candidates.tsv"
G="$W/prinyato/scripts/judge_gate.sh"
_d98_ci "$W" "$B" ci-a:success ci-b:success   # зелёный CI base для 008-гейта

# (в) писательская сторона: с флагом строка пишется событием судьи
printf 'accept\n' >"$W/verdikt.md"
out="$( _d98_zov "$W" "$G" "$M" --verdict-row T-1 "$OID" "$W/verdikt.md" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! awk -F'\t' -v t=T-1 -v o="$OID" \
    '$1=="verdict" && $2==t && $3==o && $4=="accept"' "$J" | grep -q .; then
  printf 'КРАСНО: semantika-008: писатель не пишет: judge_gate --verdict-row (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
# негативная пара: нераспознанное событие — именованный отказ, строки нет
printf 'musor\n' | tee "$W/verdikt-bad.md" >/dev/null
h0="$(sha256sum <"$J" | cut -d' ' -f1)"
out="$( _d98_zov "$W" "$G" "$M" --verdict-row T-1 "$OID" "$W/verdikt-bad.md" 2>&1)"; rc=$?
if [ "$rc" -ne 1 ] || ! printf '%s' "$out" | grep -Fq 'событие решения не распознано: musor'; then
  printf 'КРАСНО: semantika-008: мусорное событие принято (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi

# (а) 008 без флага: зелёный base → rc 0 «OK», журнал НЕ изменён
h1="$(sha256sum <"$J" | cut -d' ' -f1)"
out="$( _d98_zov "$W" "$G" "$B" 2>&1)"; rc=$?
if [ "$rc" -ne 0 ] || ! printf '%s' "$out" | grep -Fq 'OK'; then
  printf 'КРАСНО: semantika-008: бесфлаговый гейт не зелёный на зелёном base (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
h2="$(sha256sum <"$J" | cut -d' ' -f1)"
[ "$h1" = "$h2" ] \
  || { printf 'КРАСНО: semantika-008: бесфлаговый вызов ЗАПИСАЛ журнал (008 ничего не пишет)\n' >&2; exit 1; }

# (б) 008 без флага: неподпушенный M → именованный отказ 087, журнал не изменён
out="$( _d98_zov "$W" "$G" "$M" 2>&1)"; rc=$?
if [ "$rc" -eq 0 ] || ! printf '%s' "$out" | grep -Fq 'не на origin/main'; then
  printf 'КРАСНО: semantika-008: бесфлаговый гейт не судит неподпушенный sha (rc=%s, вывод: %s)\n' "$rc" "$out" >&2; exit 1
fi
h3="$(sha256sum <"$J" | cut -d' ' -f1)"
[ "$h2" = "$h3" ] \
  || { printf 'КРАСНО: semantika-008: бесфлаговый отказ ЗАПИСАЛ журнал (008 ничего не пишет)\n' >&2; exit 1; }
exit 0
