#!/usr/bin/env python3
"""Стаб st02-trek-udaljaet-sloj (SPEC §7): перевод в ЛЁГКИЙ УДАЛЯЕТ файлы
слоя полного трека (polnyj_trek/).

Ожидается пойманным на клетке a06-pereklyuchenie: после переключения целость
артефактов слоя нарушена — наблюдение в клетке (файлы слоя) расходится с
эталонным исходом.

Дефект вшит в шов probe.peropisyat_kontrakt (кодом, Н-39).
"""
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

_real_peropisyat = probe.peropisyat_kontrakt


def peropisyat_udalyaet_sloj(toy_root, nomer, **kwargs):
    """ДЕФЕКТ: при переводе в ЛЁГКИЙ файлы слоя удаляются."""
    put = _real_peropisyat(toy_root, nomer, **kwargs)
    if kwargs.get('trek') == probe.TREK_LEGKIJ:
        shutil.rmtree(os.path.join(toy_root, 'pachki', str(nomer),
                                   'polnyj_trek'), ignore_errors=True)
    return put


probe.peropisyat_kontrakt = peropisyat_udalyaet_sloj

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
