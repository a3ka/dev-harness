#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f04 — обязательная цель карты
NNN (195) выключена (disabled) В ЖИВОМ РЕФЕРЕНСЕ.

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса. testID
цели — КОНСТАНТА probe.py (KARTA_195_TSEL): раннер и мутатор читают одно и то
же имя; номер экрана и имя цели не зашиты в стаб.

CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import importlib.util
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

ZDE = os.path.dirname(os.path.dirname(os.path.dirname(
    os.path.abspath(__file__))))
_spec = importlib.util.spec_from_file_location('probe158',
                                               os.path.join(ZDE, 'probe.py'))
probe = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(probe)

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
# Идентификатор пункта меню выводится из testID цели (testID — константа
# probe.py; в разметке пункт называется коротким id).
PUNKT = probe.KARTA_195_TSEL.rsplit('-', 1)[-1]
YAKOR = ('                    <Pressable key={id} testID={`gespraech-menu-${id}`}\n'
         '                      onPress={() => { onCommandRef.current?.({ kind: id }); '
         "setMenu('closed'); }}")
ZAMENA = ('                    <Pressable key={id} testID={`gespraech-menu-${id}`}\n'
          '                      disabled={id === \'%s\'}\n'
          '                      onPress={() => { onCommandRef.current?.({ kind: id }); '
          "setMenu('closed'); }}" % PUNKT)

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
