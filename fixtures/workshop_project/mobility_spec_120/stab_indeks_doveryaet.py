#!/usr/bin/env python3
# Обманный оракул: честный оракул 120 с ОДНОЙ выключенной функцией — skrytye_indeksom
# (верит флагам assume-unchanged/skip-worktree, как `git diff <base>`). Батарея обязана
# поймать его на d45, d46 (таблица STABS раннера) и НЕ ловить на d05 той же причины:
# дефект наблюдаем только на ветви флаговых записей индекса.
import importlib.util
import os
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)
O.skrytye_indeksom = lambda repo, spec_pre: []
sys.exit(O.main(sys.argv[1:]))
