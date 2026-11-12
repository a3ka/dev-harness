#!/usr/bin/env python3
# НЕ БАРЬЕР: субъект (SUBJECT) батареи fixtures/workshop_project/standartnye_validatory_189/
# red_standartnye_validatory_189.sh; приёмка предмета 189 (контракт
# contracts/189-standartnye-validatory-i-kanon.md, инварианты 2–3) — красная проба на
# сам scripts/validate_std_json.py (режимы --repo/--model/--stabs), не сам скрипт;
# контракт 189 §Проводка: guard=fixtures/workshop_project/standartnye_validatory_189/red_standartnye_validatory_189.sh.
"""189 — режим json: JSON Schema (Draft 2020-12) движком jsonschema с пином версии.

Пин движка — строка `jsonschema` файла пинов (версия; sha256-колонка `-`: пакет
python закрепляется версией, а не байтами). Схема и документ — данные вызывающего,
код их не выбирает.

Возвращаемые коды: 0 — документ соответствует схеме; 1 — первое нарушение (stderr
`JSON_INVALID:<указатель> <причина>`); 2 — именованный отказ: ENGINE_PINS/
ENGINE_MISSING/ENGINE_VERSION/JSON_UNPARSEABLE/NOT_IMPLEMENTED.
"""
import json
import os
import sys
from pathlib import Path

# Пины — тот же файл, что читает scripts/validate_std.sh (инвариант 2): дефолт —
# файл репо рядом со скриптом, шов — для стендовых миров.
PIN_FILE = os.environ.get(
    'VALIDATE_STD_PINS',
    str(Path(__file__).resolve().parents[1] / 'ops' / 'server' / 'validators.tsv'))


def refuse(message):
    print(message, file=sys.stderr)
    sys.exit(2)


def read_pins():
    """Текст пин-файла. Три различимых состояния (инвариант 2): «файла нет» и
    «не читается» — именованный отказ ДО резолва движка; «файл цел, строки нет» —
    ENGINE_MISSING (различие видимо, а не спрятано)."""
    try:
        return Path(PIN_FILE).read_text(encoding='utf-8')
    except FileNotFoundError:
        refuse('ENGINE_PINS: файл пинов не найден: %s' % PIN_FILE)
    except OSError:
        refuse('ENGINE_PINS: файл пинов не читается: %s' % PIN_FILE)


def pinned_version(tool):
    """Версия инструмента из строки пина; None — строки нет."""
    for line in read_pins().splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) >= 2 and cols[0] == tool:
            return cols[1]
    return None


def read_json(path, what):
    try:
        return json.loads(Path(path).read_text(encoding='utf-8'))
    except OSError:
        refuse('JSON_UNPARSEABLE: %s не читается: %s' % (what, path))
    except ValueError as e:
        refuse('JSON_UNPARSEABLE: %s: %s' % (what, e))


def main():
    if len(sys.argv) != 3:
        refuse('NOT_IMPLEMENTED: validate_std_json.py <схема> <документ>')
    pin = pinned_version('jsonschema')
    if pin is None:
        refuse('ENGINE_MISSING: jsonschema (нет строки пина: %s)' % PIN_FILE)
    try:
        import jsonschema
    except Exception:
        refuse('ENGINE_MISSING: jsonschema')
    from importlib.metadata import version as package_version
    try:
        fakt = package_version('jsonschema')
    except Exception:
        refuse('ENGINE_MISSING: jsonschema (версия не разрешается)')
    if fakt != pin:
        refuse('ENGINE_VERSION: jsonschema %s ≠ пин %s' % (fakt, pin))
    schema = read_json(sys.argv[1], 'схема')
    document = read_json(sys.argv[2], 'документ')
    validator = jsonschema.Draft202012Validator(schema)
    # Первое нарушение — по указателю: сортировка стабильная, указатели сравнимы.
    errors = sorted(validator.iter_errors(document),
                    key=lambda e: [str(p) for p in e.absolute_path])
    if errors:
        first = errors[0]
        pointer = '/' + '/'.join(str(p) for p in first.absolute_path)
        print('JSON_INVALID:%s %s' % (pointer, first.message[:160]), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
