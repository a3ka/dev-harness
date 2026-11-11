#!/usr/bin/env python3
"""Стаб: «ноль» вместо «не установлен» — вердикт без СУД-строки молча отбрасывается,
счёт предмета печатается нулём. Дефект наблюдаем на мире A (предмет 303)."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def collect_calls_drop_unpinned(repo):
    calls = M.read_handoff_sud(repo)
    for v in M.read_verdicts(repo):
        if v['sud'] is None:
            continue  # дефект: неприписанный вердикт исчезает
        key = M.sud_call_key(v['sud'])
        if key is None:
            continue
        entry = calls.setdefault(key, {'verdict': None, 'n': key[2], 'seria': key[1]})
        if entry['verdict'] is None and v['ishod'] in ('FAIL', 'accept'):
            entry['verdict'] = {'ishod': v['ishod'], 'blocks': v['blocks']}
    return calls, set()


M.collect_calls = collect_calls_drop_unpinned
sys.exit(M.main(sys.argv[1:]))
