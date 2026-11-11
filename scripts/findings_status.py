#!/usr/bin/env python3
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/architecture_steward_186/red_architecture_186.sh;
# её приёмка — красная проба на сам scripts/findings_status.py (клетка status_cli, режимы --repo/--stabs), не сам скрипт;
# контракт 186 §Предмет 1 — скрипт судит просрочку находок, запись в проект — работа роли, не барьера.
"""Просрочка находок архитектуры (контракт 186, §Предмет 1).

    python3 scripts/findings_status.py <корень-CompliorOS-architecture> <git-ref-предыдущего-среза>

СОСТАВ СРЕЗА — через Git: `git ls-tree` на указанном ref. В просрочку попадают
только те файлы `governance/findings/`, которые лежали в проекте ДО среза.
Свежий файл (созданный после среза) просроченным не становится: исходный ref
задаёт состав среза, а не время модификации файла.

СТАТУС — из текущего рабочего дерева: решение, принятое после среза, закрывает
находку, иначе закрытая находка оставалась бы просроченной навсегда. Файл,
отозванный из дерева, просроченным не считается.

ДОПУСТИМЫЕ СТАТУСЫ (грамматика §8.3): `принята L1`, `принята L2`, `принята L3`,
`отклонена: <непустая причина>`, `вопрос владельцу`. Любой другой — в том числе
пустой, неоднозначный (два поля `Статус:`) или посторонний текст — просрочка:
решение не выбрано автором, а выбрать его должен приёмщик.

ВЫВОД: по строке на просроченный файл — `ПРОСРОЧЕНО: governance/findings/<имя>`;
строки идут в отчёт обзора (роль носит их в governance/review/).

Коды возврата: 0 — просрочки нет, 1 — просрочка есть (имена файлов в stdout),
                  2 — нечем проверить (нет корня проекта, ref не читается).
"""
import pathlib
import subprocess
import sys

FINDINGS_DIR = 'governance/findings/'
VALID_STATUSES = ('принята L1', 'принята L2', 'принята L3', 'вопрос владельцу')
REJECTED_PREFIX = 'отклонена:'


def not_implemented(message):
    print('NOT_IMPLEMENTED: ' + message, file=sys.stderr)
    raise SystemExit(2)


def git(root, args):
    result = subprocess.run(['git', '-C', str(root)] + args, text=True, capture_output=True)
    if result.returncode != 0:
        not_implemented('git ' + ' '.join(args) + ': ' + (result.stderr.strip() or 'отказ'))
    return result.stdout


def status_of(text):
    """Статус находки; '' — допустимого статуса нет (пусто, мусор или два поля)."""
    fields = [line[len('Статус:'):].strip()
              for line in text.splitlines() if line.startswith('Статус:')]
    if len(fields) != 1:
        return ''
    value = fields[0]
    if value in VALID_STATUSES:
        return value
    if value.startswith(REJECTED_PREFIX) and value[len(REJECTED_PREFIX):].strip():
        return value
    return ''


def main(argv):
    if len(argv) != 3:
        print('использование: findings_status.py <корень-CompliorOS-architecture> '
              '<git-ref-предыдущего-среза>', file=sys.stderr)
        return 2
    root = pathlib.Path(argv[1])
    ref = argv[2]
    if not root.is_dir():
        not_implemented('нет корня проекта: ' + str(root))
    names = [line for line in
             git(root, ['ls-tree', '-r', '--name-only', ref, '--', FINDINGS_DIR]).splitlines()
             if line.strip()]
    overdue = []
    for name in names:
        path = root / name
        if not path.is_file():
            continue  # находка отозвана из дерева — просрочки нет
        if status_of(path.read_text(encoding='utf-8')):
            continue  # решение принято
        overdue.append(name)
    for name in overdue:
        print('ПРОСРОЧЕНО: ' + name)
    return 1 if overdue else 0


if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
