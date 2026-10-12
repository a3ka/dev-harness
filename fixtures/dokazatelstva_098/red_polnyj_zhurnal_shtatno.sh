#!/usr/bin/env bash
# Клетка Б-1 «полный применимый журнал штатными вызовами» (контракт 098, §Предмет
# п.1-3): для кандидата, ОТСУТСТВУЮЩЕГО в main, — object → prepare → CI на
# нецелевой ссылке cand/<oid> → check-писатель на КАЖДЫЙ обязательный ключ →
# verdict-писатель с вердикт-файлом круга → policy-писатель санкции перехода.
# Честный результат: в журнале принятой стороны полный применимый набор строк
# ЭТОГО object_id — каждый обязательной ключ (ci-a, ci-b политики base) покрыт
# СВОЕЙ строкой check с wfsha принятой версии и tree == M^{tree}; verdict accept
# событием судьи; policy — санкция перехода. Обман (s1/s2/s3/s5: писатель
# отключён / «на origin/main» вернулось) — клетка красна именованным отказом.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: polnyj-zhurnal: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world polnyj)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"

# вход: M ещё НЕ на main (доказательства ДО публикации — Р4-3б)
if git -C "$W/repo" merge-base --is-ancestor "$M" main; then
  printf 'КРАСНО: polnyj-zhurnal: вход неконформен — M уже на main\n' >&2; exit 1
fi

# оракул в память ДО вызова писателей (правило 8)
WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"; WFB="$(_d98_wfsha "$W/repo" "$B" ci-b)"
TRM="$(_d98_tree "$W/repo" "$M")"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"
J="$W/prinyato/registry/candidates.tsv"

_d98_dokazatelstva "$W" T-1 "$B" "$C" "$M" "$OID" \
  || { printf 'КРАСНО: polnyj-zhurnal: писатель отказал (строки не записаны)\n' >&2; exit 1; }

_d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$TRM" \
  || { printf 'КРАСНО: polnyj-zhurnal: строка check ci-a отсутствует/неверна (полнота Н-204)\n' >&2; exit 1; }
_d98_check_stroka "$J" "$OID" ci-b ok "$WFB" "$TRM" \
  || { printf 'КРАСНО: polnyj-zhurnal: строка check ci-b отсутствует/неверна (полнота Н-204)\n' >&2; exit 1; }
n="$(awk -F'\t' -v t=T-1 -v o="$OID" '$1=="verdict" && $2==t && $3==o && $4=="accept" && $5 ~ /^[0-9]+$/ && $5+0 > 0' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: polnyj-zhurnal: verdict accept событием судьи не записан (n=%s)\n' "$n" >&2; exit 1; }
n="$(awk -F'\t' -v o="$OID" -v a="$PVB" -v b="$PVC" '$1=="policy" && $2==o && $3==a && $4==b && $5=="accept" && $6 ~ /^[0-9]+$/ && $6+0 > 0' "$J" | wc -l)"
[ "$n" -eq 1 ] || { printf 'КРАСНО: polnyj-zhurnal: policy-строка санкции перехода не записана (n=%s)\n' "$n" >&2; exit 1; }
n="$(wc -l <"$J")"
[ "$n" -eq 4 ] || { printf 'КРАСНО: polnyj-zhurnal: в журнале %s строк, ожидалось ровно 4 (полный применимый набор без лишних)\n' "$n" >&2; exit 1; }

# M по-прежнему не на main: доказательства не опубликовали ничего
git -C "$W/repo" merge-base --is-ancestor "$M" main \
  && { printf 'КРАСНО: polnyj-zhurnal: записи доказательства сдвинули main\n' >&2; exit 1; }
exit 0
