#!/usr/bin/env python3
# Обманный вариант s6 «гейт следует симлинку-КОРНЮ mobile/src» (159,
# уровень гейта; воспроизводит обход Б1 вердикта Crit159b:
# check_boundaries.py external-src-symlink — os.walk(followlinks=
# False) не следует вложенным ссылкам-каталогам, но следует ссылке,
# переданной корнем обхода). Состав: честные ветви каталога/карты/
# формы; soderzhatelnyj_src БЕЗ проверки islink/realpath-внутри-R у
# корня обхода — заполненный src вне R принимается содержимым.
# Демаркация: на конформном продукте rc 0 (честен); расхождение —
# ровно на входе c3-vneshnij-src-simlink: честный гейт красен
# KOREN_BEZ_SODERZHIMOGO (содержимое вне R не содержимое), этот
# вариант — rc 0. На c2 (симлинк-подкаталог при реальном src) walk
# не следует ссылке и вариант честен — вход не заявлен.
import json
import os
import sys


def chita_json(put):
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def dejstvitelnaja_zapis(z):
    return (isinstance(z, dict) and bool(z)
            and isinstance(z.get('id'), str) and bool(z['id']))


def soderzhatelnyj_src(put):
    """ДЕФЕКТ варианта: корень обхода не проверяется — walk следует
    ссылке-корню (поведение эталона v2, пойманное критиком)."""
    if not os.path.isdir(put):
        return False
    pervyj = True
    for koren, _katalogi, fajly in os.walk(put, followlinks=False):
        if pervyj:
            pervyj = False
            continue
        for imja in fajly:
            p = os.path.join(koren, imja)
            if not os.path.islink(p) and os.path.isfile(p):
                return True
    return False


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('использование: %s <корень продукта>\n'
                         % sys.argv[0])
        return 2
    r = sys.argv[1]
    if not os.path.isdir(r):
        print('PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET')
        return 1
    if not os.listdir(r):
        print('PUSTOJ_PRODUKT: KATALOG_PUST')
        return 1
    karta = chita_json(os.path.join(r, 'mobile', 'ci-screens.json'))
    if not isinstance(karta, dict):
        print('PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ')
        return 1
    ekrany = karta.get('ekrany')
    if not isinstance(ekrany, list) \
            or not any(dejstvitelnaja_zapis(z) for z in ekrany):
        print('PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ')
        return 1
    forma_est = False
    import glob
    for p in glob.glob(os.path.join(r, 'mobile', 'e2e-*', 'ekran.json')):
        ej = chita_json(p)
        if isinstance(ej, dict) and ej:
            ekran = ej.get('ekran')
            if isinstance(ekran, str) and ekran:
                forma_est = True
                break
    if not forma_est:
        print('PUSTOJ_PRODUKT: FORMA_PUSTA')
        return 1
    if not soderzhatelnyj_src(os.path.join(r, 'mobile', 'src')):
        print('PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
