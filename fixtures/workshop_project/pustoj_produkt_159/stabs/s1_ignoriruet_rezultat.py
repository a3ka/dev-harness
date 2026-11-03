#!/usr/bin/env python3
# Обманный вариант s1 «гейт вызван, но результат игнорируется» (159).
# Форма: состав [гейт → батарея], где rc гейта ВЫЧИСЛЕН и выброшен, а
# остаток батареи (по предпосылке боли) на пустом продукте зелён.
# Внутри — дословная честная проверка пустоты; её результат печатается
# трассей GATE_VYZVAN rc=N ignored и НЕ влияет на итог: rc 0 всегда.
# Валидность контрпримера (демаркация): на конформном продукте ведёт
# себя как честный состав (rc 0); расхождение — на КОНФОРМНОМ пустом
# входе, где честный гейт даёт rc 1, а этот состав — rc 0.
import glob
import json
import os
import sys


def chita_json(put):
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def pustoj(r):
    if not os.path.isdir(r):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'
    if not os.listdir(r):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_PUST'
    karta = chita_json(os.path.join(r, 'mobile', 'ci-screens.json'))
    ekrany = (karta or {}).get('ekrany')
    if not isinstance(karta, dict) or not isinstance(ekrany, list) \
            or not ekrany:
        return 1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'
    for p in glob.glob(os.path.join(r, 'mobile', 'e2e-*', 'ekran.json')):
        ej = chita_json(p)
        if isinstance(ej, dict) and ej and isinstance(ej.get('ekran'), str):
            break
    else:
        return 1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'
    put_src = os.path.join(r, 'mobile', 'src')
    if not os.path.isdir(put_src) or not any(
            os.path.isdir(os.path.join(put_src, i))
            for i in os.listdir(put_src)):
        return 1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'
    return 0, ''


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('использование: %s <корень продукта>\n'
                         % sys.argv[0])
        return 2
    rc, prichina = pustoj(sys.argv[1])
    if rc != 0:
        print('GATE_VYZVAN rc=%d ignored (%s)' % (rc, prichina))
    # результат выброшен: остаток батареи зелён и на пустом продукте
    print('BATAREJA ok')
    return 0


if __name__ == '__main__':
    sys.exit(main())
