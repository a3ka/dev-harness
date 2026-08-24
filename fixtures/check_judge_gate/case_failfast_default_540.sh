#!/usr/bin/env bash
# ПРИЧИНА: FAIL-FAST: превышен тайм-бокс 1 с
# Ветвь (фailfast-дефолт-540): барьер проверяет, что bare --fail-fast действительно
# подставляет TBOX=540 (а не 0/1/2). Fake спит 2с: при default=540 fake успевает (rc=0);
# при default<2 timeout срабатывает раньше → rc=1. Стаб, ставящий TBOX=1 для bare,
# даст RC=1 + «FAIL-FAST: превышен тайм-бокс 1 с» — НЕ «default 540 на fake 2с» → die.
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (default 540).
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast) TBOX=540; shift ;;
  --fail-fast=*) TBOX="${1#--fail-fast=}"; shift ;;
esac
sha="${1:?usage: $0 [--fail-fast[=<N>]] <sha>}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
timeout --foreground "$TBOX" "$SELF/check_ci_gate.sh" "$sha"
rc=$?
[ "$rc" = 124 ] && { printf 'FAIL-FAST: превышен тайм-бокс %s с\n' "$TBOX" >&2; exit 1; }
[ "$rc" = 0 ] && printf 'OK\n'
exit "$rc"
EOF
chmod +x "$G/scripts/judge_gate.sh"
SLEEP_FOR=2 "$BARRIER" "$G" фailfast-дефолт-540

# Красное: стаб, ставящий TBOX=1 для bare (а не 540) — fake спит 2с, timeout на 1с сработает.
R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# стаб: bare --fail-fast ставит TBOX=1 (НЕ 540). На fake спит 2с — timeout сработает раньше.
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