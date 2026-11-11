#!/usr/bin/env python3
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh;
# её приёмка — красная проба на сам scripts/architecture_review.py (клетка review_file, режимы --repo/--stabs), не сам скрипт;
# контракт 186 §Предмет 2 — скрипт судит наличие обзора в HEAD проекта, запись обзора — работа роли, не барьера.
"""Наличие обзора среза в HEAD проекта (контракт 186, §Предмет 2).

    python3 scripts/architecture_review.py <корень-CompliorOS-architecture> <YYYY-MM-DD> <Э>

Файл обзора читается ИЗ КОММИТА HEAD проекта: незакоммиченная запись обзором не
считается (проверка вызывается ПОСЛЕ сессии обзора, а не до возможности создать
файл). Отсутствующий или пустой файл — `НЕТ ОБЗОРА: <путь>`, rc 1: это находка
оркестратору, а не молчаливое отсутствие отчёта.

Полный обзор несёт обязательные разделы (каждый — отдельной строкой):
`## Дельта модели`, `## arch:conform на main`, `## Находки`, `## L2-пачка`,
`## DRAFT-реестр`. Пустой срез обзором считается: разделы есть, тело может быть
пустым. Обзор без разделов — `НЕПОЛНЫЙ ОБЗОР: <путь>`, rc 1.

Коды возврата: 0 — обзор в HEAD и полон, 1 — обзора нет или он неполон
                  (причина в stdout), 2 — нечем проверить (нет корня проекта).
"""
import pathlib
import subprocess
import sys

REQUIRED_SECTIONS = ('## Дельта модели', '## arch:conform на main', '## Находки',
                      '## L2-пачка', '## DRAFT-реестр')


def main(argv):
    if len(argv) != 4:
        print('использование: architecture_review.py <корень-CompliorOS-architecture> '
              '<YYYY-MM-DD> <Э>', file=sys.stderr)
        return 2
    root = pathlib.Path(argv[1])
    date, stage = argv[2], argv[3]
    name = 'governance/review/' + date + '-' + stage + '.md'
    if not root.is_dir():
        print('NOT_IMPLEMENTED: нет корня проекта: ' + str(root), file=sys.stderr)
        return 2
    result = subprocess.run(['git', '-C', str(root), 'show', 'HEAD:' + name],
                            text=True, capture_output=True)
    if result.returncode != 0 or not result.stdout.strip():
        print('НЕТ ОБЗОРА: ' + name)
        return 1
    if not set(REQUIRED_SECTIONS).issubset(set(result.stdout.splitlines())):
        print('НЕПОЛНЫЙ ОБЗОР: ' + name)
        return 1
    return 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
