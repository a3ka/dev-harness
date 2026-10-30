"""Стаб s70 (B.8/A.5): ключевые кадры судятся только по 25 % (и окну) —
семьи kadr-<p>-neverno-vse-sceny для p != 25 ловят пропуск."""
from _model import m, run


def _tolko_25(sc, pid, bad):
    w = sc.get('window_ms')
    if not (isinstance(w, list) and len(w) == 2
            and all(isinstance(x, (int, float)) for x in w)):
        bad.append(m.otkaz('TREK_BEZ_POLJA', pid + ': window_ms'))
        return
    kf = sc.get('keyframes_ms')
    if not (isinstance(kf, dict) and '25' in kf
            and isinstance(kf['25'], (int, float))):
        bad.append(m.otkaz('KLJUCHEVYE_KADRY_NE_RAVNY', pid))
        return
    if abs(float(kf['25']) - float(w[1]) * 0.25) > 1e-9:
        bad.append(m.otkaz('KLJUCHEVYE_KADRY_NE_RAVNY', pid + ': 25%'))


m._proverka_sceny_kadry = _tolko_25
run()
