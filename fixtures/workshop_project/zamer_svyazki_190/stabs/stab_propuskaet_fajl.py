#!/usr/bin/env python3
"""Стаб: «пропуск» ценой всего журнала — первая неконсистентная строка
обнуляет вклад файла целиком (rc 0, но таблица искажена: Crit301a выпадает
из мер, просмотрено 14 → 12; форма Б-1 ревьюера — «пропуск с искажением
таблицы»). Дефект наблюдаем на мире KC: message:null / message:[1,2] /
поля не нужного типа. На чистых журналах (K0/A) стаб честен: проверка
ничего не находит, считается оригинальный measure_agent."""
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M

_orig = M.measure_agent


def _nekonsistentnyj(path):
    for raw in Path(path).read_bytes().splitlines():
        if not raw:
            continue
        try:
            r = json.loads(raw)
        except ValueError:
            return True
        if not isinstance(r, dict):
            return True
        if r.get('type') == 'message' and not isinstance(r.get('message'), dict):
            return True
    return False


def measure_agent_fail_file(path):
    if _nekonsistentnyj(path):
        return 0, 0, 0, 0  # дефект: битая строка губит весь журнал
    return _orig(path)


M.measure_agent = measure_agent_fail_file
sys.exit(M.main(sys.argv[1:]))
