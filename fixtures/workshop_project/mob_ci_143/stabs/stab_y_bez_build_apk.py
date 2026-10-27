#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; арбитраж 143 Б2 — мутант критика 2/2):
# все пять работников теряют ребро к сборке (needs: [select-screens] без
# build-apk). Дефект наблюдаем на привязанных входах: y22 статикой (needs
# работника ≠ [select-screens, build-apk]) и a17 исполнением — шаг digest
# ссылается на needs.build-apk.outputs.*, а рендер needs-контекста возможен
# ТОЛЬКО для job ∈ needs задачи (семантика ГитХаба): без ребра артефакт и
# digest недоступны, РЕНДЕР_ВНЕ_АЛФАВИТА — проверки нет, работник «зелен»
# на пустом контексте (то же красит и y20 — шаг идентичности e2e-start).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path
d = Path(sys.argv[1])

p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = "    needs: [select-screens, build-apk]\n"
novyj = "    needs: [select-screens]\n"
if s.count(staryj) != 5:
    print("MUTACIJA_NE_NAIDENA: needs работников встречены %d раз, ожидалось 5" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
