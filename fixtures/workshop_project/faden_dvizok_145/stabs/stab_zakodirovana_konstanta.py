#!/usr/bin/env python3
"""Стаб 145: поза — зашитая константа (pose всегда возвращает CANON).

Дефект наблюдаем на клетках: s-ga-t29 (строки: w стоит на 95.5 против
оракула 101.5, отклонение 6 > 1 ед. viewBox), p01-sostojanija-tiry
(сетка против референса: тона/значения состояний ждания/ошибки иное)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "    return p;\n  }\n  function pt(p, a, rho)"
zamenа = "    return CANON;\n  }\n  function pt(p, a, rho)"
if jakor not in t:
    print('jakor ne najden: return p/pt', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamenа, 1), encoding='utf-8')
