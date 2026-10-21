#!/usr/bin/env python3
# Обманный оракул: честный оракул 120 с ОДНОЙ подменённой функцией — graf_vneshnie
# (только EXTERNAL ⊆ пин, покрытие внешних зависимостей плана 119 не требуется). Батарея
# обязана поймать его на d49 (таблица STABS раннера) и НЕ ловить на d40 той же причины:
# дефект наблюдаем только на ветви покрытия внешних узлов.
import importlib.util
import os
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)
O.graf_vneshnie = lambda ext_nodes, pin_ext: O.need(ext_nodes <= set(pin_ext), "graf-nepolny", "внешние вне плана 119")
sys.exit(O.main(sys.argv[1:]))
