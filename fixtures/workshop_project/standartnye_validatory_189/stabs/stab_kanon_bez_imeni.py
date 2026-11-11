#!/usr/bin/env python3
"""189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): отличие без имени и пути.

Дефект: структурное сравнение есть, но rc 1 выходит без строки
`CANON_DIFF: <путь>` — «нашёл отличие» без наблюдаемого первого отличия.
Различающий вход: клетка k03 (мутация без runs-on: честный субъект называет
путь runs-on, эта реализация молчит).
"""
import sys

try:
    import yaml
except Exception:
    print('CANON_ENV: нет pyyaml', file=sys.stderr)
    sys.exit(2)


def otkaz2(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


def ravny(a, b):
    if isinstance(a, dict) and isinstance(b, dict):
        return a.keys() == b.keys() and all(ravny(a[k], b[k]) for k in a)
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(ravny(x, y) for x, y in zip(a, b))
    return type(a) is type(b) and a == b


def main():
    if len(sys.argv) != 4:
        otkaz2('NOT_IMPLEMENTED: check_canon_fragment.py <workflow> <job-id> <канон>')
    import os
    for p in (sys.argv[3], sys.argv[1]):
        if not os.path.isfile(p):
            otkaz2('CANON_ABSENT: файл не найден: %s' % p)
    try:
        doc = yaml.safe_load(open(sys.argv[1], encoding='utf-8'))
        kanon = yaml.safe_load(open(sys.argv[3], encoding='utf-8'))
    except yaml.YAMLError as e:
        otkaz2('CANON_UNPARSEABLE: %s' % (str(e).splitlines()[0] if str(e) else ''))
    if not isinstance(doc, dict) or not isinstance(doc.get('jobs'), dict):
        otkaz2('CANON_UNPARSEABLE: workflow без jobs-отображения')
    if not isinstance(kanon, dict):
        otkaz2('CANON_FRAGMENT: канон не отображение job')
    if sys.argv[2] not in doc['jobs']:
        otkaz2('CANON_JOB_MISSING: job не найден: %s' % sys.argv[2])
    if not ravny(kanon, doc['jobs'][sys.argv[2]]):
        # ДЕФЕКТ: rc 1 без CANON_DIFF-пути первого отличия.
        print('OTLICHIE: запись не равна канону', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
