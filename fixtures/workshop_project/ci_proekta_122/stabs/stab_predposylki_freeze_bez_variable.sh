#!/usr/bin/env bash
# МУТАНТ (Н-39; FAIL адверсария 122 impl v2, probe_skip_variable_freeze): честная модель
# check_predposylki минус ОДНА строка с маркером МУТАЦИЯ-122:freeze-variable — при --freeze каждый
# объявленный secret сверяется с `gh secret list`, объявленный variable с `gh variable list` не
# сверяется (ветвь variable цикла --freeze удалена); поле, грамматика и счёт пунктов не меняются.
# Наблюдаемое расхождение: клетка z6-variable-ne-zavedena (--freeze, контракт объявляет ТОЛЬКО
# variable ONLY_VARIABLE, `gh variable list` успешен, имени в инвентаре нет) обязана дать rc 1
# sekrety-ne-zavedeny: ONLY_VARIABLE — мутант даёт rc 0 PREDPOSYLKI_OK. Клетки z2 (отказ на первом
# незаведённом secret наступает раньше ветви variable), z3 (gh сломан уже на secret), k-freeze (всё
# заведено) зелены. Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/check_predposylki.sh
MARK='МУТАЦИЯ-122:freeze-variable'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
