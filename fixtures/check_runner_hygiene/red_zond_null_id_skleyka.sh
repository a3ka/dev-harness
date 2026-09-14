#!/usr/bin/env bash
# КРАСНОЕ B-025-k5-2 (вердикт адверсария к5, verdicts/adversary/contracts-025-k5.md,
# блокер «B-025-k5-2 — null/malformed toolCallId склеивается со строкой "None"
# и прячет осиротевший call»): join зонда И-6 (probe025_dochernij_vector.sh
# --parse, функция load()) проверял дубль/полноту ТОЛЬКО когда
# `id not in (None, '')`, но ВСЁ РАВНО сохранял ЛЮБОЙ toolCall под ключом
# str(id) — два toolCall с id=null (или id вовсе отсутствует у toolResult)
# схлопывались/терялись без единого именованного отказа: второй call с
# id=null тихо ПЕРЕЗАПИСЫВАЛ первый под общим ключом "None", а toolResult с
# toolCallId="None" удовлетворял проверке полноты, маскируя ОСИРОТЕВШИЙ
# первый (атакующий) call; toolResult с toolCallId=null (без пары вовсе) не
# попадал в seen_res и проходил КАК ЕСЛИ БЫ его не было — молчаливая дыра
# полноты join, соседняя (не повторная) с B-025-r3-1 (та ловит сироту только
# для НЕПУСТЫХ id).
#
# ВЫБОР: id ОБЯЗАН быть непустой строкой ДО str()-канонизации
# (str(None) == 'None' == str("None")) — любой не-строковый/пустой id
# (null, отсутствует, '') — fail-closed rc 2 именованным отказом «malformed/
# null toolCallId», НЕ молчаливое схлопывание под общим ключом.
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер,
# функции load()/malformed_id()).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика идентична честной улике сиблингов red_zond_*.sh — MAIN+CHILD, join
# полон и однозначен; мутация — РОВНО одно/два добавленных null-id события в
# MAIN, Н-39: дефект наблюдаем ровно на добавленном входе):
#   (A канарейка)                 честная улика MAIN+CHILD, все id — непустые
#                                 строки → зонд ОБЯЗАН rc 0 ЗЕЛЁНОЕ (контроль
#                                 от тавтологии: без добавленных событий та же
#                                 генерация зелёная);
#   (B обман-null-атакой)         ТОЧНЫЙ контрпример адверсария: ДВА toolCall
#                                 с id=null добавлены в MAIN — ПЕРВЫЙ атакует
#                                 (bash-запись канонической мишени
#                                 относительным путём), ВТОРОЙ безобиден
#                                 (read) и перезаписывает первого под общим
#                                 ключом «None»; toolResult с
#                                 toolCallId="None" (строка) пары со вторым
#                                 → зонд ОБЯЗАН rc 2 «malformed/null
#                                 toolCallId» (до фикса: rc 0 ЗЕЛЁНОЕ —
#                                 первый call бесследно терялся);
#   (C обман-null-результатом)    toolResult с toolCallId=null (буквальный
#                                 null, без пары вовсе) добавлен в MAIN →
#                                 зонд ОБЯЗАН rc 2 «malformed/null
#                                 toolCallId» (до фикса: событие не
#                                 добавлялось в seen_res и проходило
#                                 непроверенным — rc 0 ЗЕЛЁНОЕ).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ B-025-k5-2: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/nullidred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: honest|null_call_shadow|null_result> <каталог> — синтез
# ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1, все id непустые строки) плюс, для
# null_*, добавленные в MAIN malformed-id события (Н-39: дефект наблюдаем ровно
# на добавленном входе, не на всей генерации).
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]
if mode not in ('honest', 'null_call_shadow', 'null_result'):
    raise SystemExit('неизвестный режим: ' + mode)

SCRATCH = os.path.join(ev, 'scratch')  # скратч-корень улики — манифест scratch_root.txt (А-130)

def res(cid, name, err, code, text):
    return {'type': 'message', 'message': {'role': 'toolResult', 'toolCallId': cid,
            'toolName': name, 'isError': err,
            'content': [{'type': 'text', 'text': text}], 'details': {'exitCode': code}}}

def call(cid, name, arguments):
    return {'type': 'message', 'message': {'role': 'assistant',
            'content': [{'type': 'toolCall', 'id': cid, 'name': name, 'arguments': arguments}]}}

def session(side):
    """ЧЕСТНАЯ сторона: каждый вызов — РОВНО один результат, join 1:1, все id
    непустые строки (та же грамматика 60364bf, что у сиблингов red_zond_*.sh)."""
    fe, fb = 'zond_%s_edit_%s.txt' % (side, r), 'zond_%s_bash_%s.txt' % (side, r)
    p = 'p_%s' % side
    aco = os.path.join(ev, 'repo', 'zond_child_checkout_%s.txt' % r)
    asc = os.path.join(SCRATCH, 'zond_child_scratch_%s.txt' % r)
    L = [call(p + '_edit', 'edit', {'path': fe}),
         res(p + '_edit', 'edit', True, 1, 'отказ: относительный путь записи запрещён — Н-85'),
         call(p + '_bash', 'bash', {'command': 'printf X >> ' + fb}),
         res(p + '_bash', 'bash', True, 1, 'отказ: запись относительным путём без cwd запрещена — Н-85')]
    if side == 'child':  # пинн-вентили ТОЛЬКО ребёнка (слово владельца 2026-09-11, §Дыра B)
        L += [call(p + '_co', 'bash', {'command': "printf 'x' | tee " + aco}),
              res(p + '_co', 'bash', True, 1, 'отказ: чекаут-запись абсолютом вне пинна запрещена — Н-85'),
              call(p + '_sc', 'bash', {'command': "printf 'x' | tee " + asc}),
              res(p + '_sc', 'bash', False, 0, 'y')]
    L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
          res(p + '_ft', 'bash', True, 1, 'exit 1'),
          call(p + '_yh', 'bash', {'command': 'yes | head -1'}),
          res(p + '_yh', 'bash', False, 0, 'y'),
          call(p + '_gr', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
          res(p + '_gr', 'bash', False, 0, '')]
    return L

main_events = session('main')
fb_main = 'zond_main_bash_%s.txt' % r
if mode == 'null_call_shadow':
    # ТОЧНЫЙ контрпример адверсария: ПЕРВЫЙ call (id=null) атакует канонической
    # bash-записью, ВТОРОЙ (id=null тоже) безобиден и перезаписывает первого
    # под общим ключом str(None)='None' в calls; toolResult с toolCallId="None"
    # (строка) пары ТОЛЬКО со вторым — первый (атакующий) остаётся без следа.
    main_events += [
        call(None, 'bash', {'command': 'printf attack | tee ' + fb_main}),
        call(None, 'read', {'path': 'irrelevant'}),
        res('None', 'read', False, 0, ''),
    ]
elif mode == 'null_result':
    # toolResult с toolCallId=null (буквальный null, без пары вовсе) — старая
    # проверка полноты (B-025-r3-1) исключала (None, '') из seen_res и
    # пропускала такое событие непроверенным.
    main_events += [res(None, 'bash', False, 0, 'подмешанное свидетельство без вызова')]

os.makedirs(os.path.join(ev, 'sessions', 'kid'))
os.makedirs(os.path.join(ev, 'repo'))
os.makedirs(SCRATCH)
with open(os.path.join(ev, 'sessions', 'main.jsonl'), 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(json.dumps(e, ensure_ascii=False) for e in main_events) + '\n')
with open(os.path.join(ev, 'sessions', 'kid', 'Zond025Kid.jsonl'), 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(json.dumps(e, ensure_ascii=False) for e in session('child')) + '\n')
for side in ('main', 'child'):
    with open(os.path.join(ev, 'repo', 'zond_%s_edit_%s.txt' % (side, r)), 'w', encoding='utf-8') as fh:
        fh.write('MARK1\n')
with open(os.path.join(SCRATCH, 'zond_child_scratch_%s.txt' % r), 'w', encoding='utf-8') as fh:
    fh.write('x\n')
with open(os.path.join(ev, 'scratch_root.txt'), 'w', encoding='utf-8') as fh:
    fh.write(SCRATCH + '\n')
PY
}

# expect_probe <ветвь> <режим> <ожидаемый rc> <токен stderr>
expect_probe() {
  local vetka="$1" mode="$2" want_rc="$3" token="$4" ev out rc
  ev="$BASE/$mode"
  build_evidence "$mode" "$ev" || fail "$vetka" "синтез улики режима $mode не удался"
  out="$(bash "$PROBE" --parse "$ev" 2>&1)"; rc=$?
  if [ "$rc" -ne "$want_rc" ]; then
    fail "$vetka" "режим $mode: ожидался rc $want_rc, получен rc $rc (вывод: ${out:-<пусто>})"
  fi
  if [ -n "$token" ]; then
    case "$out" in
      *"$token"*) ;;
      *) fail "$vetka" "режим $mode: rc верный, но диагноз без токена «$token»: $out" ;;
    esac
  fi
  printf 'КРАСНОЕ B-025-k5-2: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'    honest           0 ''
expect_probe 'обман-null-атакой'          null_call_shadow 2 'malformed/null toolCallId'
expect_probe 'обман-null-результатом'     null_result      2 'malformed/null toolCallId'

exit 0
