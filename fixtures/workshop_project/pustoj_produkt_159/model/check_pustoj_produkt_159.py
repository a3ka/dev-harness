#!/usr/bin/env python3
# ЭТАЛОН гейта пустого продукта (контракт 159 v2, правка по Crit159 v1).
# Живая реализация — scripts/check_pustoj_produkt.sh (зона implementer);
# грамматика — ЕДИНЫЙ источник этот файл: живой гейт обязан давать те
# же rc и ту же именованную причину на каждом входе домена (судит
# батарея 159, клетки s-gate-raven-etalonu). Трассу вызова
# (PUSTOJ_PRODUKT_TRACE) эталон НЕ пишет — трасса есть форма живого
# гейта (инвариант 3 контракта): вызов эталона не должен быть
# неотличим от вызова гейта.
#
# Домен «пустой продукт» (слово владельца 2026-11-03 + блок Б1
# вердикта Crit159: пустым считается и продукт с пустыми контейнерами,
# пустыми значениями и записями без действия; старшинство причин —
# ровно одно имя на вход):
#   (б2) R не существует или не каталог      → PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
#   (б1) R существует, но пуст (нет записей) → PUSTOJ_PRODUKT: KATALOG_PUST
#   (в)  карта mobile/ci-screens.json отсутствует/битая/не словарь
#        (в том числе непустой массив, число, строка, null, вложенный
#        словарь) или не содержит НИ ОДНОЙ действительной записи →
#        PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ; действительная запись —
#        непустой объект с непустым строковым id (null, "" и объект
#        без id — не записи)
#   (а)  ни одна пачка mobile/e2e-*/ekran.json не является непустым
#        словарём с ключом ekran, значение которого НЕПУСТАЯ строка
#        (пустой идентификатор экрана — пустая форма)
#        → PUSTOJ_PRODUKT: FORMA_PUSTA
#   (г)  mobile/src отсутствует или не содержит подкаталога, внутри
#        которого есть хотя бы один регулярный файл (корневые файлы —
#        контейнеры приложения; симлинки — не содержимое: содержимое
#        принадлежит R) → PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
#   иначе rc 0 (продукт не пуст; полнота/валидность записи и формы —
#   предмет валидатора 132, не гейта).
#
# Тип значения проверяется ДО обращения к полям: любой допустимый вход
# даёт именованный отказ БЕЗ исключений; ошибки доступа → rc 2,
# fail-closed, не зелень.
import glob
import json
import os
import sys

KARTA = os.path.join('mobile', 'ci-screens.json')
SRC = os.path.join('mobile', 'src')


def chita_json(put):
    """Разобранное значение | None. Битый JSON == отсутствует."""
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def dejstvitelnaja_zapis(z):
    """Запись экранной цели: непустой объект с непустым строковым id."""
    return (isinstance(z, dict) and bool(z)
            and isinstance(z.get('id'), str) and bool(z['id']))


def soderzhatelnyj_src(put):
    """True — в src есть подкаталог с регулярным файлом внутри.

    os.walk(followlinks=False) не спускается в симлинк-каталоги;
    симлинк-файлы отсеются islink: содержимое принадлежит R, корень
    src (контейнер приложения) содержимым не считается."""
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


def sudi(r):
    """(rc, prichina). Ровно одно имя на вход, по старшинству."""
    if not os.path.isdir(r):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'
    if not os.listdir(r):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_PUST'
    karta = chita_json(os.path.join(r, KARTA))
    if not isinstance(karta, dict):
        # тип — ДО обращения к полям: массив/число/строка/null дают
        # именованный отказ, не AttributeError
        return 1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'
    ekrany = karta.get('ekrany')
    if not isinstance(ekrany, list) \
            or not any(dejstvitelnaja_zapis(z) for z in ekrany):
        return 1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'
    forma_est = False
    for p in glob.glob(os.path.join(r, 'mobile', 'e2e-*', 'ekran.json')):
        ej = chita_json(p)
        if isinstance(ej, dict) and ej:
            ekran = ej.get('ekran')
            if isinstance(ekran, str) and ekran:
                forma_est = True
                break
    if not forma_est:
        return 1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'
    if not soderzhatelnyj_src(os.path.join(r, SRC)):
        return 1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'
    return 0, ''


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('использование: %s <корень продукта>\n'
                         % sys.argv[0])
        return 2
    try:
        rc, prichina = sudi(sys.argv[1])
    except OSError:
        sys.stderr.write('PUSTOJ_PRODUKT: NECHITAEMO (ошибка доступа)\n')
        return 2
    if prichina:
        print(prichina)
    return rc


if __name__ == '__main__':
    sys.exit(main())
