#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s01 «дверь верит слову isolated в тексте задания»:
# флаг читается из task-текста (grep isolated:true), а не из поля события.
# Различающий вход батареи: d4 — task утверждает isolated:true, поле события
# false; честная дверь отказывает NE_IZOLIROVAN, стаб пускает.
set -u
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
task="$(jq -r '(.tasks // [.])[0].task // ""' "$EVENT")"
agent="$(jq -r '(.tasks // [.])[0].agent // ""' "$EVENT")"
name="$(jq -r '(.tasks // [.])[0].name // ""' "$EVENT")"
sv="$(printf '%s\n' "$task" | grep -E '^SUBJECT=[0-9]{3}$' | sed -n '1p' | cut -c9-11)"
[ -n "$sv" ] || { printf 'ОТКАЗ: SUBJECT_NET_V_ZADANII: нет SUBJECT\n' >&2; exit 1; }
# ДЕФЕКТ СТАБА: изолированность — слово в тексте, не поле события.
if printf '%s' "$task" | grep -Fq 'isolated:true'; then
  iso=true
else
  printf 'ОТКАЗ: NE_IZOLIROVAN: рабочий спавн без реального isolated:true (поле события)\n' >&2
  exit 1
fi
mkdir -p "$SOST" 2>/dev/null
jq -nc --arg t START --arg s "$sv" --arg h "$name" --arg ro "$agent" \
  '{t:$t,subjectId:$s,holder:$h,klass:"rabochij",rol:$ro,isolated:true}' >> "$SOST/uchet.jsonl"
printf 'PUSCHEM %s\n' "$name"
exit 0
