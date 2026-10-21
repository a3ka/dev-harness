#!/usr/bin/env bash
# МУТАНТ (Н-39; арбитраж 122 П3, замеры 6–7): честная модель ci_preflight минус ОДНА строка с маркером
# МУТАЦИЯ-122:sverka-po-failu — сверка объявленности (--contract) идёт только по тексту run
# исполняемых (local) шагов, а не по всему тексту файла.
# Наблюдаемое расхождение: клетки p5-env-sekret-ne-perechislen (необъявленный секрет в env шага
# local-джобы, run: true), p5-station-sekret-ne-perechislen (необъявленный секрет в env шага
# station-джобы — боль 995 п.4, android-e2e), p5-if-shag-sekret-ne-perechislen,
# p5-if-dzhoba-var-ne-perechislena и p5-with-sekret-ne-perechislen (необъявленный токен только в if
# шага/джобы, в with шага) обязаны дать rc 1 sekrety-ne-perechisleny; мутант даёт rc 0. Клетка p5
# (секрет в тексте run) зелена. Маркер не ровно один раз — rc 2 (мутант не применён).
set -u
M=$(cd "$(dirname "$0")/../model" && pwd)/ci_preflight.sh
MARK='МУТАЦИЯ-122:sverka-po-failu'
n=$(grep -cF -- "$MARK" "$M")
[ "$n" = 1 ] || { printf 'mutant ОТКАЗ: маркер %s в модели %s раз, нужен 1\n' "$MARK" "$n" >&2; exit 2; }
bash <(grep -vF -- "$MARK" "$M") "$@"
