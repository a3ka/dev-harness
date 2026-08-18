# ПРИЧИНА: не обнаружен omp
#
# Неполный набор: один из четырёх обязательных скилов отсутствует.
# Зелёный: все четыре (из настоящего репо) → 0. Красное: один удалён → код 1.
set -euo pipefail
R="$WORK/repo"
mkdir -p "$R/skills" "$R/tmp"
for s in grilling writing-for-agents tdd diagnosing-bugs; do
  mkdir -p "$R/skills/$s"
  cp "$REPO/skills/$s/SKILL.md" "$R/skills/$s/"
done
"$BARRIER" "$R"
rm -rf "$R/skills/writing-for-agents"
"$BARRIER" "$R"
