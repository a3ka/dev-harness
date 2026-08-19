# ПРИЧИНА: не документирован в шапке grilling
# ОКРУЖЕНИЕ: PATH=$WORK/repo/bin:$PATH
#
# Ветвь (ж): псевдоним grill-me обязан быть документирован в шапке grilling. Настоящие
# тела — чтобы (е) не маскировала.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
stub_omp "$R/bin"
mkdir -p "$R/skills" "$R/scripts" "$R/tmp"
for s in grilling writing-for-agents tdd diagnosing-bugs; do
  mkdir -p "$R/skills/$s"
  cp "$REPO/skills/$s/SKILL.md" "$R/skills/$s/"
done
mkdir -p "$R/.agents/skills"
cp -r "$R/skills/." "$R/.agents/skills/"
stub_pin "$R"
"$BARRIER" --live "$R"


# Порча: убираем псевдоним из шапки — и из зеркала тоже, чтобы красной была именно (ж)
sed -i '/grill-me/d' "$R/skills/grilling/SKILL.md"
sed -i '/grill-me/d' "$R/.agents/skills/grilling/SKILL.md"
"$BARRIER" --live "$R"
