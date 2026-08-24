#!/usr/bin/env bash
# ПРИЧИНА: bare флаг не принят
# Ветвь (фailfast-дефолт): стаб разбирает ТОЛЬКО --fail-fast=N (не bare). На входе bare
# `--fail-fast <PASS_SHA>` он не отбрасывает флаг, передаёт `--fail-fast` в check_ci_gate как
# `$1` (а не `$PASS_SHA`) → fake даёт rc=1 + «CI не зелёный» — НЕ rc=0 + OK → ветвь красная.
# (Описание фактического пути отказа, по совету критика: стаб НЕ уходит в usage error —
# он пробрасывает `--fail-fast` как sha, и красный диагноз «CI не зелёный» — следствие этого,
# а не явный отказ синтаксиса. Барьер различает «нет rc=0» от «есть rc=0 + OK», что и есть
# доказательство непонимания bare-флага.)
set -euo pipefail
G="$WORK/green"; mkdir -p "$G/scripts"
cat > "$G/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# ЭТАЛОН: правильная реализация --fail-fast (bare → 540; =N → N).
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
"$BARRIER" "$G" фailfast-дефолт

# Красное: стаб, берёт только --fail-fast=N (не bare). На bare --fail-fast упадёт в usage.
R="$WORK/red"; mkdir -p "$R/scripts"
cat > "$R/scripts/judge_gate.sh" <<'EOF'
#!/usr/bin/env bash
# стаб: разбирает только --fail-fast=N; bare --fail-fast даёт usage error.
set -uo pipefail
TBOX=""
case "${1:-}" in
  --fail-fast=*) TBOX="${1#--fail-fast=}"; shift ;;
esac
sha="${1:?usage: $0 --fail-fast=N <sha>}"
SELF="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SELF/check_ci_gate.sh" "$sha"  # без timeout — стаб игнорирует fail-fast
rc=$?
[ "$rc" = 0 ] && echo OK
exit "$rc"
EOF
chmod +x "$R/scripts/judge_gate.sh"
"$BARRIER" "$R" фailfast-дефолт