#!/usr/bin/env python3
# Обманный вариант s2 «пустота определена только по ekran.json» (159).
# Форма: гейт, судящий ТОЛЬКО формы пачек — красен, когда НАЙДЕНА пустая
# форма mobile/e2e-*/ekran.json; пустой каталог, отсутствующая карта
# без целей и корень без содержимого проходят молча (rc 0) — расхождение
# с честным гейтом на конформных пустых входах (б1/б2/в/г).
# Валидность: на конформном продукте rc 0 (честен), на входе (а) красен
# как честный — дефект наблюдаем ровно на остальных пустых входах.
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
    for p in glob.glob(os.path.join(r, 'mobile', 'e2e-*', 'ekran.json')):
        ej = chita_json(p)
        if isinstance(ej, dict) and ej \
                and isinstance(ej.get('ekran'), str):
            continue
        print('PUSTOJ_PRODUKT: FORMA_PUSTA')
        return 1
    # каталог/карта/компоненты не судятся вовсе
    return 0


if __name__ == '__main__':
    sys.exit(main())
