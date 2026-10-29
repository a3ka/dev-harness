"""Стаб s48 (jakorja-ga): GA-якорь id кадра не распознаётся — экраны
D 2.4 не выявляются ни триггером, ни полнотой ekrany."""
import re

from _model import m, run

m.RE_GA_JAKOR = re.compile(r'\A(?!x)x')
run()
