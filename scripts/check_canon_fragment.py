#!/usr/bin/env python3
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/standartnye_validatory_189/
# red_standartnye_validatory_189.sh; приёмка предмета 189 (контракт
# contracts/189-standartnye-validatory-i-kanon.md, инвариант 4) — красная проба на
# сам scripts/check_canon_fragment.py (режимы --repo/--model/--stabs), не сам скрипт;
# контракт 189 §Проводка: guard=fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh.
"""189 — канон: структурное равенство job против фрагмента-канона (YAML, pyyaml).

Разбор YAML (pyyaml) и сравнение РАЗОБРАННЫХ структур: эквивалентные записи (порядок
ключей, кавычки, block/flow-списки) равны. Текстовые сравнения не применяются: подстрочный
«канон» даёт ложный отказ на эквивалентной записи.

Возвращаемые коды: 0 — job равен канону; 1 — расхождение (stderr `CANON_DIFF: <путь>:
<причина>`, путь ПЕРВОГО отличия); 2 — именованный отказ: CANON_ABSENT/
CANON_UNPARSEABLE/CANON_JOB_MISSING/CANON_FRAGMENT/CANON_ENV/NOT_IMPLEMENTED.
"""
import os
import sys

try:
    import yaml
except Exception:
    print('CANON_ENV: нет pyyaml', file=sys.stderr)
    sys.exit(2)


def refuse(message):
    print(message, file=sys.stderr)
    sys.exit(2)


def key_path(path, key):
    return '%s.%s' % (path, key) if path else str(key)


def index_path(path, index):
    return '%s[%d]' % (path, index)


def first_difference(canon, subject, path=''):
    """Первое отличие (канон, субъект) → (путь, причина); None — равны.

    Обход детерминирован: узлы канона в порядке объявления, затем лишние ключи
    субъекта в его порядке; списки — по индексам, а разница длин — первым индексом
    за общей частью."""
    if isinstance(canon, dict) and isinstance(subject, dict):
        for key in canon:
            if key not in subject:
                return (key_path(path, key), 'нет у субъекта, канон: %r' % (canon[key],))
            diff = first_difference(canon[key], subject[key], key_path(path, key))
            if diff:
                return diff
        for key in subject:
            if key not in canon:
                return (key_path(path, key), 'лишнее у субъекта: %r' % (subject[key],))
        return None
    if isinstance(canon, list) and isinstance(subject, list):
        for index in range(min(len(canon), len(subject))):
            diff = first_difference(canon[index], subject[index],
                                    index_path(path, index))
            if diff:
                return diff
        if len(canon) != len(subject):
            index = min(len(canon), len(subject))
            if len(subject) > len(canon):
                return (index_path(path, index), 'лишний элемент: %r' % (subject[index],))
            return (index_path(path, index), 'нет элемента, канон: %r' % (canon[index],))
        return None
    if type(canon) is not type(subject):
        return (path or '<job>', 'тип %s ≠ %s' % (type(subject).__name__,
                                                 type(canon).__name__))
    if canon != subject:
        return (path or '<job>', 'значение %r ≠ канон %r' % (subject, canon))
    return None


def read_yaml(path, what):
    if not os.path.isfile(path):
        refuse('CANON_ABSENT: файл %s не найден: %s' % (what, path))
    try:
        with open(path, encoding='utf-8') as stream:
            return yaml.safe_load(stream)
    except yaml.YAMLError as e:
        first = str(e).splitlines()[0] if str(e) else ''
        refuse('CANON_UNPARSEABLE: %s: %s' % (what, first))
    except OSError:
        refuse('CANON_ABSENT: файл %s не читается: %s' % (what, path))


def main():
    if len(sys.argv) != 4:
        refuse('NOT_IMPLEMENTED: check_canon_fragment.py <workflow> <job-id> <канон>')
    workflow_path, job_id, canon_path = sys.argv[1], sys.argv[2], sys.argv[3]
    canon = read_yaml(canon_path, 'канон')
    workflow = read_yaml(workflow_path, 'workflow')
    if not isinstance(workflow, dict) or not isinstance(workflow.get('jobs'), dict):
        refuse('CANON_UNPARSEABLE: workflow без jobs-отображения')
    if not isinstance(canon, dict):
        refuse('CANON_FRAGMENT: канон не отображение job')
    if job_id not in workflow['jobs']:
        refuse('CANON_JOB_MISSING: job не найден: %s' % job_id)
    diff = first_difference(canon, workflow['jobs'][job_id])
    if diff:
        print('CANON_DIFF: %s: %s' % diff, file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
