#!/usr/bin/env python3
"""Стаб: хвост считается после ПЕРВОЙ правки, а не после последней.
Дефект наблюдаем на мире A: у Architect301a две правки, хвости различаются."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def measure_agent_first_edit(path):
    msgs = []
    for line in open(path, encoding='utf-8'):
        try:
            r = M.json.loads(line)
        except ValueError:
            continue
        if r.get('type') != 'message':
            continue
        m = r.get('message', {})
        if m.get('role') != 'assistant' or not isinstance(m.get('usage'), dict):
            continue
        u = m['usage']
        tok = int(u.get('totalTokens') or 0)
        tools = [c for c in m.get('content', []) if isinstance(c, dict) and c.get('type') == 'toolCall']
        is_edit = any(t.get('name') in ('edit', 'write') for t in tools)
        msgs.append((tok, len(tools) == 1, is_edit))
    first_edit = next((i for i, (_, _, ie) in enumerate(msgs) if ie), -1)  # дефект: первая
    tail = sum(t for t, _, _ in msgs[first_edit + 1:])
    return len(msgs), sum(t for t, _, _ in msgs), sum(1 for _, s, _ in msgs if s), tail


M.measure_agent = measure_agent_first_edit
sys.exit(M.main(sys.argv[1:]))
