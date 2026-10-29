#!/usr/bin/env python3
"""Стаб 145: округление — pose() округляет все числа до целых.

Дефект наблюдаем на клетках: p01-sostojanija-tiry (сетка против референса:
w=96 против 95.5 — рассинхрон больше 1e-9), p05-path-svg (path-строки
округлённой позы не совпадают с референсными байт-точно). На s-клетках
НЕ наблюдаем (0.5 < 1 ед. viewBox) — привязка их не касается (Н-39)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "    return p;\n  }\n  function pt(p, a, rho)"
zamena = ("    Object.keys(p).forEach(function (k) { if (typeof p[k] === 'number') p[k] = Math.round(p[k]); });\n"
          "    return p;\n  }\n  function pt(p, a, rho)")
if jakor not in t:
    print('jakor ne najden: return p/pt', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
