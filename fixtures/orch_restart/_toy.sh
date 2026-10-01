# Каркас семьи orch_restart (контракт 072): строит toy-мир и проверяет
# scripts/orch_restart.sh на нём. Семья — «честный минимум» для
# verify_antiplacebo (нужны ЗЕЛЁНЫЕ контрольные прогоны, чтобы барьер
# видел носитель); расширение GC и полный гейт судит другая батарея
# (fixtures/perezapusk_sessii/red_dver_perezapuska_072.sh).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd -P)"
SUBJ="$REPO/scripts/orch_restart.sh"

LAST_OUT=''; LAST_RC=0
run_subject() {  # <корень> [ORCH_RESTART_MARKER=…] [ORCH_SESSION_START=…]
  local root="$1"; shift
  local marker="${ORCH_RESTART_MARKER:-/tmp/dev-harness-verify/orch-restart}"
  trace="${ORCH_SESSION_START:-/tmp/dev-harness-verify/orch-session-start}"
  rm -f "$marker" "$trace"
  LAST_OUT="$(cd / && env ORCH_RESTART_MARKER="$marker" ORCH_SESSION_START="$trace" "$@" bash "$SUBJ" 2>&1)"
  LAST_RC=$?
  # Дверь НЕ ставит маркер при отказе (инвариант 3).
}

refuse() {  # <имя-входа> <фраза>
  local gate="$1" phrase="$2"
  [ "$LAST_RC" -eq 1 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 1)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq "$phrase" || { printf 'ОТКАЗ: %s: причина не названа дословно «%s»:\n%s\n' "$gate" "$phrase" "$LAST_OUT" >&2; exit 1; }
  printf '%s: отказ rc 1, причина названа дословно\n' "$gate" >&2
}

accept() {  # <имя-входа>
  local gate="$1"
  [ "$LAST_RC" -eq 0 ] || { printf 'ОТКАЗ: %s: rc %s (ожидался 0)\nвывод:\n%s\n' "$gate" "$LAST_RC" "$LAST_OUT" >&2; exit 1; }
  printf '%s\n' "$LAST_OUT" | grep -Fq 'ПЕРЕЗАПУСК' || { printf 'ОТКАЗ: %s: нет строки ПЕРЕЗАПУСК:\n%s\n' "$gate" "$LAST_OUT" >&2; exit 1; }
  printf '%s: rc 0, маркер поставлен\n' "$gate" >&2
}

# mk_toy_repo <каталог>: git-репозиторий с main + origin + HANDOFF.md.
mk_toy_repo() {
  local d="$1"
  mkdir -p "$d/scripts" "$d/fixtures" "$d/contracts"
  cp "$REPO/scripts/check_no_leak.sh" "$d/scripts/"
  git -C "$d" init -q -b main
  git -C "$d" config user.name orchestrator
  git -C "$d" config user.email orchestrator@dev-harness.local
  printf '## ГДЕ МЫ (toy)\n' > "$d/HANDOFF.md"
  printf 'ignored-leak.txt\n' > "$d/.gitignore"
  git init -q --bare -b main "$d-origin.git"
  git -C "$d" remote add origin "$d-origin.git"
  git -C "$d" add -A && git -C "$d" commit -qm 'toy: init'
  git -C "$d" push -q origin main
}

# Намеренно пустые обработчики заглушек (зеркало семьи 043); семья 072
# держит СВОИ стабы в батарее perezapusk_sessii и verify_antiplacebo
# здесь видит только контрольные зелёные клетки.
: "${BARRIER:=$SUBJ}"