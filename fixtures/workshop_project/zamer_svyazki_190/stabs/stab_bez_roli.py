#!/usr/bin/env python3
"""Стаб: фильтр роль=critic у СУД-строк HANDOFF убран (мутация M1b ревьюера,
пережила батарею 22/22). Дефект наблюдаем на мире Q: СУД ревьюера несёт
кортеж вне вызовов критика (вызов=7/7) — создаётся лишний вызов-обрыв
(вызовы 301: 2 → 3, исход accept → обрыв). На мире A стаб честен: кортеж
ревьюера 1/1 совпадает с кортежем критика и поглощается дедупом."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def read_handoff_sud_bez_roli(repo):
    calls = {}
    handoff = repo / 'HANDOFF.md'
    if not handoff.is_file():
        return calls
    for line in M.lines_outside_fences(handoff.read_text(encoding='utf-8').splitlines()):
        fields = M.parse_sud_line(line.strip())
        if fields is None:
            continue  # дефект: поле роль= больше не фильтруется
        key = M.sud_call_key(fields)
        if key is None:
            continue
        calls.setdefault(key, {'verdict': None, 'n': key[2], 'seria': key[1]})
    return calls


M.read_handoff_sud = read_handoff_sud_bez_roli
sys.exit(M.main(sys.argv[1:]))
