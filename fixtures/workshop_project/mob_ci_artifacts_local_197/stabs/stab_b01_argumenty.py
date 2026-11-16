#!/usr/bin/env python3
# Стаб 197-b01: аргументы писателя не образуют пару --imja/--chto (вместо
# --chto передан --kuda) при грамматически допустимой форме вызова —
# грамматика носителя (g01) допускает ключи из замкнутого набора, точный
# состав пары судит семантика писателя. Дефект наблюдаем на клетке
# b01-forma-pisatelja.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / '.github/workflows/mobile.yml'
s = d.read_text(encoding='utf-8')
staryj = "run: npm run ci:artefakt-zapis -- --imja selection --chto selection.json"
novyj = "run: npm run ci:artefakt-zapis -- --imja selection --kuda selection.json"
if staryj not in s:
    print('MUTACIJA_NE_NAIDENA', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
