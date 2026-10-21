#!/usr/bin/env python3
# Обманный оракул: честный оракул 120 с ОДНОЙ выключенной функцией — wunsch_tipizirovany
# (любая операция пина годится в lifecycle, одна операция может нести два вида). Батарея
# обязана поймать его на d47, d48 (таблица STABS раннера) и НЕ ловить на d22 той же причины:
# дефект наблюдаем только на ветви типизации операций lifecycle.
import importlib.util
import os
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)
O.wunsch_tipizirovany = lambda wops, new_ops, kinds_req: None
sys.exit(O.main(sys.argv[1:]))
