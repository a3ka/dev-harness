"""Стаб s02 (sverka-doverjaet): раннер 123 не зовётся, кадры «зелёные» 0.900."""
from _model import m, run


def _fake(f, pack, repo, harness):
    kadry = m.read_json(pack / f['kadry'])
    lines = ['KADR\t%s\t0.900\t%.3f\tG\tOK' % (e['id'], e['porog'])
             for e in kadry['kadry']]
    return 0, '\n'.join(lines) + '\n', []


m.run_sverka = _fake
run()
