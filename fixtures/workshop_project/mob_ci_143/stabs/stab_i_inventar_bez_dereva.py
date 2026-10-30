#!/usr/bin/env python3
# Обманный стаб батареи 143 v2 (Н-39): режим --mode inventar перечисляет
# пачки ТОЛЬКО по карте и не сверяет записи с деревом — запись карты без
# пачки на дереве не отказывает (ZAPIS_BEZ_VHODA нет). Дефект наблюдаем на
# входе i01 (субслучай 3: запись без пачки → обязан быть rc 1
# ZAPIS_BEZ_VHODA; вынос пустого списка зелёный — работник экрана падает
# позже на пустом checkout).
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / "mobile/scripts/select-ci-screens.cjs"
s = p.read_text(encoding="utf-8")
staryj = "      fail(\"ZAPIS_BEZ_VHODA\", `pack ${z.pack} записи ${z.id} нет на дереве`);\n"
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: отказ ZAPIS_BEZ_VHODA (pack) встречен %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, "      continue; // (стаб) записи карты деревом не сверяются\n")
p.write_text(s, encoding="utf-8")
