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
#   --stabs      контроль + матрица обманных стабов s65–s96 (SVJAZI 49)
#   --repo R     (с --model/без) субъект B — живой продукт R: до
#               реализации красен, после — зелён
#   --snapshot   фактические rc/вывод эталонов (инструмент замера)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень входов — probe.py и source.json рядом (единый источник).
# v+1 (слово владельца 2026-11-11, Б-3 Rev148): батарея ДОПОЛНЕНА
# клетками safe-area — входы pr-safe-* (гейты провайдера/чтения инсета
# у продукт-судьи), стабы s95/s96, зондовые тесты Б-3 и исполняемые
# мутанты safe-rezerv-nul/safe-konstanta; прежние клетки не ослаблены
# (63 клетки, 34 стаба, 53 привязки).
# v6-перевод (2026-11-22, слово владельца ~10:53): токенный гейт судит
# ЗНАЧЕНИЯ проекции mobile/src/theme/nav-tokens.ts (kompakt-tokens.ts
# снят); записи 393 — ПРОИЗВОДНЫЕ эталоны safe-area
# (etalony_safe_area/postroit.py + manifest.json, семья
# mobile/etalony-vkladki-393/), гейты ETALON_393_NE_PROIZVODNYJ и
# POROG_NE_0_600 у обоих судей; +4 клетки (porog-oslablen,
# etalon-393-nizhe-poroga, pr-etalon-393-chuzhoj-bajt,
# pr-porog-oslablen), +3 стаба (s99/s100/s101) — 67 клеток, 37 стабов,
# 56 привязок; порог 0.600 и прежние клетки не ослаблены.
# v5-перенацел (2026-11-15): статические якоря продукт-судьи сняты с
# формы PR #147 (замещена v5) — MITTE-маркеры судят ключи каталога
# ui.mission.group.*, KOPII — только каталог 1.1 + запреты финала-2 и
# fixture.*/runtime.value.*, PROKHOD — только цели лейсте (канон 999 +
# gespraech-mitte); см. osi.md «v5-перенацел».
# Коды возврата — коды probe.py: 0 — зелено; 1 — красный вход / стаб жив
# (STAB_ZHIV); 2 — нечем проверить (нет python3, ORACLE_TAMPERED,
# рассинхрон стабов, SVERKA_123_ABSENT).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
