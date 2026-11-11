#!/usr/bin/env python3
"""Стаб: блоки без строк происхождения/класса считаются НУЛЁМ (исчезают из счёта),
а не «не установлен». Дефект наблюдаем на мире E: у предмета 304 один блок без меток."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig = M.read_verdicts


def read_verdicts_drop_unmarked(repo):
    out = []
    for v in _orig(repo):
        if v['ishod'] == 'FAIL':
            v = dict(v)
            v['blocks'] = [b for b in v['blocks'] if b['origin'] or b['klass']]  # дефект
        out.append(v)
    return out


M.read_verdicts = read_verdicts_drop_unmarked
sys.exit(M.main(sys.argv[1:]))
