#!/usr/bin/env python3
"""Стаб st07-polnyj-bez-ispolnenija (SPEC §7): раннер --ekran корректно читает
ТРЕК, но слой polnyj_trek/ НЕ ЗАПУСКАЕТ — только ядро.

Ожидается пойманным на клетках a10-sloj-ispolnen-v-polnom, a06-pereklyuchenie
и a11-sloj-krasen: трасса sled пуста при ТРЕК: ПОЛНЫЙ (вместо успеха — красный
исход), красная команда слоя не попадает в общий итог.

Дефект вшит в шов probe.zapustit_sloi (кодом, Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402


def sloi_ne_ispolnyaetsya(paket):
    """ДЕФЕКТ: команды слоя полного трека не запускаются."""
    return [], []


probe.zapustit_sloi = sloi_ne_ispolnyaetsya

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
