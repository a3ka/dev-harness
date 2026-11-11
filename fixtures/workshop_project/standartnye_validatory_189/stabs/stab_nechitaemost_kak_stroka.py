#!/usr/bin/env python3
"""189 — ОБМАНКА (Блок 4 критика, вызов 3): недоступность пин-файла ≡ «строки
движка нет» — OSError глотается, «файла нет»/«не читается» дают ENGINE_MISSING
«нет строки пина», неотличимо от Д5=Д7=Д9 критика. Отличие от модели ровно
одно: отказы чтения пин-файла не различаются маркером ENGINE_PINS. На клетке
v34 (файл цел, строки нет) обманка честна — краснота на v32/v33.
"""
import json
import os
import sys
from pathlib import Path

PIN_FILE = os.environ.get(
    'VALIDATE_STD_PINS',
    str(Path(__file__).resolve().parents[1] / 'ops' / 'server' / 'validators.tsv'))


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
    import jsonschema
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
