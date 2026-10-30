"""Стаб s71 (B.8/A.5): files судятся только по теме dark (наличие и
непустоту) — недостающие/пустые светлые темы проходят; семьи
fajly-*-<tema> для чужих стабу тем ловят."""
from _model import m, run


def _tolko_dark(sc, pid, bad):
    fajly = sc.get('files')
    if not isinstance(fajly, dict):
        bad.append(m.otkaz('FAJLY_ETALONOV_NE_POLNY', pid))
        return
    for vid in ('video', 'keyframes'):
        d = fajly.get(vid)
        if not isinstance(d, dict) or 'dark' not in d:
            bad.append(m.otkaz('FAJLY_ETALONOV_NE_POLNY', pid))
            return
        if vid == 'video' and not (isinstance(d['dark'], str) and d['dark']):
            bad.append(m.otkaz('FAJLY_ETALONOV_NE_POLNY', pid))
            return
        if vid == 'keyframes' and not (isinstance(d['dark'], list)
                                       and d['dark']):
            bad.append(m.otkaz('FAJLY_ETALONOV_NE_POLNY', pid))
            return


m._proverka_sceny_fajly = _tolko_dark
run()
