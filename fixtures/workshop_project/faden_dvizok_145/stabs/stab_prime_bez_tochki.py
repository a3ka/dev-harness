#!/usr/bin/env python3
"""Стаб 145: prime без точки — удержание не растит точку (нет dotScale ×1.15).

Наблюдаем: p03-prime (сетка pose(prime) против референса + свойство
роста dotScale по prime нарушено)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'faden-motion.js'
t = p.read_text(encoding='utf-8')
jakor = "if (prime > 0) { p.w += 8 * prime; p.g += 4 * prime; p.dotScale *= 1 + 0.15 * prime; p.dotRho += 2 * prime; }"
zamena = "if (prime > 0) { p.w += 8 * prime; p.g += 4 * prime; p.dotRho += 2 * prime; }"
if jakor not in t:
    print('jakor ne najden: prime', file=sys.stderr); sys.exit(1)
p.write_text(t.replace(jakor, zamena, 1), encoding='utf-8')
