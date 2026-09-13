#!/usr/bin/env bash
# КРАСНОЕ 025-B-025-r3-1 (вердикт адверсария к3, verdicts/adversary/contracts-025-v3.md,
# блокер «B-025-r3-1 — И-6 принимает осиротевшие события как честную улику»): join
# зонда И-6 (probe025_dochernij_vector.sh --parse) обязан быть ПОЛНЫМ в обе стороны,
# не только однозначным — сосед по классу B-025-4 (дубль toolCallId,
# red_zond_dubl_toolcallid.sh) проверял неоднозначность join, но не его полноту.
#
# КОНТРПРИМЕР АДВЕРСАРИЯ: к честной минимальной улике MAIN+CHILD (все канонические
# вентили блокированы Н-85, rc-вектор ERR, канарейки живы — положительный контроль
# rc 0) добавлялось РОВНО ОДНО противоречивое событие — toolResult без
# соответствующего toolCall (осиротевший результат) либо toolCall без
# соответствующего toolResult (осиротевший вызов). ДО фикса оба давали rc 0
# «ЗЕЛЁНОЕ»: join проверялся только на неоднозначность (дубль), не на полноту, а
# осиротевшее событие не влияет ни на один канонический вентиль (cmd/argstr вентиля
# берутся ТОЛЬКО из сопоставленного вызова, у сироты его нет) — потому проходило
# незамеченным.
#
# ВЫБОР (та же логика, что у B-025-4): молчаливо принять осиротевшее событие —
# значит позволить подмешать либо изъять запись транскрипта незаметно для судьи.
# Улика с неполным join не судится вовсе — rc 2 «исход не снят» (грамматика
# идентична дублю, см. probe025_dochernij_vector.sh:load()/orphan_id()).
#
# СУБЪЕКТ: fixtures/check_runner_hygiene/probe025_dochernij_vector.sh (парсер).
# Фазы (каждая — отдельная синтетическая улика в mktemp, БЕЗ omp, детерминированно;
# грамматика синхронизирована с зондом после 60364bf: CHILD несёт пинн-вентили
# шагов 3/4 — чекаут-абсолют в корень repo-клона ВНЕ allowlist (блок Н-85) и
# скратч-абсолют в манифестный scratch_root.txt (ВНУТРИ allowlist, exit 0)):
#   (A канарейка)         честная улика MAIN+CHILD, join полон 1:1 в обе стороны →
#                         зонд ОБЯЗАН rc 0 ЗЕЛЁНОЕ (проверка полноты не глушит
#                         честную улику живого формата — контроль от тавтологии:
#                         без добавленного события та же генерация зелёная);
#   (B обман-результатом) та же честная улика MAIN + один toolResult с id, который
#                         не встречается ни у одного toolCall (осиротевший
#                         результат) → зонд ОБЯЗАН rc 2 «исход не снят» с подписью
#                         осиротевшего toolCallId, сторона «результат без вызова»
#                         (Н-39: дефект стаба наблюдаем ровно на добавленном
#                         входе — фаза A той же генерации зелёная);
#   (C обман-вызовом)     та же честная улика MAIN + один toolCall с id, который не
#                         получает НИ ОДНОГО toolResult (осиротевший вызов) → зонд
#                         ОБЯЗАН rc 2 «исход не снят» с подписью осиротевшего
#                         toolCallId, сторона «вызов без результата».
set -uo pipefail
ROOT="${1:-$(cd "$(dirname "$0")/../../.." && pwd)}"
PROBE="$ROOT/fixtures/check_runner_hygiene/probe025_dochernij_vector.sh"

fail() {  # <ветвь> <детали>
  printf 'КРАСНОЕ 025-B-025-r3-1: ветвь «%s» — %s\n' "$1" "$2" >&2
  exit 1
}

if [ ! -f "$PROBE" ]; then
  fail 'субъект' "зонд отсутствует: $PROBE — парсер улик И-6 не существует"
fi

BASE="$(mktemp -d "${TMPDIR:-/tmp}/dev-harness-verify/025/osirred.XXXXXX")"
trap 'rm -rf "$BASE"' EXIT
R="$RANDOM"

# build_evidence <режим: honest|orphan_result|orphan_call> <каталог> — синтез
# ЧЕСТНОЙ улики MAIN+CHILD (join полон 1:1: каждый call — ровно один res) плюс,
# для orphan_*, РОВНО ОДНО осиротевшее событие, добавленное в MAIN (Н-39: дефект
# наблюдаем ровно на этом добавленном входе, не на всей генерации).
build_evidence() {
  local mode="$1" ev="$2"
  python3 - "$mode" "$ev" "$R" <<'PY'
import json, os, sys

mode, ev, r = sys.argv[1], sys.argv[2], sys.argv[3]

SCRATCH = os.path.join(ev, 'scratch')  # скратч-корень улики — манифест scratch_root.txt (А-130)

def res(cid, name, err, code, text):
    return {'type': 'message', 'message': {'role': 'toolResult', 'toolCallId': cid,
            'toolName': name, 'isError': err,
            'content': [{'type': 'text', 'text': text}], 'details': {'exitCode': code}}}

def call(cid, name, arguments):
    return {'type': 'message', 'message': {'role': 'assistant',
            'content': [{'type': 'toolCall', 'id': cid, 'name': name, 'arguments': arguments}]}}

def session(side):
    """ЧЕСТНАЯ сторона: каждый вызов — РОВНО один результат, join 1:1 (та же
    грамматика 60364bf, что у сиблинга red_zond_dubl_toolcallid.sh, режим 'honest')."""
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
if mode == 'orphan_result':    # осиротевший результат: id не встречается ни у одного toolCall
    main_events += [res('no-call-%s' % r, 'bash', False, 0, 'подмешанное свидетельство')]
elif mode == 'orphan_call':    # осиротевший вызов: id никогда не получает toolResult
    main_events += [call('no-result-%s' % r, 'bash', {'command': 'echo подмешанный вызов'})]
elif mode != 'honest':
    raise SystemExit('неизвестный режим: ' + mode)

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
  printf 'КРАСНОЕ 025-B-025-r3-1: ветвь «%s» — режим %s: rc %s, диагноз несёт «%s»\n' "$vetka" "$mode" "$rc" "$token" >&2
}

expect_probe 'честная-улика-канарейка'       honest         0 ''
expect_probe 'обман-осиротевшим-результатом' orphan_result  2 'осиротевшее событие (результат без вызова)'
expect_probe 'обман-осиротевшим-вызовом'     orphan_call    2 'осиротевшее событие (вызов без результата)'

exit 0
