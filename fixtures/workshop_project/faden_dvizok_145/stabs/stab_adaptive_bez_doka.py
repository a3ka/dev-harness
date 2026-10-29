#!/usr/bin/env python3
"""Стаб 145: адаптив без дока — правило «P − 64 < 96 → док» выброшено.

Наблюдаем: p07-adaptive (граничные случаи A=663.9/664.1: референс докает,
стаб нет; S/P/tier расходятся)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "var docked = !!o.docked || (Pfree - gap < min);"
zamena = "var docked = !!o.docked;"
if jakor not in t:
    print('jakor ne najden: adaptive docked', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
