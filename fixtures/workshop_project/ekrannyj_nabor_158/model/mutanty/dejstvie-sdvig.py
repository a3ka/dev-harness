#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f27-dejstvie-sdvig — каждая цель вызывает действие соседа — циклический сдвиг (класс 9).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = "onPress={() => { onCommandRef.current?.({ kind: id }); setMenu('closed'); }}"
ZAMENA = "onPress={() => { onCommandRef.current?.({ kind: ({ sprechen: 'schreiben', schreiben: 'foto', foto: 'dokument', dokument: 'sprechen' } as const)[id] }); setMenu('closed'); }}"

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
