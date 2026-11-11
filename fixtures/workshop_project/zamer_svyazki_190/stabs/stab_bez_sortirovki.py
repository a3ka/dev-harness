#!/usr/bin/env python3
"""Стаб: сортировка строк по номеру предмета снята — строки печатаются в обратном
порядке (инвариант 7: сортировка по номеру, возрастающе).
Дефект наблюдаем на мире A: порядок 303/302/301 против оракула."""
import io
import os
import sys
from contextlib import redirect_stdout

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig_build = M.build_table


def build_table_reversed(repo, zhurnaly, since, until, predmety):
    buf = io.StringIO()
    with redirect_stdout(buf):
        rc = _orig_build(repo, zhurnaly, since, until, predmety)
    lines = buf.getvalue().splitlines()
    if rc == 0 and lines:
        header, rows = lines[0], lines[1:]
        body = [r for r in rows if not (r.startswith('ИТОГО\t') or r.startswith('МЕР\t'))]
        tail = [r for r in rows if r.startswith('ИТОГО\t') or r.startswith('МЕР\t')]
        key = lambda r: -int(r.split('\t', 1)[0])
        lines = [header] + sorted(body, key=key) + tail  # дефект: обратный порядок
    print('\n'.join(lines))
    return rc


M.build_table = build_table_reversed
sys.exit(M.main(sys.argv[1:]))
