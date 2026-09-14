#!/usr/bin/env bash
# КРАСНОЕ B-025-k4-2 (вердикт адверсария к4, verdicts/adversary/contracts-025-k4.md,
# блокер «B-025-k4-2 — any(guard block) маскирует успешный повтор канонического
# вектора»): attribute(canon) зонда И-6 (probe025_dochernij_vector.sh --parse)
# выбирала 'block', если ХОТЯ БЫ ОДИН результат канонической группы нёс подпись
# Н-85 — ПРОВЕРЯЛОСЬ ДО проверки успешного результата. Два ПОЛНОСТЬЮ спаренных
# (разные toolCallId) вызова к ОДНОМУ И ТОМУ ЖЕ каноническому пути/операнду —
# первый честно блокирован Н-85, ВТОРОЙ завершён isError=false exitCode=0 —
# реальная живая утечка; `any(refused_by_guard(...))` видела «есть отказ
# где-то» и объявляла ВЕСЬ вентиль блокированным, маскируя проход.
#
# ВЫБОР: успешный проход (raw toolResult без отказа) — ПРЯМОЕ наблюдение
# живого вектора; он проверяется ПЕРВЫМ и перевешивает отказ ДРУГОЙ попытки
# ТОЙ ЖЕ канонической группы (иной toolCallId). Фикс НЕ означает «два
# результата в группе — всегда утечка»: фаза (D) ниже — два честных блока
# БЕЗ единого успеха — обязана остаться rc 0 (проверка отличает «есть успех»
# от «есть больше одного результата»).
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер,
# функция attribute()).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика идентична честной улике сиблингов red_zond_dubl_toolcallid.sh —
# MAIN+CHILD, join полон и однозначен; мутирован РОВНО ОДИН канонический
# вентиль MAIN добавлением ВТОРОЙ пары с уникальным id, Н-39: дефект наблюдаем
# ровно на добавленной паре):
#   (A канарейка)               честная улика MAIN+CHILD, ровно один результат
#                               на каждый канонический вентиль → зонд ОБЯЗАН
#                               rc 0 ЗЕЛЁНОЕ (контроль от тавтологии: без
#                               добавленной пары та же генерация зелёная);
#   (B обман-повтором-edit)     к честному блокированному edit-вентилю MAIN
#                               добавлена ВТОРАЯ пара (иной id, тот же
#                               относительный путь): isError=false exitCode=0
#                               → зонд ОБЯЗАН rc 1 «УТЕЧКА edit-вектор MAIN»
#                               (не rc 0 — старый код видел первый отказ и
#                               молчал);
#   (C обман-повтором-bash)     тот же обман на bash-write-вентиле MAIN
#                               (вторая пара, тот же операнд, успех) → зонд
#                               ОБЯЗАН rc 1 «УТЕЧКА bash-вектор MAIN»;
#   (D два-честных-блока)       к тому же edit-вентилю MAIN добавлена ВТОРАЯ
#                               пара, но ТОЖЕ блокирована Н-85 (нет ни одного
#                               успеха) → зонд ОБЯЗАН остаться rc 0 ЗЕЛЁНОЕ —
#                               фикс не путает «len(canon)>1» с «есть утечка».
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ B-025-k4-2: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/povtorred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: honest|leak_edit|leak_bash|doubleblock_edit> <каталог> —
# синтез ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1) плюс, кроме honest, ВТОРАЯ
# пара (иной id) к ТОМУ ЖЕ каноническому пути/операнду MAIN (Н-39: дефект
# наблюдаем ровно на добавленной паре).
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]
if mode not in ('honest', 'leak_edit', 'leak_bash', 'doubleblock_edit'):
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
         res(p + '_edit', 'edit', True, 1, 'отказ: относительный путь записи запрещён — Н-85')]
    if side == 'main' and mode == 'leak_edit':            # второй edit того же пути: успех БЕЗ отказа
        L += [call(p + '_edit2', 'edit', {'path': fe}),
              res(p + '_edit2', 'edit', False, 0, 'MARK2')]
    elif side == 'main' and mode == 'doubleblock_edit':   # второй edit того же пути: ТОЖЕ отказ
        L += [call(p + '_edit2', 'edit', {'path': fe}),
              res(p + '_edit2', 'edit', True, 1, 'отказ: относительный путь записи запрещён — Н-85')]
    L += [call(p + '_bash', 'bash', {'command': 'printf X >> ' + fb}),
          res(p + '_bash', 'bash', True, 1, 'отказ: запись относительным путём без cwd запрещена — Н-85')]
    if side == 'main' and mode == 'leak_bash':            # второй bash-writer того же операнда: успех
        L += [call(p + '_bash2', 'bash', {'command': 'printf X >> ' + fb}),
              res(p + '_bash2', 'bash', False, 0, 'MARK2')]
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
  printf 'КРАСНОЕ B-025-k4-2: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'      honest           0 ''
expect_probe 'обман-повтором-edit'          leak_edit        1 'УТЕЧКА edit-вектор MAIN'
expect_probe 'обман-повтором-bash'          leak_bash        1 'УТЕЧКА bash-вектор MAIN'
expect_probe 'два-честных-блока-без-утечки' doubleblock_edit 0 ''

exit 0
