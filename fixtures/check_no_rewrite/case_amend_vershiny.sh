# ПРИЧИНА: история перезаписана — прежняя вершина
#
# Второй способ той же природы: `commit --amend`. Дерево на вид то же, сообщение поправлено, а
# прежняя вершина перестала быть предком — значит её коммиты больше ничего не доказывают.
# Отдельная фикстура, потому что `amend` — это то, что делают ЕЖЕДНЕВНО и не считают
# перезаписью истории; правило обязано ловить и его, иначе оно ловит только злой умысел.
set -euo pipefail
R="$WORK/repo"
mkdir -p "$R/plans"
g() {
  GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$R" -c user.name=Фикстура -c user.email=fixture@local \
      -c commit.gpgsign=false -c core.hooksPath=/dev/null "$@"
}
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null git init -q -b main "$R"
printf 'основание\n' > "$R/plans/001-p.md"
g add -A; g commit -q -m 'основание'
base="$(g rev-parse HEAD)"

printf 'вердикт\n' > "$R/plans/002-p.md"
g add -A; g commit -q -m 'второй план'
tip="$(g rev-parse HEAD)"

"$BARRIER" "$base" "$tip" "$R"

g commit -q --amend -m 'второй план, сообщение поправлено'
"$BARRIER" "$tip" "$(g rev-parse HEAD)" "$R"
