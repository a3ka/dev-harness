#!/usr/bin/env python3
"""Стаб: окно сессий игнорируется — считаются журналы и за пределами --s/--do.
Дефект наблюдаем на мире A с окном от 01:30: Architect301a (сессия 01:00) не должен считаться."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

M.iter_journals = lambda root, since, until: (M.Path(root).is_dir() or None) and \
    [(f, M.role_of(f.stem), M.subject_of(f.stem))
     for d1 in sorted(M.Path(root).iterdir()) if d1.is_dir()
     for d2 in sorted(d1.iterdir()) if d2.is_dir()
     for f in sorted(d2.glob('*.jsonl'))]
sys.exit(M.main(sys.argv[1:]))
