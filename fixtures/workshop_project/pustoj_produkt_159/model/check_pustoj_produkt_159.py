#!/usr/bin/env python3
# ЭТАЛОН гейта пустого продукта (контракт 159). Живая реализация —
# scripts/check_pustoj_produkt.sh (зона implementer); грамматика —
# ЕДИНЫЙ источник этот файл: живой гейт обязан давать те же rc и ту же
# именованную причину на каждом входе домена (судит батарея 159 в
# безфлаговом режиме, клетка s-gate-raven-etalonu).
#
# Домен «пустой продукт» (четыре формы слова владельца 2026-11-03,
# старшинство причин — ровно одно имя на вход):
#   (б2) R не существует или не каталог      → PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET
#   (б1) R существует, но пуст (нет записей) → PUSTOJ_PRODUKT: KATALOG_PUST
#   (в)  карта mobile/ci-screens.json отсутствует/не словарь/ekrany не
#        непустой список записей (продукт без целей) → PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ
#   (а)  ни одна пачка mobile/e2e-*/ekran.json не является непустым
#        словарём с ключом ekran  → PUSTOJ_PRODUKT: FORMA_PUSTA
#   (г)  mobile/src отсутствует или не содержит ни одного подкаталога
#        (один лишь корневой компонент без содержимого)
#        → PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO
#   иначе rc 0 (продукт не пуст; полнота/валидность формы — предмет
#   валидатора 132, не гейта).
#
# Коды возврата: 0 — продукт не пуст; 1 — пустой продукт, причина
# единственной строкой stdout; 2 — нечем проверять, fail-closed.
import glob
import json
import os
import sys

KARTA = os.path.join('mobile', 'ci-screens.json')
SRC = os.path.join('mobile', 'src')


def chita_json(put):
    """Словарь | None. Битый JSON == отсутствует (пустой продукт)."""
    try:
        with open(put, encoding='utf-8') as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return None


def sudi(r):
    """(rc, prichina). Ровно одно имя на вход, по старшинству."""
    if not os.path.isdir(r):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_OTSUTSTVUET'
    if not os.listdir(r):
        return 1, 'PUSTOJ_PRODUKT: KATALOG_PUST'
    karta = chita_json(os.path.join(r, KARTA))
    ekrany = (karta or {}).get('ekrany')
    if not isinstance(karta, dict) or not isinstance(ekrany, list) \
            or not ekrany:
        return 1, 'PUSTOJ_PRODUKT: KARTA_BEZ_CELEJ'
    forma_est = False
    for p in glob.glob(os.path.join(r, 'mobile', 'e2e-*', 'ekran.json')):
        ej = chita_json(p)
        if isinstance(ej, dict) and ej and isinstance(ej.get('ekran'), str):
            forma_est = True
            break
    if not forma_est:
        return 1, 'PUSTOJ_PRODUKT: FORMA_PUSTA'
    put_src = os.path.join(r, SRC)
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
    rc, prichina = sudi(sys.argv[1])
    if prichina:
        print(prichina)
    return rc


if __name__ == '__main__':
    sys.exit(main())
