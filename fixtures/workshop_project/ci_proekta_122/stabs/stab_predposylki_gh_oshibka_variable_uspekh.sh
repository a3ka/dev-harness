#!/usr/bin/env bash
# МУТАНТ (Н-39; таблица 2×2 --freeze, класс FAIL адверсария 122 impl v3 — обход
# Adv122c-variable-gh-bypass): честная модель check_predposylki, в которой на ОДНОЙ строке с
# маркером МУТАЦИЯ-122:freeze-gh-variable отказ `|| gh_nedostupen variable $?` заменён на
# `|| return 0` — ненулевой rc `gh variable list` принят как успех (сверка имени variable
# пропущена); ветвь secret, поле, грамматика и счёт не меняются.
# Наблюдаемое расхождение: клетка z9-variable-gh-oshibka (--freeze, контракт объявляет ТОЛЬКО
# variable ONLY_VARIABLE, `gh variable list` rc 127) обязана дать rc 1 gh-nedostupen — мутант даёт
# rc 0 PREDPOSYLKI_OK. z3 (gh сломан, объявлены secret и variable) зелена: отказ на secret
# наступает раньше ветви variable — маскировка, ради которой z9 изолирована. Маркер не ровно один
# раз либо замена не применилась — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/check_predposylki.sh
MARK='МУТАЦИЯ-122:freeze-gh-variable'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
T=$(awk -v m="$MARK" 'index($0, m) { if (sub(/\|\| gh_nedostupen variable \$\?/, "|| return 0")) done = 1 } { print } END { exit !done }' "$M") || {
  printf 'mutant ОТКАЗ: замена на строке %s не применилась\n' "$MARK" >&2; exit 2; }
bash <(printf '%s\n' "$T") "$@"
