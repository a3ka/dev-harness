# ПРИЧИНА: роль вне объявленной грамматики
#
# Находка 3 вердикта ревьюера `verdicts/review/shag-5.md`: `check_ids.sh` выхватывал значение
# `verdict:` однострочным `grep` на глубине 1 — фронтматтер не читался, значение не
# валидировалось, подкаталоги не обходились. Роль с `verdict: verdicts/*/` МОЛЧА выводила свой
# каталог из области сверки, и лежащий там дубликат номера становился невидимым: объявление
# работало выключателем защиты, ровно как это уже было в механизме 4.
#
# Закрыто ЕДИНСТВЕННОЙ реализацией грамматики (`scripts/lib_roles.sh`) — той же, которой
# пользуется `check_protected.sh`. Второй разбор одного формата расходится молча; в этом
# репозитории так было уже трижды.
set -euo pipefail
R="$WORK/repo"
mkdir -p "$R/roles" "$R/plans" "$R/verdicts/glob" "$R/scripts" "$R/tmp"
cp "$REPO/scripts/check_ids.sh" "$REPO/scripts/next_id.sh" "$REPO/scripts/lib_roles.sh" "$R/scripts/"
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
printf -- '---\nname: adversary\nverdict: verdicts/adversary/\n---\nроль по грамматике\n' > "$R/roles/adversary.md"
printf 'план\n' > "$R/plans/001-p.md"
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
g add -A; g commit -q -m 'основание'
g tag id/PLAN/001
"$BARRIER" "$R"

# Порча: роль объявляет каталог вердиктов ШАБЛОНОМ, и под шаблоном прячется дубль номера.
printf -- '---\nname: newrole\nverdict: verdicts/*/\n---\nроль с шаблоном\n' > "$R/roles/newrole.md"
printf 'a\n' > "$R/verdicts/glob/001-a.md"
printf 'b\n' > "$R/verdicts/glob/001-b.md"
g add -A; g commit -q -m 'роль объявила каталог шаблоном, под ним дубль'
g tag id/VERDICT/001
"$BARRIER" "$R"
