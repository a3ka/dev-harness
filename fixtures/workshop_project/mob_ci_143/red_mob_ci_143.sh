#!/usr/bin/env bash
# Контракт 143 (mob-ci-razdelenie): guard-канал §ПРОВОДКА — обёртка над
# probe.py; режим передаётся АРГУМЕНТОМ (до ленда cutover CI несёт --stabs
# явно; после ленда оркестратор переключает шаг на безфлаговый red-режим с
# --repo <корень продукта>, где отсутствие субъекта — rc 1 SUBJECT_ABSENT с
# поимённым перечнем клеток: зелень без субъекта невозможна):
#   (без флага, без --repo)  — rc 1 SUBJECT_ABSENT + все клетки красны поимённо
#   (без флага, --repo R)    — судится живой продукт R (до cutover красен)
#   --model                  эталон model/ (контроль входов)
#   --stabs                  контроль + матрица обманных стабов (SVJAZI N)
# v3 судит универсальную матрицу и детские доказательства ПЕРВЫМ; v2
# replay остаётся независимым контролем моделей/стабов до cutover. На живом
# продукте v2-статический запрет matrix и поимённый перечень jobs устарели.
# Коды возврата: 0 — обе применимые батареи зелёные; 1 — предмет красен;
# 2 — нет предпосылки/оракул повреждён.
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 python3 "$HERE/matrix_v3.py" "$@" || exit $?
case " $* " in
  *" --repo "*) exit 0 ;;
esac
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
