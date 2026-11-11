#!/usr/bin/env python3
"""189 — МОДЕЛЬ: канон + структурное сравнение job против фрагмента-канона.

Разбор YAML (pyyaml) → глубокое сравнение разобранных структур: эквивалентные
записи (порядок ключей, кавычки, block/flow-списки) равны. Первое отличие —
детерминированный обход: узлы канона в порядке объявления, затем лишние ключи
субъекта в его порядке; списки — по индексам, разница длин — первым индексом
за общей префикс-частью. rc 0 равенство; rc 1 `CANON_DIFF: <путь>`; rc 2 —
именованные отказы разбора/грамматики/среды.
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


def kljuch(put, k):
    return '%s.%s' % (put, k) if put else str(k)


def indeks(put, i):
    return '%s[%d]' % (put, i)


def tip(znach):
    return type(znach).__name__


def pervoe_otlichie(kanon, subekt, put=''):
    if isinstance(kanon, dict) and isinstance(subekt, dict):
        for k in kanon:
            if k not in subekt:
                return (kljuch(put, k), 'нет у субъекта, канон: %r' % (kanon[k],))
            rez = pervoe_otlichie(kanon[k], subekt[k], kljuch(put, k))
            if rez:
                return rez
        for k in subekt:
            if k not in kanon:
                return (kljuch(put, k), 'лишнее у субъекта: %r' % (subekt[k],))
        return None
    if isinstance(kanon, list) and isinstance(subekt, list):
        for i in range(min(len(kanon), len(subekt))):
            rez = pervoe_otlichie(kanon[i], subekt[i], indeks(put, i))
            if rez:
                return rez
        if len(kanon) != len(subekt):
            i = min(len(kanon), len(subekt))
            if len(subekt) > len(kanon):
                return (indeks(put, i), 'лишний элемент: %r' % (subekt[i],))
            return (indeks(put, i), 'нет элемента, канон: %r' % (kanon[i],))
        return None
    if tip(kanon) != tip(subekt):
        return (put or '<job>', 'тип %s ≠ %s' % (tip(subekt), tip(kanon)))
    if kanon != subekt:
        return (put or '<job>', 'значение %r ≠ канон %r' % (subekt, kanon))
    return None


def razbor_yaml(put, chto):
    import os
    if not os.path.isfile(put):
        otkaz2('CANON_ABSENT: файл %s не найден: %s' % (chto, put))
    try:
        with open(put, encoding='utf-8') as f:
            return yaml.safe_load(f)
    except yaml.YAMLError as e:
        perv = str(e).splitlines()[0] if str(e) else ''
        otkaz2('CANON_UNPARSEABLE: %s: %s' % (chto, perv))


def main():
    if len(sys.argv) != 4:
        otkaz2('NOT_IMPLEMENTED: check_canon_fragment.py <workflow> <job-id> <канон>')
    wf_path, job_id, canon_path = sys.argv[1], sys.argv[2], sys.argv[3]
    kanon = razbor_yaml(canon_path, 'канон')
    doc = razbor_yaml(wf_path, 'workflow')
    if not isinstance(doc, dict) or not isinstance(doc.get('jobs'), dict):
        otkaz2('CANON_UNPARSEABLE: workflow без jobs-отображения')
    if not isinstance(kanon, dict):
        otkaz2('CANON_FRAGMENT: канон не отображение job')
    if job_id not in doc['jobs']:
        otkaz2('CANON_JOB_MISSING: job не найден: %s' % job_id)
    ot = pervoe_otlichie(kanon, doc['jobs'][job_id], '')
    if ot:
        print('CANON_DIFF: %s: %s' % (ot[0], ot[1]), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
