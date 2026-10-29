"""Стаб s66 (B.8 арбитража 146): механика (кривые+пружины) судится
только у ПЕРВОГО трека каждой сцены (gde == pid:1) — мутант арбитра
«i == 0 в _proverka_mekhaniki», пойманный поведением на семьях
«все треки разом»: ожидание — полный набор причин на каждом треке,
стаб выдаёт только pid:1 → расхождение множеств."""
from _model import m, run

_staryj = m._proverka_mekhaniki


def _tolko_pervyj(t, tk, gde, bad):
    if gde.split(':')[-1] == '1':
        _staryj(t, tk, gde, bad)


m._proverka_mekhaniki = _tolko_pervyj
run()
