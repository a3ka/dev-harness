#!/usr/bin/env bash
# КРАСНОЕ B-025-k5-1 (вердикт адверсария к5, verdicts/adversary/contracts-025-k5.md,
# блокер «B-025-k5-1 — не-write агрегация rc-вентиля берёт только ПЕРВЫЙ
# false | true»): rc-вентиль зонда И-6 (probe025_dochernij_vector.sh --parse)
# делал `hit = [...]; r = hit[0]` — если ЕСТЬ несколько полностью спаренных
# (разные toolCallId) канонических попыток `bash false | true`, и ПЕРВАЯ по
# порядку в транскрипте оказалась НЕуспешной (isError=true/exitCode=1), а
# ВТОРАЯ (позже) — УСПЕШНОЙ (isError=false/exitCode=0, живой pipefail-эффект) —
# код смотрел ТОЛЬКО на hit[0] и не видел вторую: живой вектор маскировался
# первой (честной) попыткой.
#
# ВЫБОР (тот же принцип, что у B-025-k4-2/attribute(): red_zond_uspeshnyj_
# povtor_kanona.sh): УСПЕХ (exit==0) ЛЮБОЙ отдельной попытки канонической
# группы — красный, порядок появления в транскрипте не должен влиять на
# результат. Фикс НЕ означает «несколько попыток в группе — всегда утечка»:
# фаза (D) ниже — ДВЕ честных попытки (обе ERR, разные коды) БЕЗ единого
# успеха — обязана остаться rc 0 (проверка отличает «есть успех» от «есть
# больше одного результата»).
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер,
# функция rc_vector_verdict()).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика идентична честной улике сиблингов red_zond_*.sh — MAIN+CHILD, join
# полон и однозначен; мутирован РОВНО ОДИН rc-вентиль MAIN добавлением ВТОРОЙ
# пары с уникальным id, Н-39: дефект наблюдаем ровно на добавленной паре):
#   (A канарейка)              честная улика MAIN+CHILD, ровно одна попытка
#                              false|true (ERR) на MAIN → зонд ОБЯЗАН rc 0
#                              ЗЕЛЁНОЕ (контроль от тавтологии: без добавленной
#                              пары та же генерация зелёная);
#   (B обман-вторым-успехом)   к честной (ERR) попытке MAIN добавлена ВТОРАЯ
#                              (иной id): isError=false exitCode=0, ПОЗЖЕ
#                              честной в транскрипте → зонд ОБЯЗАН rc 1
#                              «rc-гигиена MAIN жива» (до фикса hit[0] видел
#                              только первую честную и молчал — ИМЕННО этот
#                              контрпример адверсария);
#   (C обман-первым-успехом)   тот же обман, но успешная попытка ПЕРВАЯ в
#                              транскрипте, честная — вторая → зонд ОБЯЗАН
#                              rc 1 «rc-гигиена MAIN жива» (регрессия: этот
#                              порядок уже работал ДО фикса — не должен
#                              сломаться);
#   (D два-честных-отказа)     к честной попытке MAIN добавлена ВТОРАЯ (иной
#                              id), ТОЖЕ ERR (другой код exit=2) — ни одного
#                              успеха → зонд ОБЯЗАН остаться rc 0 ЗЕЛЁНОЕ —
#                              фикс не путает «len(canon)>1» с «есть утечка».
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ B-025-k5-1: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/rcvekred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: honest|second_success|first_success|doubleblock> <каталог> —
# синтез ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1) плюс, кроме honest, ВТОРАЯ
# попытка (иной id) к rc-вентилю false|true MAIN (Н-39: дефект наблюдаем ровно
# на добавленной паре).
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]
if mode not in ('honest', 'second_success', 'first_success', 'doubleblock'):
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
    # rc-вентиль false | true: мутация ТОЛЬКО на MAIN (Н-39 — дефект наблюдаем
    # ровно на добавленной второй попытке); CHILD всегда честен (одна ERR).
    if side == 'main' and mode == 'second_success':
        L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
              res(p + '_ft', 'bash', True, 1, 'exit 1'),
              call(p + '_ft2', 'bash', {'command': 'false | true'}),
              res(p + '_ft2', 'bash', False, 0, 'weak environment accepted pipeline')]
    elif side == 'main' and mode == 'first_success':
        L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
              res(p + '_ft', 'bash', False, 0, 'weak environment accepted pipeline'),
              call(p + '_ft2', 'bash', {'command': 'false | true'}),
              res(p + '_ft2', 'bash', True, 1, 'exit 1')]
    elif side == 'main' and mode == 'doubleblock':
        L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
              res(p + '_ft', 'bash', True, 1, 'exit 1'),
              call(p + '_ft2', 'bash', {'command': 'false | true'}),
              res(p + '_ft2', 'bash', True, 2, 'exit 2')]
    else:
        L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
              res(p + '_ft', 'bash', True, 1, 'exit 1')]
    L += [call(p + '_yh', 'bash', {'command': 'yes | head -1'}),
          res(p + '_yh', 'bash', False, 0, 'y'),
          call(p + '_gr', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
          res(p + '_gr', 'bash', False, 0, '')]
    return L

os.makedirs(os.path.join(ev, 'sessions', 'kid'))
os.makedirs(os.path.join(ev, 'repo'))
os.makedirs(SCRATCH)
for side, rel in (('main', 'sessions/main.jsonl'), ('child', 'sessions/kid/Zond025Kid.jsonl')):
    with open(os.path.join(ev, rel), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(json.dumps(e, ensure_ascii=False) for e in session(side)) + '\n')
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
  printf 'КРАСНОЕ B-025-k5-1: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'        honest         0 ''
expect_probe 'обман-вторым-успехом'           second_success 1 'rc-гигиена MAIN жива'
expect_probe 'обман-первым-успехом'           first_success  1 'rc-гигиена MAIN жива'
expect_probe 'два-честных-отказа-без-утечки'  doubleblock    0 ''

exit 0
