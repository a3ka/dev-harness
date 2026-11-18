#!/usr/bin/env python3
# Стаб 197-s01 (v3, блок Б-1 FAIL Rev197): скрипт-канон мутирован — шаблонный
# сбор кладёт детей БЕЗ пары прогона в имени каталога (поведение head
# 70ad24e5b9): неизменный ci-aggregate.cjs (зона 143) ждёт
# screen-evidence-<id>-<run_id>-<attempt> и отказывает PEREPIS_DETEJ на
# любом непустом matrix-выборе. Дефект наблюдаем НА СТЫКЕ: клетка
# s01-styk-sbor-agregat (канон-писатель → шаблонный сбор → живой агрегат);
# байтовое расхождение ловит и e01-skript-pin.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / 'mobile/scripts/ci-artefakty.cjs'
s = d.read_text(encoding='utf-8')
staryj = "skopirovat(path.join(katalog_runa, imja), path.join(kuda, imja + para));"
novyj = "skopirovat(path.join(katalog_runa, imja), path.join(kuda, imja));"
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
