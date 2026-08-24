#!/usr/bin/env bash
# ПРИЧИНА: judge_gate не позвал check_ci_gate
# Ветвь (фailfast-медленный): барьер ловит judge_gate, который ВСЕГДА выходит rc=0 + «OK»,
# игнорируя и CI-сигнал, и fail-fast-тайм-бокс. На SLOW_SHA с --fail-fast=2 fake спит 3с,
# а стаб выдаёт rc=0 + OK без задержки — НЕ «FAIL-FAST: превышен тайм-бокс 2 с» → ветвь красная.
# Зелёный контроль — heredoc эталона (как в case_failfast_passes.sh).
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast.
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
"$BARRIER" "$G" фailfast-медленный

# Красное: стаб, всегда rc=0 + «OK», без timeout.
R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# стаб: всегда RC=0 + «OK» — игнорирует и CI-сигнал, и fail-fast-тайм-бокс.
echo OK
exit 0
EOF
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-медленный