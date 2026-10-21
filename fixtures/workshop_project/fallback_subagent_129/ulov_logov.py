#!/usr/bin/env python3
"""Ловец остаточного риска контракта 129: смерти субагентов на исчерпании в живых логах omp.

usage: ulov_logov.py <каталог логов omp, напр. $HOME/.omp/profiles/dev/logs>

Событие — строка «agent turn ended with provider error» с errorStatus 429 и ожиданием
retry-after-ms > 300000 (исчерпание, инвариант 1). Исход события — первая из следующих
строк того же лога: «agent.continue scheduled» (omp продолжил: переход) либо
«subagent launch timing» / новая «provider error» (ход закрыт без продолжения: смерть).
Печатает строку на событие и итог «events=N recovered=R died=D»; рядом с каждой смертью —
секунды с последнего хода другого провайдера, оборванного «aborted» (причина 2026-10-21).
Код: 0 — смертей нет; 1 — есть смерти; 2 — нечего судить (нет логов или нет событий).
"""
import glob
import json
import os
import re
import sys
from datetime import datetime

NEXT = ('agent.continue scheduled', 'subagent launch timing', 'agent turn ended with provider error')


def main(argv):
    if len(argv) != 1 or not os.path.isdir(argv[0]):
        print('usage: ulov_logov.py <каталог логов omp>', file=sys.stderr)
        return 2
    events = died = 0
    for path in sorted(glob.glob(os.path.join(argv[0], '*.log'))):
        rows = []
        for line in open(path, errors='replace'):
            try:
                rows.append(json.loads(line))
            except ValueError:
                continue
        last_abort = {}
        for i, o in enumerate(rows):
            if o.get('message') != 'agent turn ended with provider error':
                continue
            msg = str(o.get('errorMessage', ''))
            if msg == 'aborted':
                last_abort[o.get('provider')] = datetime.fromisoformat(o['timestamp'])
                continue
            wait = re.search(r'retry-after-ms=(\d+)', msg)
            if o.get('errorStatus') != 429 or not wait or int(wait.group(1)) <= 300000:
                continue
            events += 1
            nxt = next((r for r in rows[i + 1:] if r.get('message') in NEXT), {})
            ok = nxt.get('message') == 'agent.continue scheduled'
            t = datetime.fromisoformat(o['timestamp'])
            since = min(((t - a).total_seconds() for p, a in last_abort.items() if p != o.get('provider')), default=None)
            if not ok:
                died += 1
            print('%s %s %s/%s %s since_other_abort_s=%s' % (
                os.path.basename(path), o['timestamp'][11:19], o.get('provider'), o.get('model'),
                'recovered' if ok else 'DIED', None if since is None else round(since, 1)))
    print('events=%d recovered=%d died=%d' % (events, events - died, died))
    if events == 0:
        return 2
    return 1 if died else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
