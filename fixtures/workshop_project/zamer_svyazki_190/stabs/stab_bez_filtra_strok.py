#!/usr/bin/env python3
"""Стаб: фильтр строк таблицы по реестру снят — предмет 999 вне реестра (его СУД
живёт в HANDOFF мира) получает строку при неизменных агрегатах ИТОГО/МЕР.
Дефект наблюдаем на мире A: лишняя строка 999 против инварианта 7."""
import io
import os
import sys
from contextlib import redirect_stdout

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig_build = M.build_table


def build_table_no_filter(repo, zhurnaly, since, until, predmety):
    buf = io.StringIO()
    with redirect_stdout(buf):
        rc = _orig_build(repo, zhurnaly, since, until, predmety)
    lines = buf.getvalue().splitlines()
    if rc == 0 and len(lines) > 3:
        extra = '999\t1\t0\t0\t1\tобрыв\t0\t0\t0\t0\t0\t0\t0\t-\t0\t0\t0\t0\t0\t0.0%\t0.0%'
        lines.insert(len(lines) - 2, extra)  # дефект: строка предмета вне реестра
    print('\n'.join(lines))
    return rc


M.build_table = build_table_no_filter
sys.exit(M.main(sys.argv[1:]))
