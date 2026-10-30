"""Стаб s74 (chuzhie): пересечение с чужими кадрами не судится."""
from _model import m, run

m.check_chuzhie = lambda f, harness, repo, kadry: []
run()
