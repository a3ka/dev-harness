#!/usr/bin/env python3
"""Стаб: ВСЕ строки «СУД: » вердикта считаются вызовами, включая цитаты чужих
СУД-строк внутри ```-блоков (учётная строка — первая вне цитат, инвариант 1).
Дефект наблюдаем на мире I: процитированная СУД (вызов=9) создаёт лишний вызов
предмета 301 (вызовы 2 → 3)."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig_collect = M.collect_calls


def collect_calls_count_quotes(repo):
    calls, unpinned = _orig_collect(repo)
    vdir = repo / 'verdicts' / 'critic'
    if vdir.is_dir():
        for f in sorted(vdir.glob('contracts-*.md')):
            for line in f.read_text(encoding='utf-8').splitlines():
                fields = M.parse_sud_line(line.strip())
                if fields is None:
                    continue
                key = M.sud_call_key(fields)
                if key is None:
                    continue
                calls.setdefault(key, {'verdict': None, 'n': key[2], 'seria': key[1]})  # дефект
    return calls, unpinned


M.collect_calls = collect_calls_count_quotes
sys.exit(M.main(sys.argv[1:]))
