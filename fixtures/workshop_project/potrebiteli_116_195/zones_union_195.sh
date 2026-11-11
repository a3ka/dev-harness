#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# Канон пересчёта union-держателей для раздела «Зоны» контракта 195 (Б-2 круга 1:
# счётные утверждения противоречили zones_load). Единый читатель —
# scripts/lib_zones.sh (016), та же мера, что у precision-гейта 043.
#
# Три меры на каждый путь раздела:
#   всего-держателей  — union высших заморозок по zones_scoped (точный файл или
#                       каталог-зона с завершающим `/`);
#   чужие-авторы      — держатели ТОЧНОГО пути под автором, ОТЛИЧНЫМ от автора
#                       ЗОНА-строки 195 на этом пути (механическое требование
#                       ПЕРЕСЕЧЕНИЕ-строк у precision-гейта 043, точное
#                       совпадение пути, не префикс);
#   живые             — держатели без тега done/contracts/<NNN>/1.
# ПЕРЕСЕЧЕНИЕ-строки раздела «Зоны» = чужие-авторы ∪ живые.
#
# Использование: bash zones_union_195.sh <корень-репо>
# rc 0 — мера снята; rc 1 — zones_load отказал (мера не снята — это красное).
#
# Живой срез ПЛЫВЁТ с тегами: новая заморозка расширяет, новый done сужает.
# Контрольная точка списков в тексте контракта — фикс-коммит 195
# (tag-state: frozen/contracts/* 311, done/contracts/* 147).
# ─────────────────────────────────────────────────────────────────────────────
set -uo pipefail
REPO="${1:?ispolzovanie: $0 <koren-repo>}"
# shellcheck disable=SC1091
. "$REPO/scripts/lib_zones.sh"
Z="$(zones_load "$REPO")" || { printf 'zones_load отказ: rc %s\n' "$?" >&2; exit 1; }
for spec in 'registry/ci-steps.tsv orchestrator' 'registry/ci-zamery.tsv orchestrator' '.github/workflows/ci.yml orchestrator' 'scripts/check_consumers.sh implementer'; do
  p="${spec% *}"; a="${spec#* }"
  holders="$(awk -F'\t' -v p="$p" '
    { if ($2 == p || (substr($2, length($2)) == "/" && index(p, $2) == 1)) print $3 }
  ' "$Z/zones_scoped" | sort -u)"
  total="$(printf '%s\n' "$holders" | grep -c . || true)"
  cross="$(awk -F'\t' -v p="$p" -v a="$a" '$2 == p && $3 != "195" && $1 != a { print $3 }' "$Z/zones_scoped" | sort -u)"
  ncross="$(printf '%s\n' "$cross" | grep -c . || true)"
  liv=""
  for nnn in $holders; do
    if ! git -C "$REPO" rev-parse --verify --quiet "refs/tags/done/contracts/$nnn/1" >/dev/null 2>&1; then
      liv="$liv $nnn"
    fi
  done
  nliv="$(printf '%s' "$liv" | wc -w)"
  printf '%s: всего-держателей=%s чужие-авторы=%s живых=%s\n' "$p" "$total" "$ncross" "$nliv"
  printf '  чужие-авторы (точный путь, автор != %s):%s\n' "$a" "$(printf '%s\n' "$cross" | tr '\n' ' ')"
  printf '  живые (без done-тега):%s\n' "$liv"
done
