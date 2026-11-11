#!/usr/bin/env python3
"""189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): переданная схема не читается.

Дефект: движок импортируется и пин версии честен, но валидность решается по
единственному наблюдаемому полю mode документа — ограничения схемы вызывающего
(required, типы, additionalProperties) не применяются. Различающий вход:
клетка v23 (вторая пара «схема/документ»: mode валиден, нарушения вне mode —
лишнее поле и ves не числом; честный субъект обязан rc 1 JSON_INVALID:<путь>).
"""
import json
import os
import sys
from pathlib import Path

PIN_FILE = os.environ.get(
    'VALIDATE_STD_PINS',
    str(Path(__file__).resolve().parents[1] / 'ops' / 'server' / 'validators.tsv'))

REZHIMY = ('workflow', 'bash', 'json')


def otkaz2(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


def pin_versii():
    try:
        for line in Path(PIN_FILE).read_text(encoding='utf-8').splitlines():
            if not line.strip() or line.lstrip().startswith('#'):
                continue
            cols = line.split('\t')
            if len(cols) >= 2 and cols[0] == 'jsonschema':
                return cols[1]
    except OSError:
        pass
    return None


def chitaem_json(put, chto):
    try:
        return json.loads(Path(put).read_text(encoding='utf-8'))
    except OSError:
        otkaz2('JSON_UNPARSEABLE: %s не читается: %s' % (chto, put))
    except ValueError as e:
        otkaz2('JSON_UNPARSEABLE: %s: %s' % (chto, e))


def main():
    if len(sys.argv) != 3:
        otkaz2('NOT_IMPLEMENTED: validate_std_json.py <схема> <документ>')
    pin = pin_versii()
    if pin is None:
        otkaz2('ENGINE_MISSING: jsonschema (нет строки пина: %s)' % PIN_FILE)
    try:
        import jsonschema  # noqa: F401
    except Exception:
        otkaz2('ENGINE_MISSING: jsonschema')
    from importlib.metadata import version as versia_paketa
    try:
        fakt = versia_paketa('jsonschema')
    except Exception:
        otkaz2('ENGINE_MISSING: jsonschema (версия не разрешается)')
    if fakt != pin:
        otkaz2('ENGINE_VERSION: jsonschema %s ≠ пин %s' % (fakt, pin))
    chitaem_json(sys.argv[1], 'схема')
    doc = chitaem_json(sys.argv[2], 'документ')
    # ДЕФЕКТ: схема не применяется; валидность — по полю mode документа.
    rezhim = doc.get('mode') if isinstance(doc, dict) else None
    if rezhim not in REZHIMY:
        print("JSON_INVALID:/mode %r is not one of %r" % (rezhim, list(REZHIMY)),
              file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
