#!/usr/bin/env python3
"""Стаб: число просмотренного не печатается — stderr при rc 0 пуст, хотя
инвариант 8 обязывает обход печатать «просмотрено: записей_журналов=N».
Дефект наблюдаем на мире A: stderr не несёт строки просмотренного."""
import io
import os
import sys
from contextlib import redirect_stderr

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig_build = M.build_table


def build_table_quiet(repo, zhurnaly, since, until, predmety):
    err = io.StringIO()
    with redirect_stderr(err):
        rc = _orig_build(repo, zhurnaly, since, until, predmety)
    for line in err.getvalue().splitlines():
        if 'просмотрено' not in line:  # дефект: число просмотренного молчит
            print(line, file=sys.stderr)
    return rc


M.build_table = build_table_quiet
sys.exit(M.main(sys.argv[1:]))
