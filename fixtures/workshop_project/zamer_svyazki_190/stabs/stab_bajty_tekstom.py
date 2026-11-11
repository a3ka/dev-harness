#!/usr/bin/env python3
"""Стаб: журнал читается текстом в utf-8, а тип записи не проверяется —
неконсистентная строка ЛЮБОГО вида валит инструмент traceback'ом: rc 1
присваивается ложное имя ПУСТАЯ_ВЫБОРКА (инвариант 8 нарушен; форма Б-1
ревьюера — «падение с traceback»). Дефект наблюдаем на мире KA: обрыв
посреди многобайтового символа даёт UnicodeDecodeError вне try; на мирах
KB/KC — AttributeError/ValueError. На чистых журналах (K0/A) стаб честен:
декодирование корректных байтов и подсчёт записей не отличаются от эталона."""
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def measure_agent_text(path):
    msgs = []
    for line in open(path, encoding='utf-8'):  # дефект: декодирование вне try
        try:
            r = json.loads(line)
        except ValueError:
            continue
        if r.get('type') != 'message':  # дефект: тип записи не проверен
            continue
        m = r.get('message', {})
        if m.get('role') != 'assistant' or not isinstance(m.get('usage'), dict):
            continue
        u = m['usage']
        tok = int(u.get('totalTokens') or 0)
        tools = [c for c in m.get('content', []) if isinstance(c, dict) and c.get('type') == 'toolCall']
        is_edit = any(t.get('name') in ('edit', 'write') for t in tools)
        msgs.append((tok, len(tools) == 1, is_edit))
    last_edit = -1
    for i, (_, _, ie) in enumerate(msgs):
        if ie:
            last_edit = i
    tail = sum(t for t, _, _ in msgs[last_edit + 1:])
    return len(msgs), sum(t for t, _, _ in msgs), sum(1 for _, s, _ in msgs if s), tail


M.measure_agent = measure_agent_text
sys.exit(M.main(sys.argv[1:]))
