#!/usr/bin/env python3
# ЭТАЛОН гейта пустого продукта (контракт 159 v3, правка по вердиктам
# Crit159 (Б1-Б4) и Crit159b (Б1-Б4)). Живая реализация —
# scripts/check_pustoj_produkt.sh (зона implementer); грамматика —
# ЕДИНЫЙ источник этот файл: живой гейт обязан давать те же rc и ту же
# именованную причину на каждом входе домена (судит батарея 159, клетки
# s-gate-raven-etalonu). Трассу вызова (PUSTOJ_PRODUKT_TRACE) эталон
# НЕ пишет — трасса есть форма живого гейта (инвариант 3 контракта):
# вызов эталона не должен быть неотличим от вызова гейта.
#
# Домен «пустой продукт» (слово владельца 2026-11-03 + Б1 Crit159 +
# Б1 Crit159b: пустым считается и продукт с пустыми контейнерами,
# пустыми значениями, записями без действия и содержимым вне R;
# старшинство причин — ровно одно имя на вход):
#   rc 1 — структурная пустота:
#   (б2) R не существует или не каталог      → PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
#   (б1) R существует, но пуст (нет записей) → PUSTOJ_PRODUKT: KATALOG_PUST
#   (в)  карта mobile/ci-screens.json отсутствует/битая/не словарь
#        (в том числе непустой массив, число, строка, null, вложенный
#        словарь) или не содержит НИ ОДНОЙ действительной записи или
#        сама карта — симлинк/путь вне R (не своя) →
#        PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ; действительная запись —
#        непустой объект с непустым строковым id (null, "" и объект
#        без id — не записи)
#   (а)  ни одна пачка mobile/e2e-*/ekran.json не является непустым
#        словарём с ключом ekran, значение которого НЕПУСТАЯ строка;
#        симлинк/путь вне R формой не считается →
#        PUSTOJ_PRODUKT: FORMA_PUSTA
#   (г)  mobile/src отсутствует, сам является симлинком, его realpath
#        вне R или он не содержит подкаталога, внутри которого есть
#        хотя бы один регулярный файл (корневые файлы — контейнеры
#        приложения; симлинки — не содержимое: содержимое принадлежит
#        R; os.walk следует ссылке-КОРНЮ обхода — потому корень и
#        каждый учтённый узел проверяются islink/realpath-внутри-R)
#        → PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO; внешний заполненный
#        src красен этой же причиной, конформный реальный подкаталог
#        с файлом зелён
#   rc 2 — fail-closed (Б2 Crit159b):
#   ошибка ДОСТУПА: PermissionError/иной OSError чтения карты, формы,
#   перечня пачек, листинга R, обхода src (os.walk с onerror ПОДНИМАЕТ
#   ошибку, не молчит) → PUSTOJ_PRODUKT: NECHITAEMO. Отсутствующий
#   файл и битый JSON — структурная пустота rc 1, НЕ «нечитаемо».
#   иначе rc 0 (продукт не пуст; полнота/валидность записи и формы —
#   предмет валидатора 132, не гейта).
#
# Воспроизведение ошибки доступа БЕЗ привилегий (uid, которому chmod
# 000 не мешает, например root): env PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP
# = karta|forma|src поднимает PermissionError в той же точке, где её
# даёт реальный chmod 000 (объявлено контрактом 159; живой гейт несёт
# тот же механизм — иначе равенство с эталоном на d-входах под root
# не проверяемо).
#
# Тип значения проверяется ДО обращения к полям: любой допустимый вход
# даёт именованный отказ БЕЗ исключений.
import json
import os
import stat
import sys

KARTA = os.path.join('mobile', 'ci-screens.json')
SRC = os.path.join('mobile', 'src')

SIMULIRUJ = os.environ.get('PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP', '')


class Nechitaemo(Exception):
    """Ошибка доступа: rc 2 PUSTOJ_PRODUKT: NECHITAEMO, fail-closed."""


def _simuliruj(gde):
    """Подъём отказа доступа в объявленной точке (см. заголовок):
    сразу Nechitaemo — rc 2, тот же исход, что у реального chmod 000."""
    if SIMULIRUJ == gde:
        raise Nechitaemo('симуляция отказа доступа: %s' % gde)


def prinadlezhit(r, put):
    """Узел учитывается как содержимое продукта R: сам НЕ симлинк и
    его realpath внутри realpath R (Б1 Crit159b — корень обхода src,
    карта, форма)."""
    if os.path.islink(put):
        return False
    koren_r = os.path.realpath(r)
    put_r = os.path.realpath(put)
    return put_r == koren_r or put_r.startswith(koren_r + os.sep)


def chita_json(put, gde):
    """Разобранное значение | None. Отсутствует (FileNotFoundError) и
    битый JSON (ValueError) — None, структурная пустота rc 1;
    PermissionError/иной OSError чтения — Nechitaemo rc 2; симуляция
    доступа — ДО реального открытия."""
    _simuliruj(gde)
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except FileNotFoundError:
        return None
    except ValueError:
        return None
    except OSError:
        raise Nechitaemo(put)


def dejstvitelnaja_zapis(z):
    """Запись экранной цели: непустой объект с непустым строковым id."""
    return (isinstance(z, dict) and bool(z)
            and isinstance(z.get('id'), str) and bool(z['id']))


def podnjat_oshibku_obhoda(e):
    """onerror у os.walk: ошибка обхода каталога — не молчаливый
    пропуск подкаталога (Б2 Crit159b), а отказ fail-closed."""
    raise Nechitaemo(str(e))


def soderzhatelnyj_src(r, put):
    """True — в src есть подкаталог с регулярным файлом внутри.

    Корень обхода — не симлинк и realpath внутри R (os.walk
    followlinks=False следует ссылке, переданной корнем); вложенные
    симлинк-каталоги walk не обходит, симлинк-файлы отсеивает islink;
    ошибки обхода поднимает onerror."""
    if not prinadlezhit(r, put):
        return False
    _simuliruj('src')
    if not os.path.isdir(put):
        return False
    pervyj = True
    for koren, _katalogi, fajly in os.walk(put, followlinks=False,
                                           onerror=podnjat_oshibku_obhoda):
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
    try:
        st = os.stat(r)
    except FileNotFoundError:
        return 1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'
    except OSError:
        raise Nechitaemo(r)
    if not stat.S_ISDIR(st.st_mode):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'
    try:
        pusto = not os.listdir(r)
    except OSError:
        raise Nechitaemo(r)
    if pusto:
        return 1, 'PUSTOJ_PRODUKT: KATALOG_PUST'
    put_karty = os.path.join(r, KARTA)
    if not prinadlezhit(r, put_karty):
        karta = None  # карта не своя (симлинк/вне R) — структурная пустота
    else:
        karta = chita_json(put_karty, 'karta')
    if not isinstance(karta, dict):
        # тип — ДО обращения к полям: массив/число/строка/null дают
        # именованный отказ, не AttributeError
        return 1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'
    ekrany = karta.get('ekrany')
    if not isinstance(ekrany, list) \
            or not any(dejstvitelnaja_zapis(z) for z in ekrany):
        return 1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'
    forma_est = False
    md = os.path.join(r, 'mobile')
    try:
        imena = os.listdir(md)
    except FileNotFoundError:
        imena = []
    except OSError:
        raise Nechitaemo(md)
    for imja in sorted(imena):
        if not imja.startswith('e2e-'):
            continue
        katalog_pachki = os.path.join(md, imja)
        if not os.path.isdir(katalog_pachki):
            continue
        put_formy = os.path.join(katalog_pachki, 'ekran.json')
        if not prinadlezhit(r, put_formy):
            continue
        ej = chita_json(put_formy, 'forma')
        if isinstance(ej, dict) and ej:
            ekran = ej.get('ekran')
            if isinstance(ekran, str) and ekran:
                forma_est = True
                break
    if not forma_est:
        return 1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'
    if not soderzhatelnyj_src(r, os.path.join(r, SRC)):
        return 1, 'PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO'
    return 0, ''


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('использование: %s <корень продукта>\n'
                         % sys.argv[0])
        return 2
    try:
        rc, prichina = sudi(sys.argv[1])
    except Nechitaemo:
        rc, prichina = 2, 'PUSTOJ_PRODUKT: NECHITAEMO'
    if prichina:
        print(prichina)
    return rc


if __name__ == '__main__':
    sys.exit(main())
