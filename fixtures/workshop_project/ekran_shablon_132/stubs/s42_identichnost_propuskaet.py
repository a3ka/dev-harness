"""Стаб s42 (istoricheskij-id-chuzhie-makety): идентичность замороженного
экрана сужена до id — пины maket_sha256 манифеста пачки не судятся против
пинов замороженного манифеста (С-1 РЕШЕНИЯ АРБИТРА contracts-132-v2-
arbitraz, обход (а)): НОВАЯ пачка под историческим id с чужими макетами
проходит по v1 без блоков; на входе своей записи green там, где эталон
красен; id вне отображения и пачки с shablon судятся честно
(делегируется эталону — дефект наблюдаем ровно на историческом id)."""
from _model import m

_bez_izmenenij = m.check_starost


def _starost_bez_pinov(f, piny):
    if 'shablon' not in f and f['ekran'] in m.ZAMOROZHENNYE_STARYE_EKRANY:
        return []
    return _bez_izmenenij(f, piny)


m.check_starost = _starost_bez_pinov
run()
