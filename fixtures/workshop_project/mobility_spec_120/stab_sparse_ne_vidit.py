#!/usr/bin/env python3
# Обманный оракул: честный оракул 120 с ОДНОЙ выключенной функцией — sparse_checkout
# (не различает sparse-клон: честное содержимое вне конуса судит как стёртое, rc 1 vne-zony).
# Батарея обязана поймать его на d52 (таблица STABS раннера) и НЕ ловить на d46, где
# skip-worktree без sparse-checkout — честная краснота.
import importlib.util
import os
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)
O.sparse_checkout = lambda repo: False
sys.exit(O.main(sys.argv[1:]))
