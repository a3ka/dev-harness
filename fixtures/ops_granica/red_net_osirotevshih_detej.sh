#!/usr/bin/env bash
# Клетка 7 (И-7, «Выход» п.2) контракта 093.
# ПРЕДМЕТ (починка Р1-6 круга 1): прежняя редакция была подогнана под код —
# выживающий потомок совпадал с шаблоном имени '^omp --profile', а
# «несовпадающий с шаблоном» был явно исключён из клетки (правка 746d0160
# ПОСЛЕ реализации 83a245b0). Честная семантика И-7 (дословно контракта):
# стаб-omp форкает sleeper, НЕ совпадающий с шаблоном имени; после
# завершения/таймаута сессии дерево потомков пускача ПУСТО — обход БЕЗ
# фильтра по имени, пустая выборка проверена числом.
# Вход: шим systemd-run становится прямым потомком пускача с именем
# 'toy-agent-sleeper' (НЕ совпадает с '^omp --profile'), TERM-иммунен;
# завершение сессии — по маркеру (наблюдатель субъекта TERM → KILL-фаза).
# Честный код чистит потомков БЕЗ фильтра по имени → дерево пусто, rc 0.
# Стаб s6 «сироты-живут» (TERM/KILL-фазы наблюдателя вырезаны) и
# дореализационный субъект (чистка только по шаблону '^omp --profile')
# оставляют несовпадающего потомка живым → КРАСНО.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-7-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'cleanup' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

SCOPE_PID_FILE="$SCRATCH/scope.pid"

# Shim systemd-run: становится прямым потомком пускача — ставит свидетель
# RAN (scope «создан»), делает себя TERM-иммунным и живёт под именем,
# НЕ совпадающим с шаблоном '^omp --profile' (предмет И-7): честная зачистка
# обязана убрать и его — фильтра по имени у зачистки нет.
printf '%s\n' '#!/usr/bin/env bash' \
  'if [ "$1" = "--user" ] && [ "$2" = "--scope" ]; then' \
  '  shift 2' \
  '  while [ $# -gt 0 ] && [ "$1" != "--" ]; do shift; done' \
  '  if [ "$1" = "--" ]; then shift; fi' \
  "printf '%s\\n' \"\$\$\" > '$SCOPE_PID_FILE'" \
  ": > '$SCRATCH/mark.scoped'" \
  "trap '' TERM INT" \
  "exec -a 'toy-agent-sleeper' sleep 300" \
  'fi' \
  'exit 0' > "$SCRATCH/bin/systemd-run"
chmod 755 "$SCRATCH/bin/systemd-run"

cleanup() {
  if [ -f "$SCOPE_PID_FILE" ]; then
    kill -KILL "$(cat "$SCOPE_PID_FILE")" 2>/dev/null
  fi
  [ -n "${SUBJ_PID:-}" ] && kill -KILL "$SUBJ_PID" 2>/dev/null
  [ -n "${SUBJ_PID:-}" ] && wait "$SUBJ_PID" 2>/dev/null
}

# Рекурсивный обход потомков БЕЗ фильтра по имени (живой замер числом).
desc() { # <pid> — печатает живых потомков всех поколений, по одному в строке
  local p="$1" c
  for c in $(pgrep -P "$p" 2>/dev/null); do
    printf '%s\n' "$c"
    desc "$c"
  done
}

# Живой запуск субъекта (фон): сессия «идёт» (RAN есть), наблюдатель жив.
env PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_EARLY=0 ORCH_N=0 \
  bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1 &
SUBJ_PID=$!

# Завершение сессии по маркеру: наблюдатель субъекта TERM (игнорируется
# TERM-иммунным потомком) → честный код чистит потомков БЕЗ фильтра имени
# → сессия завершается. Чистка только по '^omp --profile' потомка не
# находит — субъект висит на живом scope-потомке.
sleep 1
touch "$SCRATCH/mark"

# Ждём завершения субъекта (честный код: GRACE 1с + KILL-фаза ≤30с ≈ 36с),
# каждую секунду снимая живых потомков пускача — всех, без фильтра имени.
alive=1
last_desc=""
for _ in $(seq 1 90); do
  if ! kill -0 "$SUBJ_PID" 2>/dev/null; then alive=0; break; fi
  last_desc="$(desc "$SUBJ_PID")"
  sleep 1
done

if [ "$alive" -eq 1 ]; then
  cleanup
  printf 'КРАСНО: осиротевшие процессы живы — субъект не завершился: несовпадающий с шаблоном имени потомок пережил наблюдателя (И-7 пробит: чистка по шаблону / стаб s6)\n' >&2
  exit 1
fi
wait "$SUBJ_PID" 2>/dev/null
SUBJ_RC=$?

if [ ! -f "$SCOPE_PID_FILE" ]; then
  printf 'КРАСНО: scope-потомок не создан — вход клетки не построен (нет свидетеля потомка)\n' >&2
  exit 1
fi
SCOPE_PID="$(cat "$SCOPE_PID_FILE")"
if kill -0 "$SCOPE_PID" 2>/dev/null; then
  kill -KILL "$SCOPE_PID" 2>/dev/null
  printf 'КРАСНО: осиротевшие процессы живы — несовпадающий с шаблоном имени потомок (pid %s) пережил завершение сессии (И-7 пробит, стаб s6)\n' "$SCOPE_PID" >&2
  exit 1
fi
# Пустая выборка проверена числом: ни один потомк пускача, живший в момент
# завершения, не остался жив (осиротевшие переподчиняются init'у, но живут).
n=0
for p in $last_desc; do
  if kill -0 "$p" 2>/dev/null; then n=$((n+1)); fi
done
if [ "$n" -ne 0 ]; then
  cleanup
  printf 'КРАСНО: осиротевших потомков пускача живо: %s (обход без фильтра по имени, И-7)\n' "$n" >&2
  exit 1
fi

printf 'ЗЕЛЁНО(093-7): дерево потомков пускача пусто, живых=0, обход без фильтра по имени (И-7; субъект rc=%s)\n' "$SUBJ_RC" >&2
exit 0
