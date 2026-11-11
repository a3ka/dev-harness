#!/usr/bin/env python3
"""Стаб: вызовы критика считаются по ЧИСЛУ ФАЙЛОВ вердиктов (без HANDOFF, без дедупа).
Дефект наблюдаем на мире B: у 302 четыре файла (дубль-материализация) при трёх вызовах."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def collect_calls_by_files(repo):
    calls = {}
    unpinned = set()
    for v in M.read_verdicts(repo):
        key = (v['subject'], '', len(calls) + 1)  # каждый файл — свой вызов
        entry = {'verdict': None, 'n': key[2], 'seria': ''}
        if v['ishod'] in ('FAIL', 'accept'):
            entry['verdict'] = {'ishod': v['ishod'], 'blocks': v['blocks']}
        calls[(v['subject'], 'f%d' % len(calls), key[2])] = entry
    return calls, unpinned


M.collect_calls = collect_calls_by_files
sys.exit(M.main(sys.argv[1:]))
