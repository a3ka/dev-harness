#!/usr/bin/env bash
# Клетка «журнал создаётся писателями» (контракт 098 §Зоны, пересечение
# registry/candidates.tsv: «журнал создаётся писателями, append-only, вне
# проверяемой ветки»; ревьюер круга 1 Рв1-1: батарея создавала журнал ДО
# любого вызова писателя — _mir.sh _d98_podgotovka — и сценарий «файла ещё нет»
# не предъявлялся). Принятая сторона — живой случай: каталог registry/ есть
# (трекаемые реестры), файла registry/candidates.tsv НЕТ. Три писателя
# (check-row, verdict-row, policy-row) вызываются КАЖДЫЙ на отсутствующем
# журнале (файл снимается перед каждым входом); честный писатель — rc 0, файл
# создан, в нём РОВНО одна строка — его собственная. Каждый вход красен СВОИМ
# предъявлением: стадии не прерывают друг друга, итог — rc 1, если красна хоть
# одна. Обман (s20/s21: «журнал: нет файла» вместо создания — живой код
# scripts/judge_gate.sh:84,100 и scripts/check_ci_gate.sh:90 на d46cf8b5) —
# клетка красна именованным отказом на стадии этого писателя.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$HERE/_mir.sh"
miss="$(_d98_missing)"; [ -z "$miss" ] || { printf 'КРАСНО: zhurnal-sozdaetsja: предмет отсутствует: %s\n' "$miss" >&2; exit 1; }

W="$(_d98_world sozdaetsja)" || exit 2
trap '_d98_cleanup "$W"' EXIT
pc="$(_d98_podgotovka "$W" T-1)" || exit 2
read -r B C M OID <<<"$pc"
P="$W/prinyato"; J="$P/registry/candidates.tsv"

# оракулы в память ДО вызова писателей (правило 8)
WFA="$(_d98_wfsha "$W/repo" "$B" ci-a)"; TRM="$(_d98_tree "$W/repo" "$M")"
PVB="$(_d98_pv "$W/repo" "$B")"; PVC="$(_d98_pv "$W/repo" "$C")"
printf 'accept\n' >"$W/verdikt-$OID.md"
printf 'accept\n' >"$W/sankcia-$OID.md"

# bez_zhurnala — вход конформен: каталог registry/ есть, файла журнала нет
bez_zhurnala() {
  rm -f "$J" || return 1
  [ -d "$P/registry" ] && [ ! -e "$J" ]
}
# sozdan — журнал создан писателем обычным файлом ровно с одной строкой
sozdan() {
  local n
  [ -f "$J" ] || return 1
  n="$(wc -l <"$J")"; [ "$n" -eq 1 ]
}

red=0

# 1. check-писатель
bez_zhurnala || { printf 'КРАСНО: zhurnal-sozdaetsja: вход неконформен — журнал не снимается\n' >&2; exit 2; }
if _d98_zov "$W" "$P/scripts/check_ci_gate.sh" "$P" "$M" --check-row "$OID" ci-a; then
  if sozdan && _d98_check_stroka "$J" "$OID" ci-a ok "$WFA" "$TRM"; then :; else
    printf 'КРАСНО: zhurnal-sozdaetsja: check-row rc 0, но журнал не создан / не ровно одна строка check ci-a\n' >&2; red=1
  fi
else
  printf 'КРАСНО: zhurnal-sozdaetsja: check-row отказал на отсутствующем журнале (журнал создаётся писателями)\n' >&2; red=1
fi

# 2. verdict-писатель
bez_zhurnala || { printf 'КРАСНО: zhurnal-sozdaetsja: вход неконформен — журнал не снимается\n' >&2; exit 2; }
if _d98_zov "$W" "$P/scripts/judge_gate.sh" "$M" --verdict-row T-1 "$OID" "$W/verdikt-$OID.md"; then
  n=0
  sozdan && n="$(awk -F'\t' -v t=T-1 -v o="$OID" '$1=="verdict" && $2==t && $3==o && $4=="accept" && $5 ~ /^[0-9]+$/ && $5+0 > 0' "$J" | wc -l)"
  [ "$n" -eq 1 ] || { printf 'КРАСНО: zhurnal-sozdaetsja: verdict-row rc 0, но журнал не создан / не ровно одна строка verdict accept (n=%s)\n' "$n" >&2; red=1; }
else
  printf 'КРАСНО: zhurnal-sozdaetsja: verdict-row отказал на отсутствующем журнале (журнал создаётся писателями)\n' >&2; red=1
fi

# 3. policy-писатель
bez_zhurnala || { printf 'КРАСНО: zhurnal-sozdaetsja: вход неконформен — журнал не снимается\n' >&2; exit 2; }
if _d98_zov "$W" "$P/scripts/judge_gate.sh" "$M" --policy-row "$OID" "$PVB" "$PVC" "$W/sankcia-$OID.md"; then
  n=0
  sozdan && n="$(awk -F'\t' -v o="$OID" -v a="$PVB" -v b="$PVC" '$1=="policy" && $2==o && $3==a && $4==b && $5=="accept" && $6 ~ /^[0-9]+$/ && $6+0 > 0' "$J" | wc -l)"
  [ "$n" -eq 1 ] || { printf 'КРАСНО: zhurnal-sozdaetsja: policy-row rc 0, но журнал не создан / не ровно одна строка policy (n=%s)\n' "$n" >&2; red=1; }
else
  printf 'КРАСНО: zhurnal-sozdaetsja: policy-row отказал на отсутствующем журнале (журнал создаётся писателями)\n' >&2; red=1
fi

# писатели ничего не опубликовали: M по-прежнему не на main
git -C "$W/repo" merge-base --is-ancestor "$M" main \
  && { printf 'КРАСНО: zhurnal-sozdaetsja: записи доказательства сдвинули main\n' >&2; red=1; }
exit "$red"
