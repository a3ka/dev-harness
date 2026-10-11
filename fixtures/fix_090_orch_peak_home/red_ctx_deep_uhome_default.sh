#!/usr/bin/env bash
# Клетка 090 (глубокая-дефолт): ДЕФОЛТНАЯ ветка UHOME — `getent passwd "$U" |
# cut -d: -f6` — когда ORCH_UHOME НЕ задан (Регрессионная граница контракта
# 090: «UHOME без ORCH_UHOME в окружении вычисляется ПОБАЙТОВО как раньше»).
#
# Почему отдельная клетка: все клетки первой пачки задавали ORCH_UHOME явно —
# дефолтная ветка не тестировалась ВОВСЕ, и стаб адверсария (круг 2, 2026-10-08)
# `UHOME="${ORCH_UHOME:-/nonexistent-090-wrong-default}"` (дефолт заменён
# константой) проходил всю семью зелёным: на входах тех клеток работает ветка
# knob'а, на которой стаб честен. Эта клетка — единственный вход семьи, где
# дефолтная ветка НАБЛЮДАЕМА (Н-39: стаб к той ветви, где его дефект виден).
#
# ГЕРМЕТИЧНОСТЬ (Н-219/П3, та же, что у глубокой клетки): ORCH_UHOME субъекту
# НЕ передаётся (env -u), поэтому единственный способ указать субъекту
# НЕреальный home — подменить САМ ИСТОЧНИК дефолтной ветки: синтетический
# пользователь ORCH_USER (заранее проверено: его нет в реальном passwd) +
# getent-шим в PATH клетки, отвечающий ЗА НЕГО строкой синтетического passwd с
# полем 6 = $W/fakehome (всё остальное делегируется настоящему getent).
# Тест-сессия живёт под fakehome в write-allowlist станции
# (/tmp/dev-harness-verify/**) — ни один путь клетки не выходит за $W.
#
# Копия lib_session.sh помечена LIBSRC: — bootstrap действительно подключил
# библиотеку в главном шелле (единый источник И-13 контракта 080).
#
# Дано:  субъект; синтетический пользователь + getent-шим (поле 6 = fakehome);
#        фейковый home $W/fakehome; тест-сессия
#        <fakehome>/.local/state/dev-harness-sessions/<ID>/.../<NAME>.jsonl
#        (usage 650K, mtime будущее +90с) + свежий субагент <NAME>/Agent090.jsonl;
#        omp-pids непусты; GRACE=HARD_GRACE=2с; помеченная копия lib_session.sh.
# Когда: env -u HOME -u ORCH_SESS_GLOB -u ORCH_UHOME PATH=<шим>:$PATH
#        ORCH_USER=<синтетический> … orch-peak ctx — субъект обязан вычислить
#        UHOME из getent-дефолта, НЕ из knob'а.
# Тогда: rc 0 ∧ маркер перезапуска поставлен ∧ say.log непуст ∧ отчёт несёт
#        «живые субагенты погибнут: LIBSRC:Agent090».
# Ловит (каждый — своим предъявлением, Н-39):
#  - стаб адверсария «дефолт-константа» (`UHOME="${ORCH_UHOME:-/nonexistent-090-wrong-default}"`):
#    rc 0 тихий (пустой глоб → ранний exit 0), но маркера и отчёта НЕТ —
#    клетка отказывает именованным «маркер не поставлен»; лёгкую и глубокую
#    клетки этот стаб проходит честно (там ORCH_UHOME задан);
#  - текущий HEAD (нет ни knob'а, ни посева ORCH_SESS_GLOB): дефолтная ветка
#    getent работает (шим даёт fakehome), но source lib_session.sh рушится
#    «HOME: unbound variable» → rc≠0 — та же Н-217, красное норма;
#  - любую будущую реализацию, где дефолтная ветка потеряла getent
#    (приоритет/грамматика knob'а сломаны): сессия не найдена → нет маркера.
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

# ГЕРМЕТИЧНЫЙ фейковый home — под $W, ничего под реальным ~ пользователя.
FAKEHOME="$W/fakehome"
TESTID="z090gd_$(date +%s)_$$"
FAKEUSER="z090gd_$(date +%s)_$$"
case "$FAKEHOME" in "$W"/*) : ;; *) fix090_fail "fakehome вне scratch — нарушена герметичность Н-219" ;; esac

# ── мок дефолтной ветки: синтетический пользователь + getent-шим ───────────
# Первая ступень клетки — самопроверка мока (как install-клетка проверяет свой
# git-мок): синтетический пользователь НЕ существует в реальном passwd,
# иначе клетка судила бы реального пользователя, а не мок.
[ -z "$(/usr/bin/getent passwd "$FAKEUSER")" ] \
  || fix090_fail "синтетический пользователь $FAKEUSER существует в реальном passwd — мок не синтетический"

BIN="$W/bin"
mkdir -p "$BIN" || fix090_fail "не создан $BIN"
cat > "$BIN/getent" <<'SHIM'
#!/usr/bin/env bash
# getent-шим клетки 090 red_ctx_deep_uhome_default: за синтетического
# пользователя отвечает строкой passwd с полем 6 = fakehome; всё остальное
# делегирует настоящему getent.
if [ "$#" -eq 2 ] && [ "$1" = passwd ] && [ "$2" = "${Z090_FAKE_USER:?}" ]; then
  printf '%s:x:%s:%s:090-synthetic:%s:/bin/bash\n' \
    "$2" "${Z090_FAKE_UID:?}" "${Z090_FAKE_UID:?}" "${Z090_FAKE_HOME:?}"
  exit 0
fi
exec /usr/bin/getent "$@"
SHIM
chmod +x "$BIN/getent" || fix090_fail "не сделан исполняемым getent-шим"

# самопроверка шима — той же командой, что пишет субъект (строка UHOME)
GOT="$(PATH="$BIN:$PATH" Z090_FAKE_USER="$FAKEUSER" Z090_FAKE_UID="$$" \
  Z090_FAKE_HOME="$FAKEHOME" getent passwd "$FAKEUSER" | cut -d: -f6)"
[ "$GOT" = "$FAKEHOME" ] \
  || fix090_fail "getent-шим не даёт fakehome (получено: '${GOT:-пусто}') — мок сломан, субъект не при чём"

# ── посадка тест-сессии ПОД fakehome (достижима ТОЛЬКО через дефолт getent) ─
SD="$FAKEHOME/.local/state/dev-harness-sessions/$TESTID/zones/dev/.omp/profiles/dev/agent/sessions/--home-harness-dev-harness--"
NAME="090_${TESTID}"
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

# ГЛАВНОЕ отличие от глубокой клетки: ORCH_UHOME изъят из окружения —
# субъект обязан получить fakehome из ДЕФОЛТНОЙ ветки (getent), а не из knob'а.
env -u HOME -u ORCH_SESS_GLOB -u ORCH_UHOME \
  PATH="$BIN:$PATH" \
  Z090_FAKE_USER="$FAKEUSER" Z090_FAKE_UID="$$" Z090_FAKE_HOME="$FAKEHOME" \
  ORCH_USER="$FAKEUSER" \
  ORCH_PEAK_TEST="$T" ORCH_REPO="$MARKER" \
  ORCH_STATE="$T/state" ORCH_LOG="$T/log" ORCH_MARK="$T/mark" \
  ORCH_REPORT="$T/report" ORCH_LOOP_STOP="$T/loopstop" \
  ORCH_PEAK_GRACE=2 ORCH_PEAK_POLL=1 ORCH_HARD_GRACE=2 ORCH_HARD_POLL=1 \
  ORCH_CTX_SOFT=400000 ORCH_CTX_HARD=500000 \
  bash "$SUBJ/ops/server/root/orch-peak" ctx 2>"$T/stderr.txt"
rc=$?

if [ "$rc" -ne 0 ]; then
  if grep -q 'unbound variable' "$T/stderr.txt" 2>/dev/null; then
    fix090_fail "дефолт-getent: rc=$rc, Н-217 жив (нет посева ORCH_SESS_GLOB): $(tr '\n' ' ' < "$T/stderr.txt")"
  fi
  fix090_fail "дефолт-getent: rc=$rc (ожидался 0) — сценарий CTX_HARD не дошёл до конца. stderr: $(tr '\n' ' ' < "$T/stderr.txt")"
fi
grep -q 'unbound variable' "$T/stderr.txt" 2>/dev/null \
  && fix090_fail "дефолт-getent: unbound variable: $(tr '\n' ' ' < "$T/stderr.txt")"
[ -e "$T/mark" ] \
  || fix090_fail "дефолт-getent: маркер перезапуска не поставлен — субъект НЕ нашёл тест-сессию через дефолтную ветку UHOME (getent): дефолт подменён константой (стаб адверсария?) либо пуст глоб сессий"
[ -s "$T/say.log" ] || fix090_fail "дефолт-getent: сообщение в панель (say.log) не отправлено"
grep -q 'живые субагенты погибнут' "$T/report" 2>/dev/null \
  || fix090_fail "дефолт-getent: в отчёте нет «живые субагенты погибнут» — субагент не найден (дефолтная ветка UHOME не довела до сессии)"
grep -q 'Agent090' "$T/report" 2>/dev/null \
  || fix090_fail "дефолт-getent: в отчёте нет имени Agent090"
grep -q 'LIBSRC:' "$T/report" 2>/dev/null \
  || fix090_fail "дефолт-getent: нет LIBSRC-префикса — bootstrap lib_session.sh НЕ подключился в главном шелле (единый источник И-13 потерян)"
printf 'ЗЕЛЁНО(090-дефолт-getent): ctx CTX_HARD при env -u ORCH_UHOME: UHOME вычислен из дефолтной getent-ветви (синтетический passwd → fakehome), rc 0, маркер, say, «погибнут: LIBSRC:Agent090», ГЕРМЕТИЧНО (нет путей вне $W)\n'
exit 0
