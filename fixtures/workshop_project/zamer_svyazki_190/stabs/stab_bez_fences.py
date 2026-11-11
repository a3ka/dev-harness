#!/usr/bin/env python3
"""Стаб: переключатель fence убран — строки внутри ```-блоков читаются как
учётные (мутация M5 ревьюера, пережила батарею 22/22). Дефект наблюдаем на
мире P: fenced-цитата чужой СУД стоит в вердикте ДО учётной строки — ключ
9/2 получает вердикт (исход 301 уходит в FAIL), fenced СУД 302 в HANDOFF
создаёт лишний вызов-обрыв (вызовы 302: 4 → 5). На мире I (цитата ПОСЛЕ
учётной) стаб честен: первая СУД-строка та же, что у эталона."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def lines_bez_fences(lines):  # дефект: fence не переключается
    return [l for l in lines if not l.startswith('```')]


M.lines_outside_fences = lines_bez_fences
sys.exit(M.main(sys.argv[1:]))
