#!/usr/bin/env python3
"""189 — ОБМАННАЯ РЕАЛИЗАЦИЯ (батарея): схема-пустышка {}.

Дефект: документ только разбирается как JSON, схема вызывающего игнорируется —
валидация всегда «успешна» (эквивалент валидации против {}). Различающий вход:
клетка v13 (документ, нарушающий схему, — обязан быть красным rc 1).
"""
import json
import sys
from pathlib import Path


def otkaz2(msg):
    print(msg, file=sys.stderr)
    sys.exit(2)


def main():
    if len(sys.argv) != 3:
        otkaz2('NOT_IMPLEMENTED: validate_std_json.py <схема> <документ>')
    try:
        json.loads(Path(sys.argv[2]).read_text(encoding='utf-8'))
    except OSError:
        otkaz2('JSON_UNPARSEABLE: документ не читается: %s' % sys.argv[2])
    except ValueError as e:
        otkaz2('JSON_UNPARSEABLE: документ: %s' % e)
    # ДЕФЕКТ: схема не читается и не применяется — «валидатор» = {}.
    return 0


if __name__ == '__main__':
    sys.exit(main())
