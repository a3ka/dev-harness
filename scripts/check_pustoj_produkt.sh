#!/usr/bin/env bash
# Гейт пустого продукта (контракт 159, инварианты 1–3): общий отказ по
# признаку ПУСТОТЫ продукта для --repo-ветвей экранных батарей домена
# (147/148/149/151). Одна грамматика на все батареи: причина отказа не
# зависит от экрана.
#
# Грамматика — ЕДИНЫЙ источник: эталон
# fixtures/workshop_project/pustoj_produkt_159/model/check_pustoj_produkt_159.py
# (живой гейт обязан давать те же rc и ту же ИМЕНОВАННУЮ причину на каждом
# входе домена; равенство судит батарея 159). Этот файл — ЖИВАЯ реализация
# той же грамматики: эталон НЕ вызывается (вызов эталона не должен быть
# неотличим от вызова гейта), и гейт не зависит от фикстуры — поэтому
# грамматика живёт в теле гейта (зона implementer — один файл).
#
# Форма вызова: bash scripts/check_pustoj_produkt.sh <корень продукта R>
#
# Коды возврата (домен rc):
#   0 — продукт НЕ пуст (конформный допущен; stdout пуст);
#   1 — структурная пустота: причина на stdout РОВНО одной строкой —
#       PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET (R не существует/не каталог) |
#       KATALOG_PUST (R пуст) | KARTA_BEZ_CELEJ (карта mobile/ci-screens.json
#       отсутствует/битая/не словарь/без действительных записей) |
#       FORMA_PUSTA (ни одна пачка mobile/e2e-*/ekran.json не имеет
#       непустого строкового ключа ekran) | KOREN_BEZ_SODERZHIMOGO
#       (mobile/src отсутствует, симлинк, вне R или без подкаталога с
#       регулярным файлом);
#   2 — fail-closed: отказ доступа (PUSTOJ_PRODUKT: NECHITAEMO на stdout) или
#       нечем проверять (нет python3 — NOT_IMPLEMENTED в stderr).
#
# Ошибка доступа (chmod 000 карты/формы/подкаталога src) — rc 2, а не
# структурная пустота; воспроизведение без привилегий (uid, которому chmod
# 000 не мешает, например root): переменная окружения
# PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP=karta|forma|src поднимает отказ в той же
# точке (механизм эталона и живого гейта совпадает).
#
# Трасса вызова (инвариант 3): при заданной переменной окружения
# PUSTOJ_PRODUKT_TRACE гейт ПЕРВЫМ своим действием, до любых вычислений и
# вывода, дописывает в файл по этому пути ровно одну строку
# «<время-ns> GATE <переданные-аргументы-через-пробел>» и продолжает
# честную работу; трасса не меняет rc и stdout.
set -u

if [ -n "${PUSTOJ_PRODUKT_TRACE:-}" ]; then
  printf '%s GATE %s\n' "$(date +%s%N)" "$*" >> "$PUSTOJ_PRODUKT_TRACE" || exit 2
fi

command -v python3 >/dev/null 2>&1 || {
  printf 'NOT_IMPLEMENTED: нет python3\n' >&2
  exit 2
}

exec python3 - "$@" <<'PUSTOJ_PRODUKT_GRAMMATIKA'
# Грамматика пустоты продукта — живая реализация эталона 159.
import json
import os
import stat
import sys

KARTA = os.path.join('mobile', 'ci-screens.json')
SRC = os.path.join('mobile', 'src')

SIMULIRUJ = os.environ.get('PUSTOJ_PRODUKT_SIMULIRUJ_DOSTUP', '')


class Nechitaemo(Exception):
    """Ошибка доступа: rc 2 PUSTOJ_PRODUKT: NECHITAEMO, fail-closed."""


def simuliruj_dostup(gde):
    """Отказ доступа в объявленной точке (karta|forma|src) — тот же
    исход, что у реального chmod 000."""
    if SIMULIRUJ == gde:
        raise Nechitaemo('симуляция отказа доступа: %s' % gde)


def prinadlezhit(r, put):
    """Узел учитывается как содержимое продукта R: сам НЕ симлинк и его
    realpath внутри realpath R (корень обхода src, карта, форма)."""
    if os.path.islink(put):
        return False
    koren_r = os.path.realpath(r)
    put_r = os.path.realpath(put)
    return put_r == koren_r or put_r.startswith(koren_r + os.sep)


def chita_json(put, gde):
    """Разобранное значение | None. Отсутствующий файл и битый JSON —
    структурная пустота (None); отказ доступа — Nechitaemo (rc 2)."""
    simuliruj_dostup(gde)
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
    """Действительная запись экрана: непустой объект с непустым строковым
    id (null, "" и объект без id — не записи)."""
    return (isinstance(z, dict) and bool(z)
            and isinstance(z.get('id'), str) and bool(z['id']))


def podnjat_oshibku_obhoda(e):
    """onerror обхода: ошибка обхода каталога — отказ fail-closed, а не
    молчаливый пропуск подкаталога."""
    raise Nechitaemo(str(e))


def soderzhatelnyj_src(r, put):
    """True — в src есть подкаталог с регулярным файлом внутри (корневые
    файлы — контейнеры приложения, симлинки — не содержимое)."""
    if not prinadlezhit(r, put):
        return False
    simuliruj_dostup('src')
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
    """(rc, причина). Ровно одно имя на вход, по старшинству."""
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
        # именованный отказ, а не исключение
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


sys.exit(main())
PUSTOJ_PRODUKT_GRAMMATIKA
