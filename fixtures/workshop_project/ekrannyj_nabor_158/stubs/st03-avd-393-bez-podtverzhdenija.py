#!/usr/bin/env python3
"""Стаб st03-avd-393-bez-podtverzhdenija (SPEC §7): двойник запускает 393
при ЖИВОМ 390 (подтверждение ухода пропущено).

Ожидается пойманным на клетках b02-zalipshij-390 и b07-mutant-393-pri-390:
наблюдение состояния песочницы (393 не запущен) не держится — исход стаба
расходится с эталонным.

Дефект вшит в шов probe.zapustit_dvoinik: стаб запускает СВОЙ двойник
(stubs/st03-dvoinik-bez-podtverzhdenija.sh) вместо эталона (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

SVOY_DVOINIK = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                            'st03-dvoinik-bez-podtverzhdenija.sh')


def zapustit_dvoinik_bez_podtverzhdenija(skript, sekretar, env=None):
    """ДЕФЕКТ: канон без подтверждения ухода 390."""
    return probe.zapusk_komandy(['bash', SVOY_DVOINIK], cwd=os.path.dirname(
        SVOY_DVOINIK), env=dict(env or {}, FAKE_ADB_STATE=sekretar,
                                 PORT_390=probe.PORTY['390'],
                                 PORT_393=probe.PORTY['393']), timeout=120)


probe.zapustit_dvoinik = zapustit_dvoinik_bez_podtverzhdenija

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
