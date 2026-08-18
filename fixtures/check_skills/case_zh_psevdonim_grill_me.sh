# ПРИЧИНА: не документирован в шапке grilling
#
# Ветвь (ж): псевдоним grill-me обязан быть документирован в шапке grilling. Настоящие
# тела — чтобы (е) не маскировала.
set -euo pipefail
R="$WORK/repo"
mkdir -p "$R/skills" "$R/scripts" "$R/tmp"
for s in grilling writing-for-agents tdd diagnosing-bugs; do
  mkdir -p "$R/skills/$s"
  cp "$REPO/skills/$s/SKILL.md" "$R/skills/$s/"
done
"$BARRIER" "$R"

# Порча: убираем псевдоним из шапки
sed -i '/grill-me/d' "$R/skills/grilling/SKILL.md"
"$BARRIER" "$R"
