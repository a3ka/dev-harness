#!/usr/bin/env bash
# Сверка ПЕРЕСЕЧЕНИЕ-строк контракта 165 с ЖИВЫМИ frozen-тегами (дисциплина «А», К-03/К-15).
#
# КОНВЕНЦИЯ (по замороженным прецедентам 186/190/195, единый читатель zones lib_zones.sh):
#   для каждого файла из ЗОНА-строк черновика (кроме собственного файла контракта, каталога
#   семьи fixtures/workshop_project/verdict_materializer_165/ и verdicts/) заявленные
#   ПЕРЕСЕЧЕНИЕ обязаны покрывать КАЖДУЮ живую замороженную зону с ТОЧНЫМ совпадением пути,
#   чей автор зоны ЧУЖОЙ для ЗОНА-строки черновика, плюс каждую зону СВОЕГО автора по
#   контракту, НЕ закрытому done. Чужие объявления сверх обязательных допустимы, если
#   ссылаются на реально существующие точные зоны. Каталогозоны верхнего уровня
#   (например `.omp/` поверх `.omp/config.yml`) пересечением не считаются — так судил
#   precision-gate 043 (побайтовое равенство путей) и так заморожены 166/186.
#
# Выход: rc 0 — инвариант держится; rc 1 — именованное расхождение; rc 2 — нечем проверять.
set -uo pipefail

usage='использование: zones_union_165.sh <корень-репозитория> <отн-путь-контракта>'
ROOT="${1:?$usage}"
CONTRACT="${2:?$usage}"
[ -d "$ROOT" ] || { printf 'NOT_IMPLEMENTED: корня нет: %s\n' "$ROOT" >&2; exit 2; }
[ -f "$ROOT/$CONTRACT" ] || { printf 'NOT_IMPLEMENTED: контракта нет: %s\n' "$ROOT/$CONTRACT" >&2; exit 2; }
[ -f "$ROOT/scripts/lib_zones.sh" ] || { printf 'NOT_IMPLEMENTED: lib_zones.sh нет в корне\n' >&2; exit 2; }

# shellcheck source=/dev/null
source "$ROOT/scripts/lib_zones.sh"
ZDIR="$(zones_load "$ROOT")" || exit $?
trap '__lib_zones_cleanup' EXIT

[ -s "$ZDIR/zones_scoped" ] || { printf 'NOT_IMPLEMENTED: zones_scoped пуст — живых заморозок нет, сверять нечем\n' >&2; exit 2; }

# done-контракты: тег done/contracts/<NNN>/* закрывает живость обязательств.
DONE_LIST="$ZDIR/done_contracts"
git -C "$ROOT" tag -l 'done/contracts/*' | sed 's|done/contracts/||;s|/.*||' | sort -u > "$DONE_LIST" \
  || { printf 'NOT_IMPLEMENTED: теги done не читаются\n' >&2; exit 2; }

is_done() { grep -qx "$1" "$DONE_LIST"; }

# ЗОНА-строки черновика: автор<TAB>путь.
ZFILE="$ZDIR/draft_zones"
printf '%s\n' "$(cat "$ROOT/$CONTRACT")" | awk '
    index($0, "ЗОНА ") == 1 {
      rest = substr($0, length("ЗОНА ") + 1)
      role_end = index(rest, ":")
      if (role_end == 0) next
      author = substr(rest, 1, role_end - 1)
      n = split(substr(rest, role_end + 1), paths, /[[:space:]]+/)
      for (i = 1; i <= n; i++) if (paths[i] != "") printf "%s\t%s\n", author, paths[i]
    }' > "$ZFILE"
[ -s "$ZFILE" ] || { printf 'NOT_RED: контракт не несёт ЗОНА-строк\n' >&2; exit 1; }

# ПЕРЕСЕЧЕНИЕ-строки черновика: файл<TAB>NNN.
XFILE="$ZDIR/draft_intersections"
printf '%s\n' "$(cat "$ROOT/$CONTRACT")" | awk '
    index($0, "ПЕРЕСЕЧЕНИЕ ") == 1 {
      rest = substr($0, length("ПЕРЕСЕЧЕНИЕ ") + 1)
      role_end = index(rest, ":")
      if (role_end == 0) next
      rest = substr(rest, role_end + 1)
      sub(/^[[:space:]]+/, "", rest)
      dash = index(rest, " — ")
      if (dash == 0) next
      file = substr(rest, 1, dash - 1)
      tail = substr(rest, dash + 3)
      n = split(tail, words, /[[:space:]]+/)
      for (i = 1; i <= n; i++)
        if (words[i] ~ /^[0-9]{3}$/) printf "%s\t%s\n", file, words[i]
    }' > "$XFILE"

FAMILY_DIR='fixtures/workshop_project/verdict_materializer_165/'
failures=0
checked=0
while IFS=$'\t' read -r author path; do
  case "$path" in
    "$CONTRACT") continue ;;                                   # собственный файл контракта
    "$FAMILY_DIR"|"$FAMILY_DIR"*) continue ;;                  # каталог семьи черновика
    verdicts/critic/|verdicts/adversary/|verdicts/review/) continue ;;  # пер-предметные исходы судов
    verdicts/critic/*|verdicts/adversary/*|verdicts/review/*) continue ;;
  esac
  checked=$((checked + 1))
  # Авторы черновика на этом пути.
  draft_authors="$(awk -F'\t' -v p="$path" '$2 == p {print $1}' "$ZFILE" | sort -u)"
  # Живые ТОЧНЫЕ зоны на этом пути: nnn<TAB>автор.
  live_exact="$(awk -F'\t' -v p="$path" '$2 == p {print $3 "\t" $1}' "$ZDIR/zones_scoped" | sort -u)"
  declared="$(awk -F'\t' -v p="$path" '$1 == p {print $2}' "$XFILE" | sort -u)"
  # Обязательные: чужой автор ИЛИ свой автор и контракт не закрыт done.
  required=""
  while IFS=$'\t' read -r nnn zauthor; do
    [ -n "$nnn" ] || continue
    alien=1
    printf '%s\n' "$draft_authors" | grep -qxF "$zauthor" && alien=0
    if [ "$alien" -eq 1 ] || ! is_done "$nnn"; then
      required="$required $nnn"
    fi
  done <<EOF2
$live_exact
EOF2
  req_sorted="$(printf '%s' "$required" | tr ' ' '\n' | grep -v '^$' | sort -u)"
  missing="$(comm -23 <(printf '%s\n' "$req_sorted") <(printf '%s\n' "$declared") | tr '\n' ' ')"
  live_nnns="$(printf '%s\n' "$live_exact" | cut -f1 | sort -u)"
  phantom="$(comm -13 <(printf '%s\n' "$live_nnns") <(printf '%s\n' "$declared" | grep -v '^$' | sort -u) | tr '\n' ' ')"
  if [ -n "${missing// }" ]; then
    printf 'NEOBYAVLENO: %s — обязательные по живым тегам: %s\n' "$path" "$missing" >&2
    failures=$((failures + 1))
  fi
  if [ -n "${phantom// }" ]; then
    printf 'FANTOM: %s — заявлено без живой точной зоны: %s\n' "$path" "$phantom" >&2
    failures=$((failures + 1))
  fi
done < "$ZFILE"

# Пустая выборка — красное: хоть один файл должен быть сверен.
[ "$checked" -gt 0 ] || { printf 'NOT_RED: ни один файл ЗОН не сверен\n' >&2; exit 1; }

if [ "$failures" -eq 0 ]; then
  printf 'ok: ПЕРЕСЕЧЕНИЕ покрывают обязательные живые зоны (%s файл(ов) сверено)\n' "$checked"
  exit 0
fi
exit 1
