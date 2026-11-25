#!/usr/bin/env bash
# Reference of verdict-row only; other modes remain the existing production gate.
set -uo pipefail
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
assigned=()
if [ "$#" -eq 11 ] && [ "${10}" = --assigned-model ]; then
  assigned=(--assigned-model "${11}")
  set -- "${@:1:9}"
fi
[ "$#" -eq 5 ] || [ "$#" -eq 9 ] || { printf 'ОТКАЗ: verdict-row аргументы\n' >&2; exit 1; }
sha="$1"; task="$3"; oid="$4"; vf="$5"
[ "$2" = --verdict-row ] || exit 2
[[ "$sha" =~ ^[0-9a-f]{40}$ && "$oid" =~ ^[0-9a-f]{64}$ && "$task" =~ ^[A-Za-z0-9._/-]+$ ]] || exit 1
[ -f "$vf" ] || exit 1
IFS= read -r decision < "$vf"
case "$decision" in accept) out=accept ;; FAIL|ESCALATE) out=fail ;; *) exit 1 ;; esac
if [ "$#" -eq 5 ]; then
  printf 'ОТКАЗ: свидетельство судьи не передано\n' >&2; exit 1
fi
[ "$6" = --sud ] || exit 1
"$SELF/check_sud_model.sh" --verdict "$7" --trace "$8" --object "$sha" --session "$9" "${assigned[@]}" || exit $?
journal="$SELF/../registry/candidates.tsv"
seq=0
if [ -f "$journal" ]; then
  while IFS=$'\t' read -r kind _task _oid _out n; do
    [ "$kind" = verdict ] || continue
    [[ "$n" =~ ^[0-9]+$ ]] || exit 1
    (( n > seq )) && seq="$n"
  done < "$journal"
fi
printf 'verdict\t%s\t%s\t%s\t%s\n' "$task" "$oid" "$out" "$((seq + 1))" >> "$journal" || exit 1
printf 'verdict-строка записана: %s %s %s\n' "$task" "$oid" "$out"
