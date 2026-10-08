#!/usr/bin/env bash
# Клетка Н-217 (глубокая): полный сценарий ctx CTX_HARD в окружении БЕЗ HOME и
# БЕЗ ORCH_SESS_GLOB (среда systemd-юнита root, Н-217), на живом CTX_HARD-пути
# субъекта: cur_ctx → say → current_session_dir → live_subagents_in →
# wait_live_agents → wait_saved → отчёт «живые субагенты погибнут» → маркер.
#
# ГЕРМЕТИЧНОСТЬ (Н-219, NABLIUDENIA.md): тест-сессия сажается ПОД ПОЛНЫЙ
# КОНТРОЛЬ клетки — ФЕЙКОВЫЙ home-каталог в write-allowlist станции
# (/tmp/dev-harness-verify/**), а НЕ под реальный ${HOME:-$(getent ...)}.
# Субъект получает фейковый home через НОВЫЙ env-knob ORCH_UHOME (часть
# фикса П1, см. contracts/090-*.md §Диагноз): `UHOME="${ORCH_UHOME:-$(getent
# passwd "$U" | cut -d: -f6)}"` — приоритет ТОЛЬКО у явного knob'а, дефолтное
# поведение (без knob'а) НЕ меняется. Рецидив Н-219 (тест писал в РЕАЛЬНЫЙ
# ~/.local/state/dev-harness-sessions — живой orch-peak станции принял
# тест-сессию за настоящую, 21:45 2026-10-07 ложный «принудительный
# перезапуск», 15м GRACE) этим исключён СТРУКТУРНО: ни один путь этой
# клетки не лежит вне $W (scratch текущего прогона).
#
# Копия lib_session.sh помечена LIBSRC: (выход live_subagents_in получает
# префикс) — доказывает, что bootstrap ДЕЙСТВИТЕЛЬНО подключил библиотеку в
# ГЛАВНОМ шелле (единый источник И-13 контракта 080).
#
# Дано:  субъект; помеченная копия lib_session.sh в $ORCH_PEAK_TEST-мире;
#        фейковый home $W/fakehome; тест-сессия
#        <fakehome>/.local/state/dev-harness-sessions/<ID>/.../<NAME>.jsonl
#        (usage 650K, mtime будущее +90с) + свежий субагент <NAME>/Agent090.jsonl;
#        omp-pids непусты; GRACE=HARD_GRACE=2с.
# Когда: env -u HOME -u ORCH_SESS_GLOB ORCH_UHOME=<fakehome> … orch-peak ctx.
# Тогда: rc 0 ∧ маркер перезапуска поставлен ∧ say.log непуст ∧ отчёт несёт
#        «живые субагенты погибнут: LIBSRC:Agent090».
# Ловит (каждый — своим предъявлением, Н-39):
#  - текущий HEAD (БЕЗ ORCH_UHOME-knob'а в orch-peak): краш «HOME: unbound
#    variable» на source (rc≠0) — Н-217, ORCH_UHOME субъект ещё не умеет,
#    дефолтная ветка getent всё равно требует $HOME НЕ быть unset в lib —
#    краш идентичен лёгкой клетке;
#  - стаб «HOME=/nonexistent»/«HOME=»: краш уходит, но глоб пуст → субагент
#    не найден → нет строки «погибнут» (ложный «нет живых» = причина 695K);
#  - стаб «source в subshell с глушением»: работают локальные fallback'и,
#    но LIBSRC-префикса нет → единый источник И-13 потерян молча.
set -u
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"
SUBJ="${ORCH090_SUBJECT:-$(fix090_repo_root "$HERE")}"
[ -f "$SUBJ/ops/server/root/orch-peak" ] || fix090_fail "нет субъекта $SUBJ/ops/server/root/orch-peak"
[ -f "$SUBJ/scripts/lib_session.sh" ] || fix090_fail "нет $SUBJ/scripts/lib_session.sh"

W="$(fix090_scratch)"
cleanup() {
  [ "${ORCH090_KEEP:-}" = 1 ] || rm -rf "$W" 2>/dev/null || true
  return 0
}
trap cleanup EXIT

# ГЕРМЕТИЧНЫЙ фейковый home — ВСЁ под $W, ничего под реальным ~ пользователя.
FAKEHOME="$W/fakehome"
TESTID="z090test_$(date +%s)_$$"
SD="$FAKEHOME/.local/state/dev-harness-sessions/$TESTID/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--"
NAME="090_${TESTID}"

# посадка тест-сессии: файл сессии (usage 650000) + каталог с живым субагентом
mkdir -p "$SD/$NAME" || fix090_fail "не создан каталог сессии $SD/$NAME"
printf '{"message":{"usage":{"input":1000,"cacheRead":649000,"cacheWrite":0}}}\n' > "$SD/$NAME.jsonl"
touch -d "$(date -u -d '+90 seconds' '+%Y-%m-%dT%H:%M:%SZ')" "$SD/$NAME.jsonl" \
  || fix090_fail "не выставлено будущее mtime (GNU date/touch)"
touch "$SD/$NAME/Agent090.jsonl" || fix090_fail "не создан журнал субагента"

# помеченная копия lib_session.sh: выход live_subagents_in получает LIBSRC:
MARKER="$W/repo"
mkdir -p "$MARKER/scripts"
python3 - "$SUBJ/scripts/lib_session.sh" "$MARKER/scripts/lib_session.sh" <<'PY' \
  || fix090_fail "не помечена копия lib_session.sh (якорь printf дрейфнул?)"
import sys
src, dst = sys.argv[1], sys.argv[2]
s = open(src, encoding='utf-8').read()
old = '  printf \'%s\' "$out"'
new = '  printf \'LIBSRC:%s\' "$out"'
n = s.count(old)
if n != 1:
    print('MARKER-REFUSE: якорь printf встречен %d раз, ожидался 1' % n, file=sys.stderr)
    sys.exit(1)
open(dst, 'w', encoding='utf-8').write(s.replace(old, new))
PY

T="$W/t"
mkdir -p "$T/state"
printf '4194304\n' > "$T/omp-pids"

env -u HOME -u ORCH_SESS_GLOB \
  ORCH_PEAK_TEST="$T" ORCH_REPO="$MARKER" ORCH_UHOME="$FAKEHOME" \
  ORCH_STATE="$T/state" ORCH_LOG="$T/log" ORCH_MARK="$T/mark" \
  ORCH_REPORT="$T/report" ORCH_LOOP_STOP="$T/loopstop" \
  ORCH_PEAK_GRACE=2 ORCH_PEAK_POLL=1 ORCH_HARD_GRACE=2 ORCH_HARD_POLL=1 \
  ORCH_CTX_SOFT=400000 ORCH_CTX_HARD=500000 \
  bash "$SUBJ/ops/server/root/orch-peak" ctx 2>"$T/stderr.txt"
rc=$?

[ "$rc" -eq 0 ] \
  || fix090_fail "глубокая: rc=$rc (ожидался 0) — сценарий CTX_HARD не дошёл до конца. stderr: $(tr '\n' ' ' < "$T/stderr.txt")"
grep -q 'unbound variable' "$T/stderr.txt" \
  && fix090_fail "глубокая: unbound variable: $(tr '\n' ' ' < "$T/stderr.txt")"
[ -e "$T/mark" ] || fix090_fail "глубокая: маркер перезапуска не поставлен"
[ -s "$T/say.log" ] || fix090_fail "глубокая: сообщение в панель (say.log) не отправлено"
grep -q 'живые субагенты погибнут' "$T/report" 2>/dev/null \
  || fix090_fail "глубокая: в отчёте нет «живые субагенты погибнут» — субагент не найден (глоб сессий сломан: стаб-глоб/HOME-заглушка?)"
grep -q 'Agent090' "$T/report" 2>/dev/null \
  || fix090_fail "глубокая: в отчёте нет имени Agent090"
grep -q 'LIBSRC:' "$T/report" 2>/dev/null \
  || fix090_fail "глубокая: нет LIBSRC-префикса — bootstrap lib_session.sh НЕ подключился в главном шелле (единый источник И-13 потерян)"
printf 'ЗЕЛЁНО(090-глубокая): ctx CTX_HARD под env -u HOME -u ORCH_SESS_GLOB ORCH_UHOME=<fakehome>: rc 0, маркер, say, «погибнут: LIBSRC:Agent090», ГЕРМЕТИЧНО (нет путей вне $W)\n'
exit 0
