"""Стаб: алфавит id верный, но якорь «$» — хвостовой перевод строки проходит."""
import re

from _model import m, run

m.ID_RE = re.compile(r'^[A-Za-z0-9._-]+( [A-Za-z0-9._-]+)*$')
run()
