#!/usr/bin/env python3
"""Стаб 145: сдвиг тайминга морфа — motion-morph 450 → 600 мс.

Наблюдаем: p06-morph (морф с длительностью по умолчанию: середина
движется не там), p11-katalog (каталог TIMING.morph)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "morph: 450, morphEase: 'cubic-bezier(0.32, 0.72, 0, 1)'"
zamena = "morph: 600, morphEase: 'cubic-bezier(0.32, 0.72, 0, 1)'"
if jakor not in t:
    print('jakor ne najden: morph timing', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
