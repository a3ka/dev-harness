"""Стаб: отказ без имени кадра — причина есть, какой кадр — нет."""
import sys

from _model import m, run

m.report = lambda reason, ident, detail='': print(f'{reason}\t-\t{detail}', file=sys.stderr)
run()
