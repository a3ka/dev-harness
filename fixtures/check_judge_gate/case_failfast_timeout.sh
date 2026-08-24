#!/usr/bin/env bash
# ПРИЧИНА: rc=1
# Ветвь (фailfast-медленный): барьер ловит стаб-ИМИТАТОР fail-fast, который синхронно
# ждёт fake все 3с, после RC=1 печатает дословно «FAIL-FAST: превышен тайм-бокс 2 с» и
# выходит 1. Без `timeout` он НЕ ускоряет отказ — на SLOW_SHA ждёт fake 3с → elapsed ≥ 2800мс.
# Барьер ловит это на проверке elapsed < 2800 (стаб проходит RC≠0 + подстроку, но проваливается
# на времени). Зелёный контроль — heredoc эталона с `timeout --foreground`.
# (Стаб «echo OK; exit 0» тоже валится, но на другом die — «judge_gate не позвал check_ci_gate»;
# имитатор ловит именно ИМИТАЦИЮ fail-fast, что и было ОБХОДОМ критика.)
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (timeout убивает на ~TBOX секунд).
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*) TBOX="${1#--fail-fast=}"; shift ;;
esac
sha="${1:?usage: $0 [--fail-fast[=<N>]] <sha>}"
command -v timeout >/dev/null 2>&1 || { printf 'FAIL-FAST: timeout не найден\n' >&2; exit 1; }
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
rc=$?
[ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
[ "$rc" = 0 ] && printf 'OK\n'
exit "$rc"
EOF
chmod +x "$G/scripts/judge_gate.sh"
"$BARRIER" "$G" фailfast-медленный

# Красное: стаб-имитатор — синхронно ждёт fake 3с, потом печатает «FAIL-FAST» и rc=1.
# НЕ использует timeout. Проваливается на новой проверке elapsed < 2800мс.
R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# стаб: синхронно ждёт fake, потом печатает «FAIL-FAST» — имитация без timeout.
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SELF/check_ci_gate.sh" "$@"
rc=$?
[ "$rc" != 0 ] && { printf 'FAIL-FAST: превышен тайм-бокс 2 с\n' >&2; exit 1; }
[ "$rc" = 0 ] && echo OK
exit "$rc"
EOF
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-медленный