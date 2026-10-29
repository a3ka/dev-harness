#!/usr/bin/env python3
"""Стаб 145: неверная ось — listening раскрывает дугу в минус (g −= вместо +=).

Наблюдаем: s-ga-t29 (g уходит к 1.7 против оракула 13.7 — 12 ед.), p01."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "p.w += 6 * d; p.g += (em.symmetric ? 0 : 6) * d;"
zamena = "p.w += 6 * d; p.g -= (em.symmetric ? 0 : 6) * d;"
if jakor not in t:
    print('jakor ne najden: listening g', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
