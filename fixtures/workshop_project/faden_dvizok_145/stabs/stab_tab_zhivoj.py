#!/usr/bin/env python3
"""Стаб 145: знак во вкладке живой — TIERS.tab.amp 0 → 1 (амплитуда двигает tab).

Наблюдаем: p04-tab (pose(tab, amplitude .9) против референса — точка
дышит; свойство «живые входы мертвы» нарушено), p11-katalog (TIERS)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "tab: { amp: 0, deform: 0, drift: 0, px: 28 }"
zamena = "tab: { amp: 1, deform: 0, drift: 0, px: 28 }"
if jakor not in t:
    print('jakor ne najden: TIERS.tab', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
