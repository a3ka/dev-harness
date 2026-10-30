#!/usr/bin/env python3
# Стаб-мутатор ekran-minimalnyj (клетка s-pachka-validirovana, блок 1
# Crit149b — дословная атака «продукт без полной v3-пачки»): заменяет
# ekran.json пачки на МИНИМАЛЬНУЮ форму {"shablon","ekran","dvizhenie":
# {"ekrany"}} — без источников dvizhenie, prokhodimost, vtoroj_profil и
# остальных полей v3 (обход Crit149b-mut-ekran-minimal: прежняя клетка
# лекала проверяла лишь shablon/ekran/ekrany и проходила rc 0 83/83).
# Суд пачки ЗАМОРОЖЕННЫМ валидатором 146 (пин 5fd1415e) обязан краснеть;
# клетка-«пропускник» (зелена без суда) оставила бы вход зелёным —
# STAB_ZHIV rc 1 (Н-39: вход — там, где дефект наблюдаем).
import json
import sys

MINIMAL = {
    "shablon": 3,
    "ekran": "gespraech-tekst",
    "dvizhenie": {
        "ekrany": ["GA-11", "GA-12", "GA-13", "GA-17", "GA-18", "GA-19"],
    },
}


def main():
    if len(sys.argv) != 2:
        print('CLI: stab_ekran_minimalnyj.py <корень репо>', file=sys.stderr)
        return 2
    put = sys.argv[1].rstrip('/') + '/mobile/e2e-gespraech-tekst/ekran.json'
    try:
        with open(put, encoding='utf-8') as fh:
            forma = json.load(fh)
    except (OSError, ValueError) as e:
        print('ekran.json не читается: %s' % e, file=sys.stderr)
        return 2
    if forma.get('ekran') != 'gespraech-tekst':
        print('не пачка gespraech-tekst: %r' % forma.get('ekran'),
              file=sys.stderr)
        return 2
    with open(put, 'w', encoding='utf-8') as fh:
        json.dump(MINIMAL, fh, ensure_ascii=False, indent=1)
    return 0


if __name__ == '__main__':
    sys.exit(main())
