#!/usr/bin/env python3
"""189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): текстовая подстрока вместо разбора YAML.

Дефект: «сравнение с каноном» — поиск первой содержательной строки канона как
подстроки в файле workflow; структурного разбора нет. Различающий вход: клетка
k02 (эквивалентная запись — иные кавычки/порядок ключей; обязана быть зелёной,
подстрочный поиск даёт ложный отказ).
"""
import sys


def otkaz2(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


def main():
    if len(sys.argv) != 4:
        otkaz2('NOT_IMPLEMENTED: check_canon_fragment.py <workflow> <job-id> <канон>')
    try:
        kanon = open(sys.argv[3], encoding='utf-8').read()
        wf = open(sys.argv[1], encoding='utf-8').read()
    except OSError as e:
        otkaz2('CANON_ABSENT: %s' % e)
    igla = next(
        (l.strip() for l in kanon.splitlines()
         if l.strip() and not l.strip().startswith('#')),
        '')
    # ДЕФЕКТ: подстрока вместо структурного сравнения разобранных YAML.
    if igla and igla in wf:
        return 0
    print('OTLICHIE: текст канона не найден подстрокой', file=sys.stderr)
    return 1


if __name__ == '__main__':
    sys.exit(main())
