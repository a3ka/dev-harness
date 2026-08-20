# ПРИЧИНА: 30721 байт
#
# Ветвь правил, AGENTS.md, пара границы (контракт 004 v1): РОВНО 30720 байт → 0;
# 30721 байт → 1. AGENTS.md — фиксированное имя ветви; независимость имён держит
# кейс omp_rules с порождаемым именем.
set -euo pipefail
. "$(dirname "$0")/_gen.sh"
R="$WORK/repo"
mkdir -p "$R"
make_bytes "$R/AGENTS.md" 30720
"$BARRIER" "$R"

make_bytes "$R/AGENTS.md" 30721
"$BARRIER" "$R"
