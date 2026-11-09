#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f13-zona-flex-20 — flexBasis:20, paddingHorizontal:0 в ряду вкладок (Crit148k2e-3).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса>. Код возврата 0 — замена применена;
2 — якорь не найден ровно один раз (мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = '  tab: {\n    paddingHorizontal: 12,\n    paddingVertical: 6,\n    minHeight: navZiel,\n    minWidth: ziel,\n  },'
ZAMENA = '  tab: {\n    paddingVertical: 6,\n    minHeight: navZiel,\n    flexBasis: 20,\n  },'

if __name__ == '__main__':
    sys.exit(primenit(sys.argv[1], FAJL, YAKOR, ZAMENA))
