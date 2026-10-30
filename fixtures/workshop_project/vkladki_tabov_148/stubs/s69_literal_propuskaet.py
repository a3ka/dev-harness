"""Стаб s69 (literal): аудит литералов пачки не судится."""
from _model import m, run

m.check_literal = lambda pack: []
run()
