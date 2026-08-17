# ПРИЧИНА: история перезаписана — прежняя вершина
#
# Способ, который `check_protected.sh` по своей границе поймать не может: `git reset --hard`
# назад. Коммит с защищённым артефактом остаётся в объектной базе, но из графа, достижимого от
# HEAD, исчезает — и барьер защиты честно не видит, что артефакт существовал. Здесь предъявлено,
# что этот случай ловит ДРУГОЙ барьер и ловит там, где данные есть: по прежней вершине ветки.
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

printf 'второй план\n' > "$R/plans/002-p.md"
g add -A; g commit -q -m 'второй план'
tip="$(g rev-parse HEAD)"


# Второй зелёный вызов задевает путь НУЛЕВОЙ вершины — создание ветки. Он объявлен в шапке
# барьера, а зелёные ветви фикстурой не выражаются; но вызвать его здесь стоит ничего, и если
# он однажды перестанет возвращать ноль, учёт этой фикстуры сойдётся иначе и она покраснеет.
"$BARRIER" 0000000000000000000000000000000000000000 "$tip" "$R"
# Зелёный контроль: движение вперёд историю не перезаписывает.
"$BARRIER" "$base" "$tip" "$R"

# Порча: вершина откатывается назад, коммит со вторым планом выпадает из графа.
g reset --hard -q "$base"
"$BARRIER" "$tip" "$(g rev-parse HEAD)" "$R"
