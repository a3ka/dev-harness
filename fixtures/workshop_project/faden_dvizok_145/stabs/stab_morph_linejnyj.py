#!/usr/bin/env python3
"""Стаб 145: линейный морф — ease-morph заменён тождественным k=u.

Наблюдаем: p06-morph (середина морфа: бокс по линейному t против
кривой 0.32/0.72/0/1 — расхождение в средней точке до ~0.15 доли)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "var dur = o.duration == null ? TIMING.morph : o.duration, u = o.reducedMotion || dur <= 0 ? 1 : clamp((t - (o.delay || 0)) / dur, 0, 1), k = EASE_MORPH(u);"
zamena = jakor.replace("k = EASE_MORPH(u)", "k = u")
if jakor not in t:
    print('jakor ne najden: morph k', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
