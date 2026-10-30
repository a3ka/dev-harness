"""Стаб s65 (grammatika-odin-perehod): грамматика спеки судится только
по ПЕРВОМУ объявленному переходу (сортированным порядком суда) — пружины
и кривые в остальных объявленных сценах проходят незамеченными. Класс
обхода круга критика 1 («литерал на месте, исполняемое иное»): без
литерала pid — судится ровно один переход, какой бы ни был объявлен.
Наблюдаем на входе pruzhina-vo-vseh-perehodah (пружина в КАЖДОМ
объявленном переходе: эталон отказывает по всем, стаб — только по
первому); привязка seed-инвариантна — наблюдаема при любом --seed."""
from _model import m, run

_staryj = m._grammatika_sceny
_pervyj = [True]


def _grammatika_tolko_pervogo(sc, tk, pid):
    if _pervyj[0]:
        _pervyj[0] = False
        return _staryj(sc, tk, pid)
    return []


m._grammatika_sceny = _grammatika_tolko_pervogo
run()
