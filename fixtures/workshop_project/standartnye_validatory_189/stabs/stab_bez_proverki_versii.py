#!/usr/bin/env python3
"""189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): версия движка не сверяется с пином.

Дефект: jsonschema импортируется и валидизирует без сверки версии со строкой
пина. Различающий вход: клетка v16 (подложный дистрибутив 0.0.0 в PYTHONPATH —
честный субъект обязан отказаться rc 2 ENGINE_VERSION).
"""
import json
import sys
from pathlib import Path


def otkaz2(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


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
    try:
        import jsonschema
    except Exception:
        otkaz2('ENGINE_MISSING: jsonschema')
    # ДЕФЕКТ: сверка importlib.metadata.version('jsonschema') с пином отсутствует.
    schema = chitaem_json(sys.argv[1], 'схема')
    doc = chitaem_json(sys.argv[2], 'документ')
    oshibki = sorted(
        jsonschema.Draft202012Validator(schema).iter_errors(doc),
        key=lambda e: [str(p) for p in e.absolute_path])
    if oshibki:
        perv = oshibki[0]
        ukaz = '/' + '/'.join(str(p) for p in perv.absolute_path)
        print('JSON_INVALID:%s %s' % (ukaz, perv.message[:160]), file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
