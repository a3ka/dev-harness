#!/usr/bin/env bash
# Контракт 148 (§ПРОВОДКА guard-канал): обёртка над probe.py батареи
# vkladki_tabov_148 — ДВА субъекта: (A) живой scripts/ekran_shablon.py на
# модельной пачке (эталон — model/ekran_shablon.py: байт-копия модели
# батареи 146, v3) и (B) produkt_sud.py на дереве продукта/референса
# (эталон — референсная раскладка model/produktnaja-raskladka):
#   (без флага)  красный прогон: субъект A — живой скрипт (до реализации
#               v3 красны клетки формы: живым остаётся v2 и отвечает
#               SHABLON_NEVEREN «shablon» на shablon 3); субъект B —
#               дерево ХАРНЕССА (продукта нет: PACHKA_ABSENT и расхождения
#               с эталонными ожиданиями); rc 1
#   --model      эталоны: A на модельной пачке + B на референсе — rc 0
#   --stabs      контроль + матрица обманных стабов s65–s81 (SVJAZI 29)
#   --repo R     (с --model/без) субъект B — живой продукт R: до
#               реализации красен, после — зелён
#   --snapshot   фактические rc/вывод эталонов (инструмент замера)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень входов — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красный вход / стаб жив
# (STAB_ZHIV); 2 — нечем проверить (нет python3, ORACLE_TAMPERED,
# рассинхрон стабов, SVERKA_123_ABSENT).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
