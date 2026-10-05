#!/usr/bin/env bash
# Диф-компаратор вердиктов четырёх исторических чеков (контракт 083, А2/инв. 8).
# Сравнивает ДВА файлa-снимка (эталон ДО и результат ПОСЛЕ) СТРУКТУРНО:
#   - сортированное МНОЖЕСТВО строк вердиктов, заanchored как `^  (ok|FAIL) `
#     (целая строка-вердикт, не подстрока где угодно);
#   - строка `rc=<N>` (код возврата прогона).
# Коды возврата:
#   0 — множества и rc совпали;
#   1 — именованное расхождение (строки только-ДО / только-ПОСЛЕ / rc различается);
#   2 — пустая выборка (ни одного вердикта ни в одном файле) или нет строки rc=
#       (НЕ зелёное — сравнивать нечего).
set -uo pipefail
[ $# -eq 2 ] || { printf 'diff_verdicts_083 ОТКАЗ: ждал 2 аргумента (эталон ДО, результат ПОСЛЕ)\n' >&2; exit 2; }
[ -f "$1" ] || { printf 'diff_verdicts_083 ОТКАЗ: нет файла ДО: %s\n' "$1" >&2; exit 2; }
[ -f "$2" ] || { printf 'diff_verdicts_083 ОТКАЗ: нет файла ПОСЛЕ: %s\n' "$2" >&2; exit 2; }
A="$(mktemp)"; B="$(mktemp)"; trap 'rm -f "$A" "$B"' EXIT
grep -E '^  (ok|FAIL) ' "$1" | sort > "$A" || true
grep -E '^  (ok|FAIL) ' "$2" | sort > "$B" || true
na="$(wc -l < "$A" | tr -d ' ')"; nb="$(wc -l < "$B" | tr -d ' ')"
[ "$na" -gt 0 ] || { printf 'diff_verdicts_083 ОТКАЗ: пустая выборка ДО (вердиктов %s) — не зелёное\n' "$na" >&2; exit 2; }
[ "$nb" -gt 0 ] || { printf 'diff_verdicts_083 ОТКАЗ: пустая выборка ПОСЛЕ (вердиктов %s) — не зелёное\n' "$nb" >&2; exit 2; }
rca="$(sed -n 's/^rc=//p' "$1" | tail -n1)"; rcb="$(sed -n 's/^rc=//p' "$2" | tail -n1)"
[ -n "$rca" ] || { printf 'diff_verdicts_083 ОТКАЗ: в ДО нет строки rc=\n' >&2; exit 2; }
[ -n "$rcb" ] || { printf 'diff_verdicts_083 ОТКАЗ: в ПОСЛЕ нет строки rc=\n' >&2; exit 2; }
rc=0
only_a="$(comm -23 "$A" "$B")"; only_b="$(comm -13 "$A" "$B")"
if [ -n "$only_a" ]; then printf 'только-ДО:\n%s\n' "$only_a" >&2; rc=1; fi
if [ -n "$only_b" ]; then printf 'только-ПОСЛЕ:\n%s\n' "$only_b" >&2; rc=1; fi
if [ "$rca" != "$rcb" ]; then printf 'rc различается: ДО=%s ПОСЛЕ=%s\n' "$rca" "$rcb" >&2; rc=1; fi
if [ "$rc" -eq 0 ]; then printf 'verdiktov=%s, rc=%s — совпали\n' "$na" "$rca" >&2; fi
exit "$rc"
