#!/usr/bin/env python3
# Стаб 197-r09/e01: скрипт-канон мутирован — путь артефакта строится БЕЗ
# run_attempt (каталоги попыток сливаются). Дефект наблюдаем НА ПОВЕДЕНИИ:
# клетка r09-izoljacija-popytok (записи попыток 1 и 2 попадают в один
# каталог); байт-пин ловит то же расхождение клеткой e01-skript-pin.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / 'mobile/scripts/ci-artefakty.cjs'
s = d.read_text(encoding='utf-8')
staryj = "path.resolve(koren(), k.id + '-' + k.popytka, imja)"
novyj = "path.resolve(koren(), k.id, imja)"
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
staryj2 = "path.resolve(baza, k.id + '-' + k.popytka)"
novyj2 = "path.resolve(baza, k.id)"
if s.count(staryj2) != 1:
    print(f'MUTACIJA_NE_NAIDENA-2: vstrech {s.count(staryj2)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj2, novyj2, 1), encoding='utf-8')
