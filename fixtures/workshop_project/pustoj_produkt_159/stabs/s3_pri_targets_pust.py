#!/usr/bin/env python3
# Обманный вариант s3 «пустой продукт принят при targets:[]» (159).
# Форма: гейт, вычисливший честные ветви каталога/формы/корня, но
# принимающий карту без целей: ветвь ekrany отсутствует/пуста НЕ
# краснеет (молча rc 0 дальше). Расхождение с честным гейтом — ровно
# на входе (в) karta-bez-celej: честный даёт KARTA_BEZ_CELEJ rc 1,
# этот вариант — rc 0.
# Валидность: на конформном продукте rc 0; на остальных пустых входах
# красен теми же именами, что честный гейт.
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
    # ветвь карты СОЗНАТЕЛЬНО не судит пустоту ekrany (дефект варианта)
    forma_est = False
    for p in glob.glob(os.path.join(r, 'mobile', 'e2e-*', 'ekran.json')):
        ej = chita_json(p)
        if isinstance(ej, dict) and ej and isinstance(ej.get('ekran'), str):
            forma_est = True
            break
    if not forma_est:
        print('PUSTOJ_PRODUKT: FORMA_PUSTA')
        return 1
    put_src = os.path.join(r, 'mobile', 'src')
    if not os.path.isdir(put_src) or not any(
            os.path.isdir(os.path.join(put_src, i))
            for i in os.listdir(put_src)):
        print('PUSTOJ_PRODUKT: KOREN_BEZ_SODERZHIMOGO')
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
