#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): «агрегат без checkout» — у required-агрегата
# android-e2e удалён шаг actions/checkout (скрипт ci-aggregate.cjs запускается на
# чистом раннере, файла нет — блокер 3 критика). Наблюдаем на входе
# y19-outputs-provodka (структурная нога: checkout с persist-credentials: false
# ДО шага запуска скрипта).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
blok = ("      # 143 (блокер 3 критика): агрегат запускает node mobile/scripts/ci-aggregate.cjs\n"
        "      # — на чистом раннере файла нет; checkout той же ревизии ДО запуска скрипта,\n"
        "      # persist-credentials: false (токен checkout-а не остаётся на диске).\n"
        "      - uses: actions/checkout@v7\n"
        "        with:\n"
        "          persist-credentials: false\n")
if blok not in s:
    print("MUTACIJA_NE_NAIDENA: блок checkout агрегата не найден", file=sys.stderr)
    sys.exit(1)
s = s.replace(blok, "", 1)
p.write_text(s, encoding="utf-8")
