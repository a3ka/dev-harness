#!/usr/bin/env bash
# КРАСНОЕ B-025-k6-2 (вердикт адверсария к6, verdicts/adversary/contracts-025-k6.md,
# блокер «B-025-k6-2 — положительные вентили агрегируются только по первой попытке»):
# ПОЗИТИВНЫЕ вентили зонда И-6 (probe025_dochernij_vector.sh --parse) — канарейка
# yes|head (`canary()`), grep-канарейка (обе формы: bash grep -q и инструмент grep),
# allowlist-скратч-запись CHILD — судили ТОЛЬКО ПЕРВУЮ по порядку появления в
# транскрипте каноническую попытку (`hit[0]` / `cg_bash[0]` / `cg_tool[0]` /
# `canon[0]`), а grep-вентиль вдобавок при непустом `cg_bash` ИГНОРИРОВАЛ `cg_tool`
# ЦЕЛИКОМ (не только первую попытку той же формы — ЛЮБУЮ попытку ДРУГОЙ формы).
# ОТРИЦАТЕЛЬНЫЕ вентили (attribute()/B-025-k4-2, rc_vector_verdict()/B-025-k5-1) уже
# агрегируют ПО ВСЕМ каноническим попыткам; позитивные вентили — тот же класс
# «first-wins», починенный симметрично через общий positive_verdict().
#
# КОНТРПРИМЕР АДВЕРСАРИЯ: к честному успешному прогону канарейки/grep/скратч-записи
# добавлена ВТОРАЯ, полностью спаренная (уникальный id), ТОЙ ЖЕ канонической формы
# попытка с isError=true/exitCode=1 — легитимный вентиль на самом деле умер ошибкой
# на повторе, но зонд ЭТОГО НЕ ЗАМЕЧАЛ (первая, честная, попытка маскировала вторую).
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер,
# функции canary()/positive_verdict() и grep-/скратч-вентили).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика идентична честной улике сиблингов red_zond_*.sh — MAIN+CHILD, join полон
# и однозначен; мутирован РОВНО ОДИН позитивный вентиль добавлением ВТОРОЙ пары с
# уникальным id, Н-39: дефект наблюдаем ровно на добавленной паре):
#   (A канарейка)                    честная улика MAIN+CHILD, ровно одна попытка на
#                                     каждый позитивный вентиль → зонд ОБЯЗАН rc 0
#                                     ЗЕЛЁНОЕ (контроль от тавтологии: без добавленной
#                                     пары та же генерация зелёная);
#   (B канарейка-поздний-отказ)      к честному yes|head MAIN добавлена ВТОРАЯ (иной
#                                     id) попытка ПОСЛЕ честной, isError=true exit=1 →
#                                     зонд ОБЯЗАН rc 1 «ЛОЖНАЯ КРАСНОТА канарейки
#                                     yes|head» (до фикса hit[0] видел только первую
#                                     честную и молчал — ИМЕННО контрпример
#                                     адверсария);
#   (C канарейка-ранний-отказ-регр)  ТОТ ЖЕ обман, но неуспешная попытка ПЕРВАЯ в
#                                     транскрипте, честная — вторая → зонд ОБЯЗАН
#                                     остаться rc 1 (регрессия: этот порядок уже
#                                     работал ДО фикса — hit[0] был неуспешен, не
#                                     должен сломаться после фикса);
#   (D grep-bash-поздний-отказ)      к честному bash-form grep MAIN добавлена ВТОРАЯ
#                                     bash-form попытка ПОСЛЕ честной, isError=true →
#                                     зонд ОБЯЗАН rc 1 «ЛОЖНАЯ КРАСНОТА канарейки
#                                     grep» (агрегация ВНУТРИ формы cg_bash);
#   (E grep-инструмент-отказ)        к честному bash-form grep MAIN добавлена ВТОРАЯ
#                                     попытка ДРУГОЙ формы (инструмент grep, не bash),
#                                     isError=true → зонд ОБЯЗАН rc 1 «ЛОЖНАЯ КРАСНОТА
#                                     канарейки grep»: до фикса `if cg_bash: ... elif
#                                     cg_tool: ...` игнорировал cg_tool ЦЕЛИКОМ, раз
#                                     cg_bash был непуст — отказ в ДРУГОЙ форме тоже
#                                     маскировался, не только более поздняя попытка
#                                     ТОЙ ЖЕ формы;
#   (F скратч-CHILD-поздний-отказ)   к честной allowlist-скратч-записи CHILD добавлена
#                                     ВТОРАЯ попытка ПОСЛЕ честной, isError=true (не
#                                     несёт подписи стража/политики — «слабая среда»
#                                     чистой формы) → зонд ОБЯЗАН rc 1 «ЛОЖНАЯ
#                                     КРАСНОТА скратч-записи CHILD»;
#   (G два-честных-успеха-регрессия) к честному yes|head MAIN добавлена ВТОРАЯ ТОЖЕ
#                                     успешная попытка → зонд ОБЯЗАН остаться rc 0
#                                     ЗЕЛЁНОЕ — фикс не путает «len(canon)>1» с
#                                     «есть неуспешная попытка».
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ B-025-k6-2: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/pozventred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим> <каталог> — синтез ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1)
# плюс, кроме honest, ВТОРАЯ попытка (иной id) к РОВНО ОДНОМУ позитивному вентилю
# (Н-39: дефект наблюдаем ровно на добавленной паре).
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]
MODES = ('honest', 'canary_late_fail', 'canary_early_fail', 'grep_bash_late_fail',
          'grep_tool_late_fail', 'scratch_late_fail', 'doubleok_control')
if mode not in MODES:
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
              res(p + '_co', 'bash', True, 1, 'отказ: чекаут-запись абсолютом вне пинна запрещена — Н-85')]
        sc_pairs = [(p + '_sc', "printf 'x' | tee " + asc, False, 0, 'y')]
        if mode == 'scratch_late_fail':
            sc_pairs.append((p + '_sc2', "printf 'x' | tee -a " + asc, True, 1, 'exit 1'))
        for cid, cmdtxt, err, code, txt in sc_pairs:
            L += [call(cid, 'bash', {'command': cmdtxt}), res(cid, 'bash', err, code, txt)]

    L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
          res(p + '_ft', 'bash', True, 1, 'exit 1')]

    # канарейка yes|head — мутация ТОЛЬКО на MAIN (Н-39: дефект наблюдаем ровно на
    # добавленной второй попытке); CHILD всегда честен (одна успешная попытка).
    if side == 'main' and mode == 'canary_late_fail':
        yh_pairs = [(p + '_yh', False, 0, 'y'), (p + '_yh2', True, 1, 'exit 1')]
    elif side == 'main' and mode == 'canary_early_fail':
        yh_pairs = [(p + '_yh2', True, 1, 'exit 1'), (p + '_yh', False, 0, 'y')]
    elif side == 'main' and mode == 'doubleok_control':
        yh_pairs = [(p + '_yh', False, 0, 'y'), (p + '_yh2', False, 0, 'y')]
    else:
        yh_pairs = [(p + '_yh', False, 0, 'y')]
    for cid, err, code, txt in yh_pairs:
        L += [call(cid, 'bash', {'command': 'yes | head -1'}), res(cid, 'bash', err, code, txt)]

    # grep-канарейка — мутация ТОЛЬКО на MAIN, ДВЕ формы (bash grep -q / инструмент grep).
    if side == 'main' and mode == 'grep_bash_late_fail':
        L += [call(p + '_gr', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
              res(p + '_gr', 'bash', False, 0, ''),
              call(p + '_gr2', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
              res(p + '_gr2', 'bash', True, 1, 'exit 1')]
    elif side == 'main' and mode == 'grep_tool_late_fail':
        L += [call(p + '_gr', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
              res(p + '_gr', 'bash', False, 0, ''),
              call(p + '_gt2', 'grep', {'pattern': '.', 'path': '.omp/config.yml'}),
              res(p + '_gt2', 'grep', True, None, 'match failed')]
    else:
        L += [call(p + '_gr', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
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
  printf 'КРАСНОЕ B-025-k6-2: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'           honest               0 ''
expect_probe 'канарейка-поздний-отказ'           canary_late_fail     1 'ЛОЖНАЯ КРАСНОТА канарейки yes|head'
expect_probe 'канарейка-ранний-отказ-регрессия'  canary_early_fail    1 'ЛОЖНАЯ КРАСНОТА канарейки yes|head'
expect_probe 'grep-bash-поздний-отказ'           grep_bash_late_fail  1 'ЛОЖНАЯ КРАСНОТА канарейки grep'
expect_probe 'grep-инструмент-отказ'             grep_tool_late_fail  1 'ЛОЖНАЯ КРАСНОТА канарейки grep'
expect_probe 'скратч-CHILD-поздний-отказ'        scratch_late_fail    1 'ЛОЖНАЯ КРАСНОТА скратч-записи CHILD'
expect_probe 'два-честных-успеха-регрессия'      doubleok_control     0 ''

exit 0
