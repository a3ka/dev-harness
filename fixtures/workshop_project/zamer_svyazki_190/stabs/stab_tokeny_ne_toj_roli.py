#!/usr/bin/env python3
"""Стаб: подсчёт токенов не той роли — reviewer тоже считается architect.
Дефект наблюдаем на мире A: токены architect предмета 301 вырастут на 9999."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig_iter = M.iter_journals


def iter_journals_misrole(root, since, until):
    files = _orig_iter(root, since, until)
    return [(f, 'architect' if role == 'reviewer' else role, subj) for f, role, subj in files]


M.iter_journals = iter_journals_misrole
sys.exit(M.main(sys.argv[1:]))
