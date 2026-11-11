#!/usr/bin/env python3
"""Стаб: правая граница окна снята — --do молча игнорируется, --s работает
(инвариант 6). Дефект наблюдаем на мире A с --do 2026-11-10T01:30:00Z:
сессия 02:00 обязана выпасть и не выпадает."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig_iter = M.iter_journals
M.iter_journals = lambda root, since, until: _orig_iter(root, since, None)  # дефект: until исчез
sys.exit(M.main(sys.argv[1:]))
