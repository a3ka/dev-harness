#!/usr/bin/env bash
# КРАСНОЕ B-025-k4-1 (вердикт адверсария к4, verdicts/adversary/contracts-025-k4.md,
# блокер «B-025-k4-1 — join не проверяет согласованность типа инструмента»):
# join зонда И-6 (probe025_dochernij_vector.sh --parse) сопоставляет toolResult
# со связанным toolCall ПО toolCallId, но `name` вентиля берёт ИЗ toolResult.toolName,
# а `cmd`/`argstr` — ИЗ СВЯЗАННОГО toolCall БЕЗ ПРОВЕРКИ, что toolCall.name и
# toolResult.toolName для ОДНОГО id — ОДНО И ТО ЖЕ имя инструмента.
#
# КОНТРПРИМЕР АДВЕРСАРИЯ: toolCall назван `read` (аргументы — путь/команда
# КАНОНИЧЕСКОГО вентиля), связанный toolResult ЛЖИВО назван `edit`/`bash` —
# join склеивает их в «честный bash/edit-вызов», хотя реальный `read` bash не
# исполняет и файлы не правит. ДО фикса join молча доверял КАЖДОЙ стороне по
# отдельности (id совпал — достаточно); ПОСЛЕ — несовпадение имён при непустых
# обеих сторонах есть ПРОТИВОРЕЧИВАЯ улика, СОСЕДНИЙ (не повторный) класс с
# дублем (B-025-4) и сиротой (B-025-r3-1): не судится вовсе, rc 2.
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер,
# функции load()/mismatch()).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика идентична честной улике сиблингов red_zond_dubl_toolcallid.sh /
# red_zond_osirotevshij_toolcallid.sh — MAIN+CHILD, join полон и однозначен —
# мутировано РОВНО ОДНО поле toolCall.name одной пары, Н-39: дефект наблюдаем
# ровно на этом изменённом входе):
#   (A канарейка)              честная улика MAIN+CHILD, все имена согласованы →
#                              зонд ОБЯЗАН rc 0 ЗЕЛЁНОЕ (проверка согласованности
#                              не глушит честную улику живого формата — контроль
#                              от тавтологии: без мутации та же генерация зелёная);
#   (B обман-именем-edit)      та же честная улика, НО toolCall.name edit-вентиля
#                              MAIN подменён на `read` (toolResult.toolName
#                              остаётся честным `edit`) → зонд ОБЯЗАН rc 2
#                              «несогласованность имени инструмента» с подписью
#                              toolCallId;
#   (C обман-именем-bash)      та же честная улика, НО toolCall.name
#                              bash-write-вентиля MAIN подменён на `read`
#                              (toolResult.toolName остаётся честным `bash`) →
#                              зонд ОБЯЗАН rc 2 «несогласованность имени
#                              инструмента» с подписью toolCallId.
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ B-025-k4-1: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/imenred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: honest|mismatch_edit|mismatch_bash> <каталог> — синтез
# ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1, все имена согласованы); для
# mismatch_* — РОВНО ОДИН toolCall.name (эдит- либо bash-write-вентиля MAIN)
# подменяется на `read` (Н-39: дефект наблюдаем ровно на этом мутированном
# входе, не на всей генерации). toolResult.toolName ВСЕГДА остаётся честным.
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]
if mode not in ('honest', 'mismatch_edit', 'mismatch_bash'):
    raise SystemExit('неизвестный режим: ' + mode)

SCRATCH = os.path.join(ev, 'scratch')  # скратч-корень улики — манифест scratch_root.txt (А-130)

def res(cid, name, err, code, text):
    return {'type': 'message', 'message': {'role': 'toolResult', 'toolCallId': cid,
            'toolName': name, 'isError': err,
            'content': [{'type': 'text', 'text': text}], 'details': {'exitCode': code}}}

def call(cid, name, arguments):
    return {'type': 'message', 'message': {'role': 'assistant',
            'content': [{'type': 'toolCall', 'id': cid, 'name': name, 'arguments': arguments}]}}

# ЧЕСТНАЯ сторона (грамматика 60364bf, идентична сиблингам red_zond_*);
# toolCall.name edit- либо bash-write-вентиля MAIN подменяется на `read`
# РОВНО когда мутирует именно эта пара (mismatch_edit/mismatch_bash) —
# toolResult.toolName при этом ВСЕГДА остаётся честным, как в контрпримере
# адверсария (несогласованность односторонняя).
def session(side):
    fe, fb = 'zond_%s_edit_%s.txt' % (side, r), 'zond_%s_bash_%s.txt' % (side, r)
    p = 'p_%s' % side
    aco = os.path.join(ev, 'repo', 'zond_child_checkout_%s.txt' % r)
    asc = os.path.join(SCRATCH, 'zond_child_scratch_%s.txt' % r)
    edit_call_name = 'read' if (mode == 'mismatch_edit' and side == 'main') else 'edit'
    bash_call_name = 'read' if (mode == 'mismatch_bash' and side == 'main') else 'bash'
    L = [call(p + '_edit', edit_call_name, {'path': fe}),
         res(p + '_edit', 'edit', True, 1, 'отказ: относительный путь записи запрещён — Н-85'),
         call(p + '_bash', bash_call_name, {'command': 'printf X >> ' + fb}),
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
  printf 'КРАСНОЕ B-025-k4-1: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'           honest         0 ''
expect_probe 'обман-несогласованным-именем-edit' mismatch_edit  2 'несогласованность имени инструмента'
expect_probe 'обман-несогласованным-именем-bash' mismatch_bash  2 'несогласованность имени инструмента'

exit 0
