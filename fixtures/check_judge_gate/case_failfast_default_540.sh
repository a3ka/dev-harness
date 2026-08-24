#!/usr/bin/env bash
# ПРИЧИНА: FAIL-FAST: превышен тайм-бокс 1 с
# Ветвь (фailfast-дефолт-540): барьер проверяет, что bare --fail-fast действительно
# подставляет TBOX=540 (а не 0/1/2/3). Fake спит 2с: при default=540 fake успевает (rc=0);
# при default<2 timeout срабатывает раньше → rc=124 + «FAIL-FAST: превышен тайм-бокс N с».
# Стаб с TBOX=1 для bare: timeout убивает fake на 1с → rc=124 → стаб печатает
# «FAIL-FAST: превышен тайм-бокс 1 с» + exit 1. Эта подстрока в die-сообщении (через
# «Вывод: $OUT») ловит стаб.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (default 540).
# ВАЖНО: timeout вызывается ТОЛЬКО если --fail-fast задан (008-логика для остальных входов).
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*)
    TBOX="${1#--fail-fast=}"
    shift
    case "$TBOX" in
      ''|*[!0-9]*) printf 'FAIL-FAST: тайм-бокс должен быть > 0 (дано: %s)\n' "$TBOX" >&2; exit 1 ;;
    esac
    [ "$TBOX" -gt 0 ] || { printf 'FAIL-FAST: тайм-бокс должен быть > 0 (дано: %s)\n' "$TBOX" >&2; exit 1; }
    ;;
esac
sha="${1:?usage: $0 [--fail-fast[=<N>]] <sha>}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -n "$TBOX" ]; then
  command -v timeout >/dev/null 2>&1 || { printf 'FAIL-FAST: timeout не найден\n' >&2; exit 1; }
  timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
  rc=$?
  [ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
else
  "$SELF/check_ci_gate.sh" "$sha"
  rc=$?
fi
[ "$rc" = 0 ] && printf 'OK\n'
exit "$rc"
EOF
chmod +x "$G/scripts/judge_gate.sh"
SLEEP_FOR=2 "$BARRIER" "$G" фailfast-дефолт-540
# Обязательный положительный контроль all (решение арбитра 2026-08-24).
"$BARRIER" "$G" all

# Красное: стаб, ставящий TBOX=1 для bare (а не 540) — fake спит 2с, timeout на 1с сработает.
R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=1; shift ;;  # НЕ 540
  --fail-fast=*) TBOX="${1#--fail-fast=}"; shift ;;
esac
sha="${1:?usage}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
rc=$?
[ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
[ "$rc" = 0 ] && echo OK
exit "$rc"
EOF
chmod +x "$R/scripts/judge_gate.sh"
SLEEP_FOR=2 "$BARRIER" "$R" фailfast-дефолт-540