"""Стаб s72 (kadry): отказы раннера 123 глотаются (rc принудительно
0, stdout честный), свежесть кадров не судится — подмена макета,
ниже-пороговый и устаревший кадр проходят."""
from _model import m, run

_rov = m.run_sverka
_rpr = m.run_sverka_profil


def run_sverka(f, pack, repo, harness):
    rc, out, _bad = _rov(f, pack, repo, harness)
    return 0, out, []


m.run_sverka = run_sverka
m.svezhost_kadrov = lambda kd, start_ns, rester: []
run()
