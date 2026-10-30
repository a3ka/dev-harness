#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): в DAG добавлен ЯВНЫЙ работник
# (копия e2e-first-run под именем e2e-vkladki с условием выбора и needs),
# но записи в карте нет — селектор не знает экрана, output выбора не
# объявлен, агрегат не ждёт. Работник либо никогда не запускается, либо
# запускается вне инвентаря (пачка не вынесена/не судится). Дефект
# наблюдаем на входе i02: job без карты — именованное расхождение
# (карта — единственный источник владения, И-1/И-12).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
stroki = p.read_text(encoding="utf-8").splitlines(keepends=True)
nachalo = next(i for i, l in enumerate(stroki) if l.rstrip("\n") == "  e2e-first-run:")
konec = next(i for i in range(nachalo + 1, len(stroki))
             if stroki[i].startswith("  # 143 (e2e-erstinformation)"))
blok = "".join(stroki[nachalo:konec])
kopiya = blok.replace("e2e-first-run", "e2e-vkladki")
if kopiya == blok:
    print("MUTACIJA_NE_NAIDENA: имя e2e-first-run в блоке не найдено", file=sys.stderr)
    sys.exit(1)
stroki.insert(konec, kopiya)
p.write_text("".join(stroki), encoding="utf-8")
