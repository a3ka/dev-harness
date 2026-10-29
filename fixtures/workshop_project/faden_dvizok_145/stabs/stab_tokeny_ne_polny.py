#!/usr/bin/env python3
"""Стаб 145: неполные токены — в theme-модуле 29 токенов вместо 31 и
одиночное значение изменено (motion-base 250 → 300 мс).

Наблюдаем: t01-tokemy (NET_TOKENA motion-none/motion-stagger +
ZNACHENIE_TOKENA motion-base)."""
import sys, pathlib
cel = pathlib.Path(sys.argv[1])
p = cel / 'motion-tokens.ts'
t = p.read_text(encoding='utf-8')
udalit1 = '  "motion-none": "0ms",\n'
udalit2 = '  "motion-stagger": "60ms",\n'
izmenit = ('  "motion-base": "250ms",', '  "motion-base": "300ms",')
if udalit1 not in t or udalit2 not in t or izmenit[0] not in t:
    print('jakor ne najden: tokeny', file=sys.stderr); sys.exit(1)
t = t.replace(udalit1, '', 1).replace(udalit2, '', 1).replace(izmenit[0], izmenit[1], 1)
p.write_text(t, encoding='utf-8')
