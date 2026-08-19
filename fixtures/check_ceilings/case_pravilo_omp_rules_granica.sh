# ПРИЧИНА: > потолка
#
# Ветвь правил, .omp/rules/, пара границы (контракт 004 v1): РОВНО 30720 байт → 0;
# 30721 байт → 1. Имя файла порождается при каждом прогоне — ловит барьер,
# зашитый на известный путь пробы.
set -euo pipefail
. "$(dirname "$0")/_gen.sh"
R="$WORK/repo"
mkdir -p "$R/.omp/rules"
P="$(rnd rule)"
make_bytes "$R/.omp/rules/$P.md" 30720
"$BARRIER" "$R"

make_bytes "$R/.omp/rules/$P.md" 30721
"$BARRIER" "$R"
