# ПРИЧИНА: не обнаружен omp
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Неполный набор: один из четырёх обязательных скилов отсутствует.
# Зелёный: все четыре (из настоящего репо) → 0. Красное: один удалён → код 1.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
stub_omp "$R/bin"
for s in grilling writing-for-agents tdd diagnosing-bugs; do
  mkdir -p "$R/skills/$s"
  cp "$REPO/skills/$s/SKILL.md" "$R/skills/$s/"
done
mkdir -p "$R/.agents/skills"
cp -r "$R/skills/." "$R/.agents/skills/"
stub_pin "$R"
"$BARRIER" --live "$R"
rm -rf "$R/skills/writing-for-agents"
"$BARRIER" --live "$R"
