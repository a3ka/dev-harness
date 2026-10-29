"""Стаб s62 (priemka-forma): форма команды приёмки движения не требует
--json/--outputFile — «исполнена» без отчёта."""
from _model import m, run

m._forma_priemki_dvizhenija = lambda dv: (
    dv['priemka_dvizhenija'].split(' '), 'mobile/dvizhenie-otchet.json')
run()
