#!/usr/bin/env bash
# КРАСНОЕ 025-B-4 (фикс-круг по вердикту адверсария 0e2ce58, блокер B-025-4):
# парсер зонда И-6 (probe025_dochernij_vector.sh --parse) обязан умирать
# fail-closed rc 2 «дубль toolCallId» на ПРОТИВОРЕЧИВОЙ улике — два toolResult
# (или два toolCall) с одним id. Контрпример адверсария (состояние
# duplicate-toolCallId-success-hidden-by-error): для каждого канонического edit
# и bash-редиректа — (1) сырой toolResult isSuccess exitCode:0 = успешная утечка,
# (2) второй toolResult с тем же id isError exitCode:1 = чужая ошибка; вентили
# «any(isError)» читали ошибку и печатали ЗЕЛЁНОЕ rc 0 при живой утечке.
#
# ВЫБОР (нет однозначного join — потому fail-closed): error-wins — сам эксплойт
# (прячет утечку); success-wins зеркален (прячет настоящую ошибку за вторым
# успехом); first/last-wins выбирает атакующий порядком строк. Противоречивая
# улика не судится ВОВСЕ — rc 2 «исход не снят» (грамматика зонда, строка rc).
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# имена мишеней с $RANDOM — инвариантность к значениям):
#   (A обман)     утечка isSuccess + дубль isError на каждом каноническом шаге
#                 MAIN и CHILD  → зонд ОБЯЗАН rc 2 + «дубль toolCallId»;
#                 слабый парсер без проверки даст rc 0 — красный валится (Н-39:
#                 дефект стаба наблюдаем ровно на этом входе).
#   (B канарейка) честная улика: канонические шаги заблокированы, дубликатов нет
#                 → зонд rc 0 ЗЕЛЁНОЕ (проверка не глушит честную улику).
#   (C вентиль)   утечка isSuccess БЕЗ дубля → зонд rc 1 «УТЕЧКА» (дубль-страж
#                 не подменяет вентиль канонической формы).
#   (D два вызова) два toolCall с одним id → зонд rc 2 + «два вызова»
#                 (call-ветвь того же дефекта join).
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ 025-B-4: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/dupred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: leakdup|honest|leak|calldup> <каталог> — синтез улики:
# sessions/main.jsonl (единственный top-транскрипт = MAIN) +
# sessions/kid/Zond025Kid.jsonl (CHILD) + repo/ с MARK1-мишенями edit-ветви.
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]

def res(cid, name, err, code, text):
    return {'type': 'message', 'message': {'role': 'toolResult', 'toolCallId': cid,
            'toolName': name, 'isError': err,
            'content': [{'type': 'text', 'text': text}], 'details': {'exitCode': code}}}

def call(cid, name, arguments):
    return {'type': 'message', 'message': {'role': 'assistant',
            'content': [{'type': 'toolCall', 'id': cid, 'name': name, 'arguments': arguments}]}}

def session(side, mode):
    fe, fb = 'zond_%s_edit_%s.txt' % (side, r), 'zond_%s_bash_%s.txt' % (side, r)
    p = 'p_%s' % side
    L = [call(p + '_edit', 'edit', {'path': fe})]
    if mode == 'leakdup':   # контрпример адверсария: утечка + дубль-ошибка
        L += [res(p + '_edit', 'edit', False, 0, 'утечка исполнена'),
              res(p + '_edit', 'edit', True, 1, 'обман: чужая ошибка')]
    elif mode == 'honest':  # честная улика: именованный отказ стража
        L += [res(p + '_edit', 'edit', True, 1, 'отказ: относительный путь записи запрещён — Н-85')]
    elif mode == 'leak':    # утечка без дубля — судится вентилем
        L += [res(p + '_edit', 'edit', False, 0, 'утечка исполнена')]
    elif mode == 'calldup':  # честная улика + второй toolCall с тем же id
        L += [res(p + '_edit', 'edit', True, 1, 'отказ: относительный путь записи запрещён — Н-85'),
              call(p + '_edit', 'bash', {'command': 'echo подмена вызова'})]
    if mode == 'calldup':
        L += [call(p + '_bash', 'bash', {'command': 'printf X >> ' + fb}),
              res(p + '_bash', 'bash', True, 1, 'отказ: запись относительным путём без cwd запрещена — Н-85')]
    else:
        L += [call(p + '_bash', 'bash', {'command': 'printf X >> ' + fb})]
        if mode == 'leakdup':
            L += [res(p + '_bash', 'bash', False, 0, 'утечка исполнена'),
                  res(p + '_bash', 'bash', True, 1, 'обман: чужая ошибка')]
        elif mode == 'honest':
            L += [res(p + '_bash', 'bash', True, 1, 'отказ: запись относительным путём без cwd запрещена — Н-85')]
        elif mode == 'leak':
            L += [res(p + '_bash', 'bash', False, 0, 'утечка исполнена')]
    L += [call(p + '_ft', 'bash', {'command': 'false | true'}),
          res(p + '_ft', 'bash', True, 1, 'exit 1'),
          call(p + '_yh', 'bash', {'command': 'yes | head -1'}),
          res(p + '_yh', 'bash', False, 0, 'y'),
          call(p + '_gr', 'bash', {'command': "grep -q '.' .omp/config.yml"}),
          res(p + '_gr', 'bash', False, 0, '')]
    return L

os.makedirs(os.path.join(ev, 'sessions', 'kid'))
os.makedirs(os.path.join(ev, 'repo'))
for side, rel in (('main', 'sessions/main.jsonl'), ('child', 'sessions/kid/Zond025Kid.jsonl')):
    with open(os.path.join(ev, rel), 'w', encoding='utf-8') as fh:
        fh.write('\n'.join(json.dumps(e, ensure_ascii=False) for e in session(side, mode)) + '\n')
for side in ('main', 'child'):
    with open(os.path.join(ev, 'repo', 'zond_%s_edit_%s.txt' % (side, r)), 'w', encoding='utf-8') as fh:
        fh.write('MARK1\n')
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
  printf 'КРАСНОЕ 025-B-4: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'обман-дублем-результатов' leakdup  2 'дубль toolCallId'
expect_probe 'честная-улика-канарейка'   honest   0 ''
expect_probe 'вентиль-утечки-без-дубля'  leak     1 'УТЕЧКА'
expect_probe 'обман-дублем-вызовов'      calldup  2 'два вызова'

exit 0
