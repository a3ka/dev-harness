#!/usr/bin/env bash
# КРАСНОЕ B-025-k6-1 (вердикт адверсария к6, verdicts/adversary/contracts-025-k6.md,
# блокер «B-025-k6-1 — обратный порядок пары обходит проверку имени инструмента»):
# join зонда И-6 (probe025_dochernij_vector.sh --parse, функция load()) сверял
# toolCall.name с toolResult.toolName ТОЛЬКО в момент чтения строки toolResult, беря
# имя вызова из `calls.get(rid)` — если toolResult расположен в JSONL РАНЬШЕ своего
# toolCall (реверс-порядок), `calls[rid]` ещё пуст, cname='' давало вакуумную истину
# сверки (проверка МОЛЧА пропускалась), а argstr/cmd связанного вызова захватывались
# ПУСТЫМИ в момент чтения result'а и НИКОГДА не пересматривались, даже когда call
# приходил позже в той же трассе. Реверс-порядок не просто обходил проверку имени —
# он обнулял видимость всей попытки для ВСЕХ вентилей ниже (canon-фильтры матчат по
# cmd), включая уже починенную агрегацию attribute() (B-025-k4-2): вторая (реверс-
# порядок) попытка того же канонического bash-write операнда становится НЕВИДИМОЙ
# вообще, а не просто «первой в списке».
#
# КОНТРПРИМЕР АДВЕРСАРИЯ: к честной MAIN-улике добавлена ДОПОЛНИТЕЛЬНАЯ, полностью
# спаренная (уникальный id) пара — toolResult СТРОКОЙ РАНЬШЕ toolCall в файле,
# toolResult.toolName='read', toolCall.name='bash' с успешной относительной записью
# в ТОТ ЖЕ канонический bash-write операнд MAIN. До фикса: `bash --parse` даёт rc 0
# ЗЕЛЁНОЕ (несогласованность не замечена — попытка невидима; настоящая утечка того же
# операнда в форме B-025-k4-2, но доставленная реверс-порядком, тоже осталась бы
# незамеченной — см. фазу reverse_match_leak ниже).
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер,
# функция load()/mismatch()).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика идентична честной улике сиблингов red_zond_*.sh — MAIN+CHILD, join полон
# и однозначен; к MAIN добавлена РОВНО ОДНА дополнительная «теневая» пара с уникальным
# id, нацеленная на ТОТ ЖЕ операнд, что и честный bash-write вентиль MAIN — Н-39:
# дефект наблюдаем ровно на добавленной паре):
#   (A канарейка)                  честная улика MAIN+CHILD, без теневой пары → зонд
#                                   ОБЯЗАН rc 0 ЗЕЛЁНОЕ (контроль от тавтологии: без
#                                   добавленной пары та же генерация зелёная);
#   (B обман-реверсом-несогласов)  теневая пара В РЕВЕРС-ПОРЯДКЕ (toolResult раньше
#                                   toolCall в файле), имена НЕСОГЛАСОВАНЫ
#                                   (toolResult.toolName=read, toolCall.name=bash) →
#                                   зонд ОБЯЗАН rc 2 «несогласованность имени
#                                   инструмента» — ИМЕННО контрпример адверсария;
#   (C контроль-форвард-несогласов) ТА ЖЕ теневая пара, но В ФОРВАРД-ПОРЯДКЕ (toolCall
#                                   раньше toolResult) → зонд ОБЯЗАН rc 2 с тем же
#                                   диагнозом — регрессия: сверка симметрична порядку,
#                                   этот порядок уже работал ДО фикса B-025-k6-1 (не
#                                   должен сломаться после);
#   (D реверс-совпадающая-утечка)  теневая пара В РЕВЕРС-ПОРЯДКЕ, но имена СОГЛАСОВАНЫ
#                                   (toolResult.toolName=bash=toolCall.name) и попытка
#                                   УСПЕШНА (isError=false exitCode=0) — настоящая
#                                   ВТОРАЯ успешная попытка того же bash-write операнда,
#                                   доставленная реверс-порядком → зонд ОБЯЗАН rc 1
#                                   «УТЕЧКА bash-вектор MAIN»: доказывает, что фикс не
#                                   просто добавил сверку имени, а восстановил cmd/argstr
#                                   связанного вызова НЕЗАВИСИМО ОТ ПОРЯДКА, поэтому
#                                   attribute() (B-025-k4-2) снова видит эту попытку.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ B-025-k6-1: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/obrporred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: honest|reverse_mismatch|forward_mismatch_control|reverse_match_leak>
# <каталог> — синтез ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1) плюс, кроме honest,
# ОДНА дополнительная теневая пара (уникальный id 'hidden') к MAIN, нацеленная на ТОТ
# ЖЕ канонический bash-write операнд ($fb MAIN) — Н-39: дефект наблюдаем ровно на
# добавленной паре, порядок строк внутри пары и согласованность имён — единственные
# переменные между режимами.
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]
if mode not in ('honest', 'reverse_mismatch', 'forward_mismatch_control', 'reverse_match_leak'):
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
    # ТЕНЕВАЯ пара — ТОЛЬКО у MAIN, ТОЛЬКО когда mode != honest. Нацелена на ТОТ ЖЕ
    # операнд $fb, что и честный (блокированный) bash-write вентиль выше. Порядок
    # строк и согласованность имён — единственная переменная между режимами (Н-39).
    if side == 'main' and mode != 'honest':
        hid = p + '_hidden'
        hidden_call = call(hid, 'bash', {'command': "printf attack | tee " + fb})
        if mode == 'reverse_match_leak':
            hidden_res = res(hid, 'bash', False, 0, 'weak environment accepted write')
        else:
            hidden_res = res(hid, 'read', False, 0, 'ok')  # несогласованное имя (read ≠ bash)
        if mode == 'forward_mismatch_control':
            L += [hidden_call, hidden_res]      # ФОРВАРД: call раньше result
        else:                                   # reverse_mismatch | reverse_match_leak
            L += [hidden_res, hidden_call]       # РЕВЕРС: result раньше call
    return L

os.makedirs(os.path.join(ev, 'sessions', 'kid'))
os.makedirs(os.path.join(ev, 'repo'))
os.makedirs(SCRATCH)
with open(os.path.join(ev, 'sessions', 'main.jsonl'), 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(json.dumps(e, ensure_ascii=False) for e in session('main')) + '\n')
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
  printf 'КРАСНОЕ B-025-k6-1: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'            honest                    0 ''
expect_probe 'обман-реверс-несогласованным-именем' reverse_mismatch          2 'несогласованность имени инструмента'
expect_probe 'контроль-форвард-несогласов'         forward_mismatch_control  2 'несогласованность имени инструмента'
expect_probe 'реверс-совпадающая-утечка'           reverse_match_leak        1 'УТЕЧКА bash-вектор MAIN'

exit 0
