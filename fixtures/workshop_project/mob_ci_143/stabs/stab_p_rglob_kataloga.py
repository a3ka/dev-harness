#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): атака ДВОЙНОГО checkout (вердикт критика
# 1/2) — в e2e-pilot измеренный checkout .harness (4ac99af9, freeze 995/5,
# P v5) СОХРАНЁН, а после него, до шага запуска maestro_probe.py, вставлен
# второй checkout ТОГО ЖЕ path с retired пином 66052cdf (frozen 995/4, P
# копирует весь .maestro rglob-ом). Судья, берущий ПЕРВЫЙ ref, исполняет
# P v5 и даёт зелёное 69/69 — обход исполняемого критерия И-8. Клетка
# p01-P-nabor обязана покраснеть ИСПОЛНЕНИЕМ: ЭФФЕКТИВНЫЙ checkout .harness
# в момент запуска P — ПОСЛЕДНИЙ до шага запуска (66052cdf): replay поднимает
# retired-нагрузку батареи (stabs/p-66052cdf.py, целостность — кодовая
# константа probe.py), подложный maestro фиксирует запрос ВСЕГО каталога
# (8 флоу), а не фиксированного набора P из четырёх.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = (
    "          ref: 4ac99af9fe8b02f16206b5c98bb9556556c05e74\n"
    "          path: .harness\n"
    "          persist-credentials: false\n"
)
if s.count(blok) != 1:
    print("MUTACIJA_NE_NAIDENA: блок checkout 4ac99af9 встречен %d раз, ожидался 1" % s.count(blok), file=sys.stderr)
    sys.exit(1)
dublj = (
    "      - name: Checkout retired probe into the same destination\n"
    "        uses: actions/checkout@v7\n"
    "        with:\n"
    "          repository: a3ka/dev-harness\n"
    "          ref: 66052cdfd134ab0958421a961caef219694a54df\n"
    "          path: .harness\n"
    "          persist-credentials: false\n"
)
s = s.replace(blok, blok + dublj)
p.write_text(s, encoding="utf-8")
