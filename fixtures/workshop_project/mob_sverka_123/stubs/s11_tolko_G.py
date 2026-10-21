"""Стаб: только общая похожесть поля G — поэлементного минимума нет."""
from _model import m, run

m.element_scores = lambda fb, mb, mask, k, mera: []
run()
