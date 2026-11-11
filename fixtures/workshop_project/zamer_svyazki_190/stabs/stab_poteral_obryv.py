#!/usr/bin/env python3
"""Стаб: потеря обрыва — СУД-строки HANDOFF не читаются, вызов без вердикта выпадает.
Дефект наблюдаем на мире A: у 302 вызовов 4 (включая обрыв), стаб насчитает 3."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

M.read_handoff_sud = lambda repo: {}
sys.exit(M.main(sys.argv[1:]))
