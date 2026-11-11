#!/usr/bin/env python3
"""Стаб: доля одиночных вызовов считается по ВСЕМ ролям, а не только architect.
Дефект наблюдаем на мире A: итоговая доля отличается от оракула."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig = M.journal_measures


def journal_measures_all_roles(files):
    agents, reviewed = _orig(files)
    arch = agents.get('architect')
    if arch is not None:
        for role, st in agents.items():
            if role == 'architect':
                continue
            arch['single'] += st['single']
            arch['calls'] += st['calls']
    return agents, reviewed


M.journal_measures = journal_measures_all_roles
sys.exit(M.main(sys.argv[1:]))
