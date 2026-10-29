#!/usr/bin/env python3
"""Стаб 145: дрейф сглаживания — faden-transition 320 → 640 мс.

Наблюдаем: s-ga-t35 (переход после t=500 идёт вдвое медленнее — строки
расходятся > 1 ед. в середине перехода), p12-instance-sglazhivanie
(микрореплей атаки/спада против референса), p11-katalog (каталог TIMING)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "transition: 320, ease: 'cubic-bezier(0.2, 0.7, 0.2, 1)',"
zamena = "transition: 640, ease: 'cubic-bezier(0.2, 0.7, 0.2, 1)',"
if jakor not in t:
    print('jakor ne najden: transition', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
