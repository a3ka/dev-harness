#!/usr/bin/env bash
# Scoped contract-996 acceptance; no network and no shared checkout writes.
set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd -P)"
TOOLS="$(cd "$HERE/../../.." && pwd -P)"

# Адверсарий-2 (круг 1): контракт 996 §Порядок требует от пакета E «ключ
# package.json» батареи. Полный прогон (без --case/--model/--mutant) обязан
# отказать на отсутствии ключа и на зашитой заглушке (мутант 8dd10c23):
# неплацебо доказывается диспетчеризацией — probe.py на неизвестном case
# отвечает rc 2 (argparse), заглушка `true` молчит rc 0.
_full=1
for _arg in "$@"; do
  case "$_arg" in --case|--model|--mutant) _full=0 ;; esac
done
if [ "$_full" -eq 1 ]; then
  _key='check:rezhim-996-family-selftest'
  _cmd="$(jq -r --arg k "$_key" '.scripts[$k] // empty' "$TOOLS/package.json")"
  case "$_cmd" in
    *fixtures/workshop_project/rezhim_996/probe.sh*) ;;
    *) printf '996: npm-ключ %s отсутствует или не ведёт к батарее (контракт 996 §Порядок: ключ package.json)\n' "$_key" >&2
       exit 1 ;;
  esac
  _out="$( cd "$TOOLS" && bash -c "$_cmd --case __no_such_case__" 2>&1 )"
  _rc=$?
  if [ "$_rc" -ne 2 ]; then
    printf '996: npm-ключ %s плацебо: dispatch rc=%s, ожидается 2\n' "$_key" "$_rc" >&2
    exit 1
  fi
fi
exec python3 "$HERE/probe.py" "$@"
