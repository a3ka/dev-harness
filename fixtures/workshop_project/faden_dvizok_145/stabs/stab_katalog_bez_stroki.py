#!/usr/bin/env python3
"""Стаб 145: каталог без строки — LABEL.done пустая («Erledigt.» выброшена).

Наблюдаем: p11-katalog (каталог LABEL против референса)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "done: 'Erledigt.'"
zamena = "done: ''"
if jakor not in t:
    print('jakor ne najden: LABEL.done', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
