#!/usr/bin/env bash
# КРАСНОЕ 025-И-4 (пачка B-2): extension exit-marker — строка [exit=N] в каждом
# bash tool_result из details харнеса (независимо от эха агента).
# СУБЪЕКТ: .omp/extensions/exit-marker.ts. СЕГОДНЯ: модуль отсутствует → rc 1
# именованный. ПОСЛЕ реализации: rc 0.
#
# ГРАММАТИКА judge-протокола (заморожена контрактом 025 §Пачка B-2; Н-39):
#   node exit-marker.ts --judge '<json>'  — один синтетический tool_result:
#     {"tool":"bash","result":{"exitCode":<число|null>,"output":"<текст>"}}
#   Выход — РОВНО ОДНА строка JSON на stdout, rc модуля 0:
#     {"append":"[exit=N]"}          — дописать строку в tool_result
#     {"append":null}                — не bash-результат, не дописывать
#   Значение N — ТОЛЬКО из result.exitCode (details харнеса), НЕ из разбора
#   output: эхо агента «rc=0» при exitCode=1 не имеет силы (форма Н-84).
#   rc модуля 2 — сломанный вход.
#
# АНТИ-ПЛАЦЕБО (вердикт 72049b0, блокер 1): оракул здесь, не в --selftest
# субъекта; декой process.exit(0) не отвечает и умирает именованно; декой
# «всегда [exit=0]» умирает на входах с ненулевыми кодами; декой «парсит эхо»
# умирает на входе-лжи (эхо rc=0 при exitCode=1).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
SUBJ="$ROOT/.omp/extensions/exit-marker.ts"

if [ ! -f "$SUBJ" ]; then
  printf 'КРАСНОЕ 025-И-4: механизм отсутствует — %s не существует; rc bash-вызова виден агенту только его собственным эхом (форма «руками echo rc=0» не ловится)\n' "$SUBJ" >&2
  exit 1
fi

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ 025-И-4: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

# expect <ветвь> <ожидаемый append (строка или "null")> <json>
expect() {
  local vetka="$1" want="$2" evt="$3" out rc got
  out="$(node "$SUBJ" --judge "$evt")"; rc=$?
  if [ "$rc" -ne 0 ]; then
    fail "$vetka" "субъект не ответил решением (rc $rc, вывод: ${out:-<пусто>}) — декой/сломанный модуль"
  fi
  got="$(printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>{try{const j=JSON.parse(s);console.log(j.append===null?"null":(j.append??"BAD"))}catch(e){console.log("BAD_JSON")}})')"
  if [ -z "$got" ] || [ "$got" = "BAD_JSON" ] || [ "$got" = "BAD" ]; then
    fail "$vetka" "субъект не ответил решением-JSON (вывод: ${out:-<пусто>})"
  fi
  if [ "$got" != "$want" ]; then
    fail "$vetka" "ожидалось append=$want, получено $got (вывод: $out)"
  fi
}

expect "код-7-из-details"        "[exit=7]"   '{"tool":"bash","result":{"exitCode":7,"output":"…" }}'
expect "код-0"                   "[exit=0]"   '{"tool":"bash","result":{"exitCode":0,"output":"ok"}}'
expect "код-141-виден-судье"     "[exit=141]" '{"tool":"bash","result":{"exitCode":141,"output":"…"}}'
expect "эхо-лжёт-exitCode-истина" "[exit=1]"  '{"tool":"bash","result":{"exitCode":1,"output":"rc=0"}}'
expect "эхо-лжёт-обратно"        "[exit=0]"   '{"tool":"bash","result":{"exitCode":0,"output":"rc=1"}}'
expect "не-bash-результат"       "null"       '{"tool":"read","result":{"exitCode":0,"output":"x"}}'
expect "exitCode-отсутствует"    "[exit=?]"   '{"tool":"bash","result":{"exitCode":null,"output":"x"}}'

exit 0
