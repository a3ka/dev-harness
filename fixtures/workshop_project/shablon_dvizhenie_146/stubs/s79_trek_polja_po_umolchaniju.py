"""Стаб s79 (Crit146c-3): обязательные поля трека имеют «умолчания» —
физическое удаление любого поля молча восполняется производным
значением (мутант критика omitted_reduced_duration_default, обобщённый
на все поля POLJA_TREKA). Семьи pole-treka-udaleno-<pole> ловят
на каждом поле; на честных входах восполнять нечего — ведёт себя
честно."""
from _model import m, run

_staryj = m._grammatika_sceny


def _s_umolchanijami(sc, tk, pid):
    treki = sc.get('tracks')
    if isinstance(treki, list):
        for i, t in enumerate(treki):
            if not isinstance(t, dict):
                continue
            zamenil_vremja = False
            if 'duration' not in t:
                t['duration'] = {'token': '0', 'ms': 0}
                zamenil_vremja = True
            if 'delay' not in t:
                t['delay'] = {'token': '0', 'ms': 0}
                zamenil_vremja = True
            if 'order' not in t:
                t['order'] = i + 1
            if 'element' not in t:
                t['element'] = 'prachee'
            if 'property' not in t:
                t['property'] = 'opacity'
            if 'end_ms' not in t:
                t['end_ms'] = float(t['delay']['ms']) + \
                    float(t['duration']['ms'])
            elif zamenil_vremja:
                t['end_ms'] = float(t['delay']['ms']) + \
                    float(t['duration']['ms'])
            if 'curve' not in t:
                t['curve'] = {'token': 'linear', 'value': None}
            if 'spring' not in t:
                t['spring'] = None
            if 'reduced_duration_ms' not in t:
                t['reduced_duration_ms'] = 0
    return _staryj(sc, tk, pid)


m._grammatika_sceny = _s_umolchanijami
run()
