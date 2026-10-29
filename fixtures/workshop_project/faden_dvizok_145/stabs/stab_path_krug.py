#!/usr/bin/env python3
"""Стаб 145: путь — полная окружность — path() игнорирует раскрытие w.

Наблюдаем: p05-path-svg (path-строки против референса), s-ga-t20
(5 именованных точек: PATH_RASKHODITSYA в каждой)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "var a0 = p.g - p.w / 2, a1 = p.g + p.w / 2, P0 = pt(p, a0), P1 = pt(p, a1);"
zamena = "var a0 = p.g - 180, a1 = p.g + 180, P0 = pt(p, a0), P1 = pt(p, a1);"
if jakor not in t:
    print('jakor ne najden: path a0/a1', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
