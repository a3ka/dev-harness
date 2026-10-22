"""Стаб s33 (bez-KADR-pechati): строки KADR <кадр> <score> <porog> не
печатаются наружу — приёмочный критерий 16 KADR 1.000 0.600 не наблюдаем
(дефект наблюдаем на честном входе chestnyj-ekran, чей stdout несёт KADR)."""
from _model import m, run

_isxodnyj = m.run_sverka


def _bez_kadr(f, pack, repo, harness):
    rc, out, bad = _isxodnyj(f, pack, repo, harness)
    return rc, '\n'.join(l for l in out.splitlines()
                          if not l.startswith('KADR')), bad


m.run_sverka = _bez_kadr
run()
