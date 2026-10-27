#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): «rglob всего каталога» при УЖЕ перепиненном
# .harness (симуляция исполненного предшественника 995 v5: ref в задаче,
# исполняющей maestro_probe.py, сменён с пина 995/4 на новый 40-hex). Клетка
# p01-P-nabor при этом АКТИВИРУЕТСЯ и обязана покраснеть: носитель P батареи —
# байты 66052cdf (rglob .maestro), подложный maestro фиксирует запрос ВСЕГО
# каталога (8 флоу), а не фиксированного набора P из четырёх. Доказывает, что
# отложенная клетка — работающий барьер, а не зелёная заглушка.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = "ref: 66052cdfd134ab0958421a961caef219694a54df"
novyj = "ref: 995v5simuljatsija0000000000000000000000000000"
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: пин 66052cdf встречен %d раз, ожидался 1" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
