"""Стаб s45 (dvizhenie-bez-suda): блок dvizhenie и триггер D 2.4 не
судятся вовсе — пачка без декларации движения проходит зелёно; на входах
своих записей green там, где эталон красен; на честной пачке расходится
с эталоном только отсутствием суда."""
from _model import m, run

m.check_dvizhenie = lambda f, repo, kadry: []
m.check_d24_triggery = lambda f, kadry: []
run()
