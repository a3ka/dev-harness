#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39; С-2 Rev143): run шага заменён на YAML-bool
# true (`- run: true`) — до правки С-2 probe.py падал TypeError-трассой на
# "maestro_probe.py" in True. Наблюдаем на входе p01: именованный отказ
# «run шага … не строка (YAML-bool?)», не трасса.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = '      - run: npm test -- --json --outputFile=e2e-erstinformation/jest-otchet.json\n'
novyj = '      - run: true\n'
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: вхождений %d, ожидалось 1" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj, 1)
p.write_text(s, encoding="utf-8")
