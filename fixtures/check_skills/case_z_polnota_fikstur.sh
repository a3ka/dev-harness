# ПРИЧИНА: полнота фикстур
#
# Ветвь (з): на родителе первого коммита по skills/ каталог fixtures/check_skills/ содержит
# фикстуры ВСЕХ объявленных ветвей. Одна ранняя и шесть поздних не проходят.
set -euo pipefail
. "$(dirname "$0")/_repo.sh"
R="$WORK/repo"
make_tree "$R"
mkdir -p "$R/fixtures/check_skills"
printf '# ПРИЧИНА: не обнаружен\n' > "$R/fixtures/check_skills/case_a_only.sh"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R" >/dev/null
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.name Ф
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git -C "$R" config user.email f@l
commit_all "$R" one-fixture-only
"$BARRIER" "$R"
