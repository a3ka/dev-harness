"""Стаб s78 (Crit146c-2): у объявленного перехода без сцены спеки
молча подставляется ПЕРВАЯ существующая сцена (PEREHOD_BEZ_SPECY не
звучит, грамматика судит чужую честную сцену) — мутант критика
missing_scene_fallback. Клетки perehod-bez-specy-<pid> ловят подмену
на КАЖДОМ объявленном переходе."""
import copy

from _model import m, run

_staryj = m.zagnost_istochniki


def _s_podmenoj(dv, repo):
    bad, isto = _staryj(dv, repo)
    if isto is not None and isto.get('spec') is not None:
        sceny = isto['spec'].get('scenes')
        if isinstance(sceny, list) and sceny:
            est = {s['id'] for s in sceny
                   if isinstance(s, dict) and isinstance(s.get('id'), str)}
            perehody = dv.get('perehody') if isinstance(dv, dict) else None
            for p in (perehody or []):
                if isinstance(p, str) and p not in est:
                    kandidat = next((s for s in sceny
                                     if isinstance(s, dict) and 'id' in s),
                                    None)
                    if kandidat is None:
                        break
                    zamen = copy.deepcopy(kandidat)
                    zamen['id'] = p
                    sceny.append(zamen)
    return bad, isto


m.zagnost_istochniki = _s_podmenoj
run()
