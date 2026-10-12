#!/usr/bin/env bash
# Клетка 7 (И-7, «Выход» п.2) контракта 093.
# ПОЧИНКА Рв2-3 круга 3: прежняя редакция сузила замороженный вход ровно до
# пути, который был в коде — сироту форкал САМ systemd-run-шим (никакого
# стаб-omp), а завершение шло только по маркеру. Замороженный вход
# (§Красные предъявления, п.7): toy-сессия, СТАБ-OMP форкает sleeper, НЕ
# совпадающий с шаблоном имени '^omp --profile', затем сессия
# завершается/таймаутится; на фиксе дерево потомков пусто (обход БЕЗ
# фильтра по имени, пустая выборка проверена числом), на HEAD/стабе s6 —
# rc 1 «осиротевшие процессы живы».
# Оба прогона несут ПОЛНЫЙ вход (сироту форкает стаб-omp, свидетель ppid):
#   a) естественное завершение — стаб-omp форкает сироту и выходит rc 0,
#      без маркера; остатки гасит reap_session (группа setsid-двери, ПОСЛЕ
#      возврата сессии);
#   b) гашение по маркеру — стаб-omp форкает сироту и живёт; дерево гасит
#      наблюдатель (kill_tree), остатки — reap_session.
# Сирота TERM-иммунен (SIG_IGN переживает exec) — зачистка обязана дойти
# до KILL-фазы; имя 'toy-agent-sleeper' НЕ совпадает с '^omp --profile' —
# чистка по шаблону имени сироту не находит (предмет И-7). Дореализационный
# субъект (чистка только '^omp --profile') и стаб s6 (зачистка вырезана)
# оставляют сироту живым → КРАСНО.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

BASE="$(mktemp -d /tmp/dev-harness-verify/ops-granica-7-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
SUBJ_PID=""

cleanup() {
  if [ -n "$SUBJ_PID" ]; then
    kill -KILL "$SUBJ_PID" 2>/dev/null
    wait "$SUBJ_PID" 2>/dev/null
  fi
  rm -rf "$BASE"
}
trap 'cleanup' EXIT

# ── Сирота (дословно замороженного входа): пишем ppid-свидетель происхождения
# (форк ОТ стаб-omp, числом), становимся TERM-иммунными и живём под именем,
# НЕ совпадающим с шаблоном '^omp --profile'. ──
make_sleeper() { # $1=каталог прогона
  printf '%s\n' '#!/usr/bin/env bash' \
    "printf 'ppid=%s\\n' \"\$PPID\" >\"\$1\"" \
    'trap "" TERM INT' \
    'exec -a toy-agent-sleeper sleep 300' > "$1/sleeper"
  chmod 755 "$1/sleeper"
}

# ── Стаб-omp, вариант a (естественное завершение): форкает сироту, ждёт
# ppid-свидетель (гонку «родитель умер раньше свидетеля» закрываем барьером)
# и выходит rc 0 — сессия завершается сама, маркер НЕ трогается. ──
# ── Стаб-omp, вариант b (гашение по маркеру): тот же форк, затем живёт. ──
make_omp() { # $1=каталог прогона $2=a|b
  {
    printf '%s\n' '#!/usr/bin/env bash'
    printf "%s\n" "printf '%s\n' \"\$\$\" >'$1/omp_pid'"
    printf "%s\n" "\"$1/sleeper\" '$1/sleeper_fact' &"
    printf "%s\n" "printf '%s\n' \"\$!\" >'$1/sleeper_pid'"
    printf "%s\n" "while [ ! -e '$1/sleeper_fact' ]; do :; done"
    if [ "$2" = a ]; then printf '%s\n' 'exit 0'; else printf '%s\n' 'exec sleep 300'; fi
  } > "$1/omp_$2"
  chmod 755 "$1/omp_$2"
}

# ── Shim-ы (прецедент клеток 3/4): systemd-run честно exec'ит команду —
# сессию запускает НАСТОЯЩАЯ дверь субъекта (setsid sh → sudo -nu → стаб-omp),
# сироту форкает стаб-omp, не шим; sudo — свидетель двери uid + честный exec. ──
make_shims() { # $1=каталог прогона
  mkdir -p "$1/bin" "$1/repo" "$1/agent_home"
  printf '%s\n' '#!/usr/bin/env bash' \
    'if [ "$1" = "--user" ] && [ "$2" = "--scope" ]; then' \
    '  shift 2' \
    '  while [ $# -gt 0 ] && [ "$1" != "--" ]; do shift; done' \
    '  if [ "$1" = "--" ]; then shift; fi' \
    '  exec "$@"' \
    'fi' \
    'exit 0' > "$1/bin/systemd-run"
  printf '%s\n' '#!/usr/bin/env bash' \
    'set -u' \
    'if [ "${1:-}" = "-nu" ] && [ $# -ge 3 ]; then' \
    '  tgt="$2"; shift 2' \
    "  printf 'user=%s\\nargv0=%s\\n' \"\$tgt\" \"\$1\" >'$1/sudo_fact'" \
    '  exec "$@"' \
    'fi' \
    'printf "sudo-шим: ожидается -nu <user> <cmd>\n" >&2' \
    'exit 1' > "$1/bin/sudo"
  chmod 755 "$1/bin/systemd-run" "$1/bin/sudo"
  printf '# stub handoff\n' > "$1/repo/HANDOFF.md"
}

# ── Один прогон: <tag> <a|b> <touch-mark|no-mark>. 0 — чист, 1 — отказ. ──
run_case() {
  local tag="$1" variant="$2" domark="$3"
  local d="$BASE/$tag" pgid spid n p src alive
  mkdir -p "$d"
  make_shims "$d"
  make_sleeper "$d"
  make_omp "$d" "$variant"

  env PATH="$d/bin:$PATH" \
    ORCH_REPO="$d/repo" ORCH_WORKSHOP="$d/omp_$variant" \
    ORCH_MARK="$d/mark" ORCH_STOP="$d/stop" ORCH_LOG="$d/loop.log" \
    ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
    ORCH_CRASH=9 ORCH_EARLY=0 ORCH_N=0 \
    ORCH_AGENT_HOME="$d/agent_home" \
    ORCH_LOOP_AGENT_CMD="$d/omp_$variant" \
    bash "$SUBJ" >"$d/subj_out" 2>&1 &
  SUBJ_PID=$!

  # Завершение сессии: a — естественное (стаб-omp уже вышел rc 0, маркер не
  # трогаем); b — гашение по маркеру (наблюдатель: GRACE → TERM/KILL дерева).
  sleep 1
  [ "$domark" = touch-mark ] && touch "$d/mark"

  # Ждём выхода субъекта (маркерный путь: 5с до маркера + GRACE 1с + фазы
  # ≤35с + reap ≤4с); cap 90с.
  alive=1
  for _ in $(seq 1 90); do
    if ! kill -0 "$SUBJ_PID" 2>/dev/null; then alive=0; break; fi
    sleep 1
  done
  if [ "$alive" -eq 1 ]; then
    kill -KILL "$SUBJ_PID" 2>/dev/null
    wait "$SUBJ_PID" 2>/dev/null
    SUBJ_PID=""
    printf 'КРАСНО(%s): осиротевшие процессы живы — субъект не завершился после завершения сессии (И-7 пробит: зачистка не работает / стаб s6)\n' "$tag" >&2
    return 1
  fi
  wait "$SUBJ_PID" 2>/dev/null
  src=$?
  SUBJ_PID=""

  # Вход построен? Свидетели: дверь uid вызвана, стаб-omp исполнялся, сирота
  # форкнут ИМЕННО от стаб-omp (ppid ребёнка == pid стаб-omp, числом).
  if [ ! -f "$d/sudo_fact" ] || [ ! -f "$d/omp_pid" ] || [ ! -f "$d/sleeper_pid" ] || [ ! -f "$d/sleeper_fact" ]; then
    printf 'КРАСНО(%s): вход клетки не построен — нет свидетелей двери/стаб-omp/сироты\n' "$tag" >&2
    return 1
  fi
  pgid="$(cat "$d/omp_pid")"
  spid="$(cat "$d/sleeper_pid")"
  if ! grep -Fxq "ppid=$pgid" "$d/sleeper_fact"; then
    printf 'КРАСНО(%s): сирота форкнут НЕ от стаб-omp (свидетель ppid != %s) — вход клетки не построен\n' "$tag" "$pgid" >&2
    return 1
  fi

  # И-7: несовпадающий с шаблоном имени TERM-иммунный сирота НЕ пережил
  # завершение сессии.
  if kill -0 "$spid" 2>/dev/null; then
    kill -KILL "$spid" 2>/dev/null
    printf 'КРАСНО(%s): осиротевшие процессы живы — потомок стаб-omp (pid %s, имя вне шаблона) пережил завершение сессии (И-7 пробит, стаб s6)\n' "$tag" "$spid" >&2
    return 1
  fi
  # Пустая выборка проверена ЧИСЛОМ: в группе сессии (pgid = лидер setsid-
  # двери == pid стаб-omp) не осталось ни одного живого процесса.
  n="$(pgrep -g "$pgid" 2>/dev/null | wc -l)"
  if [ "$n" -ne 0 ]; then
    for p in $(pgrep -g "$pgid" 2>/dev/null); do kill -KILL "$p" 2>/dev/null; done
    printf 'КРАСНО(%s): осиротевших в группе сессии живо: %s (обход без фильтра по имени, И-7)\n' "$tag" "$n" >&2
    return 1
  fi
  printf '  %s: чисто — сирота мёртв, группа пуста (субъект rc=%s)\n' "$tag" "$src" >&2
  return 0
}

itog=0
run_case a a no-mark || itog=1
run_case b b touch-mark || itog=1
if [ "$itog" -ne 0 ]; then
  printf 'КРАСНО(093-7): осиротевшие процессы живы — потомки стаб-omp переживают завершение сессии (естественное и по маркеру)\n' >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-7): оба завершения сессии (естественное rc 0 и по маркеру) оставили дерево/группу пустыми — сирота стаб-omp (имя вне шаблона, TERM-иммунен) зачищен без фильтра по имени (И-7)\n' >&2
exit 0
