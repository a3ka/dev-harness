#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s03 «дверь игнорирует флаг isolated» — семантика двери до
# предмета 199: флаг события не судится вовсе. Различающие входы батареи:
# d2 (isolated:false) и d3 (поле отсутствует) — честная дверь отказывает
# NE_IZOLIROVAN, стаб пускает.
set -u
TAB=$'\t'
MODE=''; SOST=''; ZHUR=''; REPO=''; EVENT=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --sudit) MODE=1 ;;
    --sostojanie) SOST="${2:?}"; shift ;;
    --zhurnaly)   ZHUR="${2:?}"; shift ;;
    --repo)       REPO="${2:?}"; shift ;;
    *) EVENT="$1" ;;
  esac
  shift
done
[ -n "$MODE" ] || exit 2
[ -f "$EVENT" ] || { printf 'NOT_IMPLEMENTED: события нет\n' >&2; exit 2; }
command -v jq >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет jq\n' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет git\n' >&2; exit 2; }
task="$(jq -r '(.tasks // [.])[0].task // ""' "$EVENT")"
agent="$(jq -r '(.tasks // [.])[0].agent // ""' "$EVENT")"
name="$(jq -r '(.tasks // [.])[0].name // ""' "$EVENT")"
sv="$(printf '%s\n' "$task" | grep -E '^SUBJECT=[0-9]{3}$' | sed -n '1p' | cut -c9-11)"
[ -n "$sv" ] || { printf 'ОТКАЗ: SUBJECT_NET_V_ZADANII: нет SUBJECT\n' >&2; exit 1; }
rxw="^WORKTREE=/[^${TAB}]+$"; rxb="^BRANCH=wip/[0-9]{3}/[^${TAB}]+$"
wc="$(printf '%s\n' "$task" | grep -cE "$rxw" || true)"
bc="$(printf '%s\n' "$task" | grep -cE "$rxb" || true)"
if [ "$wc" = '0' ] || [ "$bc" = '0' ]; then printf 'ОТКАЗ: PIN_NET: пара отсутствует\n' >&2; exit 1; fi
if [ "$wc" -gt 1 ] || [ "$bc" -gt 1 ]; then printf 'ОТКАЗ: GRAMMATIKA_PINA: дубли строк\n' >&2; exit 1; fi
wt="$(printf '%s\n' "$task" | grep -E "$rxw" | sed -n '1p' | cut -c10-)"
br="$(printf '%s\n' "$task" | grep -E "$rxb" | sed -n '1p' | cut -c8-)"
[ "$(printf '%s' "${br#wip/}" | cut -c1-3)" = "$sv" ] || { printf 'ОТКАЗ: RASHOZHDENIE_PINA: NNN ≠ SUBJECT\n' >&2; exit 1; }
[ -d "$wt" ] || { printf 'NOT_IMPLEMENTED: worktree пина нет\n' >&2; exit 2; }
# ДЕФЕКТ СТАБА: флаг isolated события не проверяется.
mkdir -p "$SOST" 2>/dev/null
jq -nc --arg t START --arg s "$sv" --arg h "$name" --arg ro "$agent" --arg w "$wt" --arg b "$br" \
  '{t:$t,subjectId:$s,holder:$h,klass:"rabochij",rol:$ro,worktree:$w,branch:$b,isolated:false}' >> "$SOST/uchet.jsonl"
printf 'PUSCHEM %s\n' "$name"
exit 0
