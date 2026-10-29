#!/usr/bin/env bash
# Контракт 146 (§ПРОВОДКА guard-канал): обёртка над probe.py батареи
# shablon_dvizhenie_146 — судит субъект scripts/ekran_shablon.py (живой
# валидатор харнесса, ветка dvizhenie шаблона 132 v3):
#   (без флага)  python3 probe.py        — red-режим: субъект судится
#               живьём + ПОБАЙТОВЫЙ ПОРТ (B.8): scripts обязан быть равен
#               model байт-в-байт (PORT_NE_DOOSLOVEN — честный красный
#               до пачки implementer; SHABLON_ABSENT, если скрипта нет)
#   --model      эталон (контроль входов; ожидания — kejsy source.json,
#               для вычислимых клеток — прогон эталона ДО субъекта)
#   --stabs      контроль + матрица обманных стабов (SVJAZI 71, живых 0)
#   --d24-real R реальный канон (B.10): пины kontekst (A.6) + честный
#               контроль всех сцен реальной спеки + структурное покрытие
#               семей A.3–A.5 по реальному корпусу + сеяная атака
#   --differencial R  дифференциал C.11: статическая граница трёх версий
#               на двух реальных пачках + равенство v2/v3 на v2-форме
#   --oracle-tamper   самопроба оракула (A.6): порча каждого носителя
#               piny.nositeli в копии — ORACLE_TAMPERED rc 2 ДО клеток
#   --seed N     seed сеяного распределения (дефолт 146; меняет
#               значения/порядок, НЕ структурное покрытие — каталог
#               адресов A.1 и семьи «все адреса разом» seed-независимы)
# Обёртка режим не подменяет и сама ничего не печатает; движок, оракул и
# перечень входов — probe.py и source.json рядом (единый источник).
# Коды возврата — коды probe.py: 0 — зелено; 1 — красный вход / стаб жив
# (STAB_ZHIV) / нет субъекта (SHABLON_ABSENT) / PORT_NE_DOOSLOVEN; 2 —
# нечем проверить (нет python3, ORACLE_TAMPERED, рассинхрон стабов,
# SVERKA_123_ABSENT).
set -u
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 "$HERE/probe.py" "$@"
