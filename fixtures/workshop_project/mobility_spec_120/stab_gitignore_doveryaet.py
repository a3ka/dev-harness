#!/usr/bin/env python3
# Обманный оракул: честный оракул 120 с ОДНОЙ выключенной функцией — gitignore_neotslezhivaemye
# (верит неотслеживаемым .gitignore дерева). Батарея обязана поймать его на d51 (таблица STABS
# раннера) и НЕ ловить на d50 той же причины: локальный exclude ловит соседняя ветвь.
import importlib.util
import os
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)
O.gitignore_neotslezhivaemye = lambda repo, spec_pre: []
sys.exit(O.main(sys.argv[1:]))
