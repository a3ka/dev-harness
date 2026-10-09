#!/usr/bin/env bash
# Клетка 7 (И-7, «Выход» п.2) контракта 093.
# ПРЕДМЕТ: toy-сессия orch-loop; прямой потомок пускача в scope (TERM-иммунный
# «omp --profile …», шим systemd-run становится им через exec -a) переживает
# TERM-фазу наблюдателя; затем сессия завершается по маркеру. На фикс: KILL-фаза
# наблюдателя чистит потомка — дерево потомков пускача пусто (обход без фильтра
# по имени, пустая выборка проверена числом). Стаб s6 «сироты-живут» убирает
# TERM/KILL-фазы — на нём клетка красна: потомок жив.
# ОГРАНИЧЕНИЕ (живой замер на d54e5bc7): честный orch-loop чистит только
# прямых потомков, совпадающих с шаблоном '^omp --profile'; несовпадающий
# sleeper честным кодом не чистится вовсе — поэтому выживающий в клетке потомок
# совпадает с шаблоном имени (TERM-иммунен), а проверка «несовпадающего
# сироты» честным кодом не проходит и в клетку не входит (дефект субъекта,
# доложен оркестратору отдельно от батареи).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${OPS093_ROOT:-$(cd "$HERE/../.." && pwd)}"
SUBJ="$ROOT/ops/server/user/orch-loop"
[ -f "$SUBJ" ] || { printf 'NOT_IMPLEMENTED: нет субъекта %s\n' "$SUBJ" >&2; exit 2; }

SCRATCH="$(mktemp -d /tmp/dev-harness-verify/ops-granica-7-XXXXXX)" || { printf 'NOT_IMPLEMENTED: mktemp\n' >&2; exit 2; }
trap 'rm -rf "$SCRATCH"' EXIT

mkdir -p "$SCRATCH/bin" "$SCRATCH/repo"
cd "$SCRATCH/repo" || exit 2
[ -f HANDOFF.md ] || printf '# stub handoff\n' > HANDOFF.md

SCOPE_PID_FILE="$SCRATCH/scope.pid"

# Shim systemd-run: становится прямым потомком пускача — ставит свидетель RAN
# (scope «создан»), делает себя TERM-иммунным (^omp-именем через exec -a) и
# живёт: до такого потомка честный наблюдатель добирается только KILL-фазой.
printf '%s\n' '#!/usr/bin/env bash' \
  'if [ "$1" = "--user" ] && [ "$2" = "--scope" ]; then' \
  '  shift 2' \
  '  while [ $# -gt 0 ] && [ "$1" != "--" ]; do shift; done' \
  '  if [ "$1" = "--" ]; then shift; fi' \
  "printf '%s\\n' \"\$\$\" > '$SCOPE_PID_FILE'" \
  ": > '$SCRATCH/mark.scoped'" \
  "trap '' TERM" \
  "exec -a 'omp --profile dev -- toy-session' sleep 120" \
  'fi' \
  'exit 0' > "$SCRATCH/bin/systemd-run"
chmod 755 "$SCRATCH/bin/systemd-run"

# Живой запуск субъекта (фон): сессия «идёт» (RAN есть), наблюдатель жив.
env PATH="$SCRATCH/bin:$PATH" \
  ORCH_REPO="$SCRATCH/repo" ORCH_WORKSHOP="$SCRATCH/workshop" \
  ORCH_MARK="$SCRATCH/mark" ORCH_STOP="$SCRATCH/stop" ORCH_LOG="$SCRATCH/loop.log" \
  ORCH_GRACE=1 ORCH_MIN_LIFE=3600 ORCH_EARLY_WAIT=1 ORCH_EARLY_MAX=1 \
  ORCH_CRASH=9 ORCH_EARLY=0 ORCH_N=0 \
  bash "$SUBJ" >"$SCRATCH/subj_out" 2>&1 &
SUBJ_PID=$!

# Завершение сессии по маркеру: наблюдатель субъекта TERM (игнорируется
# потомком) → KILL-фаза (честный код) → сессия завершается.
sleep 1
touch "$SCRATCH/mark"

# Ждём завершения субъекта (честный код: TERM@~6с + KILL-фаза 30с ≈ 36с).
alive=1
for _ in $(seq 1 50); do
  kill -0 "$SUBJ_PID" 2>/dev/null || { alive=0; break; }
  sleep 1
done

cleanup() {
  [ -f "$SCOPE_PID_FILE" ] && kill -KILL "$(cat "$SCOPE_PID_FILE")" 2>/dev/null
  kill -KILL "$SUBJ_PID" 2>/dev/null
  wait "$SUBJ_PID" 2>/dev/null
}
if [ "$alive" -eq 1 ]; then
  cleanup
  printf 'КРАСНО: осиротевшие процессы живы — субъект не завершился, потомок пережил TERM+KILL фазы наблюдателя (И-7 пробит)\n' >&2
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
  printf 'КРАСНО: осиротевшие процессы живы — потомок пускача (pid %s) пережил завершение сессии (И-7 пробит, стаб s6)\n' "$SCOPE_PID" >&2
  exit 1
fi
n="$(pgrep -P "$SUBJ_PID" 2>/dev/null | wc -l)"
[ "$n" -eq 0 ] || { printf 'КРАСНО: осиротевшие процессы живы — потомков пускача %s (И-7)\n' "$n" >&2; exit 1; }

printf 'ЗЕЛЁНО(093-7): дерево потомков пускача пусто, живых=%s, обход без фильтра по имени (И-7; субъект rc=%s)\n' "$n" "$SUBJ_RC" >&2
exit 0
