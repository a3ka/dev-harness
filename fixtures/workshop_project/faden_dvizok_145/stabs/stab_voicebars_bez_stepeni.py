#!/usr/bin/env python3
"""Стаб 145: полосы без подъёма — voiceBars без степени ^0.8 (сырой max).

Наблюдаем: p08-voicebars (тихая речь: 0.5^0.8=0.574 против 0.5 —
расхождение с референсом на записанных и синтетических окнах)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "out.push(end <= 0 ? 0 : Math.round(Math.pow(clamp(m, 0, 1), 0.8) * 1000) / 1000);"
zamena = "out.push(end <= 0 ? 0 : Math.round(clamp(m, 0, 1) * 1000) / 1000);"
if jakor not in t:
    print('jakor ne najden: voiceBars push', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
