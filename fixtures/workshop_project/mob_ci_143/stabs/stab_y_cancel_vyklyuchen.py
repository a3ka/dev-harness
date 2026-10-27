#!/usr/bin/env python3
# Обманный стаб батареи 143 (Н-39): «cancel выключен» — мутант критика
# `cancel-in-progress: ${{ github.event_name == 'pull_request' }}` → `false`
# (устаревший PR-run не отменяется и делит общий пул — блокер 4). Наблюдаем на
# входе y21-concurrency: при pull_request отмена обязана быть ИСТИНОЙ.
# argv[1] — каталог копии модели.
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / ".github/workflows/mobile.yml"
s = p.read_text(encoding="utf-8")
staryj = "cancel-in-progress: ${{ github.event_name == 'pull_request' }}"
novyj = "cancel-in-progress: false"
if s.count(staryj) != 1:
    print("MUTACIJA_NE_NAIDENA: cancel-строка встречена %d раз" % s.count(staryj), file=sys.stderr)
    sys.exit(1)
s = s.replace(staryj, novyj)
p.write_text(s, encoding="utf-8")
