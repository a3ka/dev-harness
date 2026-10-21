"""Стаб: поля манифеста без замкнутого алфавита — id/snimok/imja принимаются любыми."""
import re

from _model import m, run

m.ID_RE = re.compile(r'.+', re.S)
m.SHOT_RE = re.compile(r'.+', re.S)
m.ELEM_RE = re.compile(r'.+', re.S)
run()
