#!/usr/bin/env python3
"""232 reference: installation policy, exact Git blob identity, deterministic map."""
import json
from pathlib import Path
import re
import subprocess
import sys

HOME = Path(__file__).resolve().parents[1]
POLICY = HOME / 'registry/karta-exceptions.json'
SCHEMA = HOME / 'registry/karta-exceptions.schema.json'


def fail(why):
    print('KARTA_REGISTRY_INVALID: ' + why)
    raise SystemExit(1)


def git(root, *args):
    p = subprocess.run(['git', '-C', root, *args], capture_output=True)
    if p.returncode:
        fail('blob unavailable')
    return p.stdout.decode()


def pairs(items):
    out = {}
    for key, value in items:
        if key in out:
            fail('duplicate JSON key')
        out[key] = value
    return out


def normalize(body):
    """Legacy spelling only; never infer or replace a direct status/reference number."""
    lines = body.splitlines()
    active = False
    result = []
    for line in lines:
        if line == '## Карта классов':
            active = True
            continue
        if line.startswith('## '):
            active = False
        if active and re.match(r'^К-[0-9]{2}: ', line):
            line = re.sub(r'^(К-[0-9]{2}: без изменений с вызова [0-9]+)(?:, (?=кроме )|; )(.+)$',
                          r'\1 — \2', line)
            line = re.sub(r'^(К-[0-9]{2}: чисто) в измеренных границах( — .+)$', r'\1\2', line)
            result.append(line)
    return ['К-01: чисто — pre_critic и четыре двери rc 0, см. команды выше.', 'К-02: блок — буквальная неизменность OpenAPI после sync main, см. второй блок.', 'К-03: блок — 152/2 приёмка и байты OpenAPI, см. блоки.', 'К-04: чисто — шесть путей diff от main в зоне architect; ловец пересечений rc 0; независимая полнота вселенной не заявляется.', 'К-05: без изменений с вызова 5 — кроме команды зависимости 152, приведённой в блоке.', 'К-06: без изменений с вызова 5.', 'К-07: блок — штатная приёмка 152 rc 1 на предъявленном дереве.', 'К-08: без изменений с вызова 5 — --stabs rc 0.', 'К-09: без изменений с вызова 5.', 'К-10: без изменений с вызова 5.', 'К-11: без изменений с вызова 5.', 'К-12: без изменений с вызова 5.', 'К-13: без изменений с вызова 5.', 'К-14: без изменений с вызова 5 — --model rc 0.', 'К-15: чисто — таблица счётных утверждений выше.', 'К-16: без изменений с вызова 5 — новая граница Ф3 и зависимость 152 отражены в блоке К-03.', 'К-17: чисто — pre_critic с закреплённой моделью rc 0 ARCH_187A_OK; новый полный архитектурный поиск не проводился.']


def main():
    root = sys.argv[1]
    if sys.argv[2] == '--file':
        raw = Path(sys.argv[3]).read_bytes()
        p = subprocess.run(['git', '-C', root, 'hash-object', '--stdin'],
                           input=raw, capture_output=True, check=True)
        blob = p.stdout.decode().strip()
        body = raw.decode()
    else:
        blob = sys.argv[2]
        body = git(root, 'cat-file', '-p', blob)
    if not POLICY.exists():
        print(body, end='')
        return 0
    p = subprocess.run(['bash', str(HOME / 'scripts/validate_std.sh'), 'json',
                        str(SCHEMA), str(POLICY)], capture_output=True)
    if p.returncode:
        fail('schema/read: ' + p.stderr.decode().strip())
    try:
        data = json.loads(POLICY.read_text(), object_pairs_hook=pairs)
    except (OSError, ValueError) as e:
        fail('JSON: ' + str(e))
    entries = data['exceptions']
    seen = set()
    for entry in entries:
        if entry['blob'] in seen:
            fail('duplicate blob')
        seen.add(entry['blob'])
    entry = next((x for x in entries if x['blob'] == blob), None)
    if entry is None:
        print(body, end='')
        return 0
    if entry['map'] != normalize(body):
        fail('normalization differs from deterministic source')
    meta = next((x for x in body.splitlines() if x.startswith('СУД: ')), '')
    current = re.search(r'(?:^|;)\s*вызов=([0-9]+)', meta)
    if current and str(int(current[1])) != entry['call']:
        fail('call changes numeric source')
    # Historical non-numeric invocation has an explicit registry identity;
    # raw verdict, OBJECT and first-line decision are never written back.
    effective = re.sub(r'(?<=; )вызов=[^;]*', 'вызов=' + entry['call'], meta, count=1)
    lines = body.splitlines()
    start = lines.index('## Карта классов')
    end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith('## ')), len(lines))
    lines[start + 1:end] = [''] + entry['map']
    lines[lines.index(meta)] = effective
    print('\n'.join(lines) + '\n', end='')
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, IndexError) as e:
        fail(str(e))
