#!/usr/bin/env python3
# Стаб 197-r11 (v+1): скрипт-канон МОЛЧА выходит rc 0 при чтении
# отсутствующего ТОЧНОГО имени (ложная зелень: смягчение шаблона нельзя
# растянуть на точное имя). Дефект наблюдаем НА ПОВЕДЕНИИ: клетка
# r11-tochnoe-imja-otsutstvuet (ожидает rc 2 + CHTENIE_OTSTUTSTVUET);
# байтовое расхождение ловит и e01-skript-pin.
import sys
from pathlib import Path

d = Path(sys.argv[1]) / 'mobile/scripts/ci-artefakty.cjs'
s = d.read_text(encoding='utf-8')
staryj = """    if (!fs.existsSync(istochnik) || !fs.statSync(istochnik).isDirectory()) {
      otkaz('CHTENIE_OTSTUTSTVUET: ' + path.relative(baza, istochnik));
    }
"""
novyj = """    if (!fs.existsSync(istochnik) || !fs.statSync(istochnik).isDirectory()) {
      process.exit(0); // обманка: тихий пропуск отсутствующего точного имени
    }
"""
if s.count(staryj) != 1:
    print(f'MUTACIJA_NE_NAIDENA: vstrech {s.count(staryj)}', file=sys.stderr)
    sys.exit(1)
d.write_text(s.replace(staryj, novyj, 1), encoding='utf-8')
