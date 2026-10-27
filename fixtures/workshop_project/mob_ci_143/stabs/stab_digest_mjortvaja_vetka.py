#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): мутант критика «проверка digest отключена
# мёртвой веткой» — во ВСЕХ пяти работниках условие проверки digest становится
# `if false && …`, текст маркера APK_DIGEST_RASKHOZHDENIE остаётся (статике
# y11 хватало текста — мутант проходил). Наблюдаем на входе a17: шаг digest
# исполняется с подложным APK иного digest и ПРОХОДИТ (rc 0) — работник доходит
# до экранного шага и ставит подложный APK (в логе подложного adb — USTANOVLEN).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = 'if [ "$got" != "$ZHELANYJ_DIGEST" ]; then'
novyj = 'if false && [ "$got" != "$ZHELANYJ_DIGEST" ]; then'
n = s.count(staryj)
if n != 5:
    print("MUTACIJA_NE_NAIDENA: вхождений %d, ожидалось 5" % n, file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
