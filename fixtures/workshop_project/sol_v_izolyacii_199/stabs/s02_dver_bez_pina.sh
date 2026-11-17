#!/usr/bin/env bash
# ОБМАННЫЙ СТАБ s02 «дверь без проверки пина»: пара WORKTREE/BRANCH не
# требуется вовсе. Различающие входы батареи: d6 (пара отсутствует) и
# d7 (дубли строк пары) — честная дверь отказывает PIN_NET/GRAMMATIKA_PINA,
# стаб пускает.
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
iso="$(jq -r '(.tasks // [.])[0].isolated // false' "$EVENT")"
[ "$iso" = 'true' ] || { printf 'ОТКАЗ: NE_IZOLIROVAN: рабочий спавн без реального isolated:true (поле события)\n' >&2; exit 1; }
# ДЕФЕКТ СТАБА: проверка пина удалена целиком.
mkdir -p "$SOST" 2>/dev/null
jq -nc --arg t START --arg s "$sv" --arg h "$name" --arg ro "$agent" \
  '{t:$t,subjectId:$s,holder:$h,klass:"rabochij",rol:$ro,isolated:true}' >> "$SOST/uchet.jsonl"
printf 'PUSCHEM %s\n' "$name"
exit 0
