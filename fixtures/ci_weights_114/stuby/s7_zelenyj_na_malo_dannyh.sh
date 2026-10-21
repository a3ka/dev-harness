#!/usr/bin/env bash
# Обманный стаб s7 (zelenyj_na_malo_dannyh, measure): порог min-obs не
# проверяется — TSV пишется и на 0 наблюдений ключа (мало данных = зелёное,
# пусто-зелёный класс). Точка лжи — ST114_LIE=s7 каркаса _karkas_staba.py;
# грамматика/медиана/ceil/атомарность честны. Привязка к клетке — KARTA
# red_114.sh (по коду, Н-39).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ST114_LIE=s7
exec python3 "$HERE/_karkas_staba.py" measure "$@"
