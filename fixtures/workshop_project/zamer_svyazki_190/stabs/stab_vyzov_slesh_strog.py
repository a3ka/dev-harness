#!/usr/bin/env python3
"""Стаб: грамматика поля вызов= строгая — только «N/M», число до слэша;
живые формы «N (пояснение)» без слэша не разбираются (инт-разбор валится).
Дефект наблюдаем на мире D: предмет 302 с формами «3 (…)»/«4 (…)» теряет
установленность (вызовы 4 → не-установлен)."""
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'model'))
import zamer_model as M


def sud_call_key_strict(fields):
    if 'предмет' not in fields or 'роль' not in fields or 'вызов' not in fields:
        return None
    try:
        n = int(fields['вызов'].split('/')[0].strip())
    except ValueError:
        return None  # дефект: «N (…)» без слэша не разбирается
    mm = M.re.search(r'\(([^)]*)\)', fields.get('фаза', ''))
    seria = mm.group(1).strip() if mm else ''
    return (fields['предмет'].lstrip('0') or '0', seria, n)


M.sud_call_key = sud_call_key_strict
sys.exit(M.main(sys.argv[1:]))
