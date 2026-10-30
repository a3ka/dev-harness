"""Стаб s74 (B.8/A.2): ∩-полнота считается только по ПЕРВОМУ кадру
каждого перехода манифеста — переход, касающийся пачки вторым кадром
(GA-T36: frames [GA-34, GA-16]), не требуется; семья
perehody-ne-polny-ga-t36 ловит. Пин манифеста проверяется ДО усечения."""
from _model import m, run

_staryj = m.zagnost_istochniki


def _pervymi_kadrami(dv, repo):
    bad, isto = _staryj(dv, repo)
    if isto is not None:
        for x in isto['manifest']['motion']:
            x['frames'] = x['frames'][:1]
    return bad, isto


m.zagnost_istochniki = _pervymi_kadrami
run()
