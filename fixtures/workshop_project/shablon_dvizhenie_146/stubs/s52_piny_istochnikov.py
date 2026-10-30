"""Стаб s52 (piny-istochnikov): пины sha256 источников не сверяются с
байтами репо — пачка лжёт об источнике движения."""
import json

from _model import m, run


def _novyj(dv, repo):
    isto = {}
    for imja in ('manifest', 'spec', 'pozvonok'):
        p = repo / dv[imja]
        if not p.is_file():
            return ([m.otkaz('ISTOCHNIK_OTSVTSTVUET', dv[imja])], None)
        isto[imja] = json.loads(p.read_text(encoding='utf-8'))
    return [], isto


m.zagnost_istochniki = _novyj
run()
