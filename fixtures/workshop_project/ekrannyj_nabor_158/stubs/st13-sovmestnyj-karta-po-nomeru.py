#!/usr/bin/env python3
"""Стаб st13-sovmestnyj-karta-po-nomeru (SPEC §7): совместная ветвь двери при
первом вызове номера N считывает карту пачки и записывает её в
sidecar-файл по N; при последующих вызовах того же N берёт карту из
sidecar (кеш живёт между фазами A→B→A — между подпроцессами двери).

Ожидается пойманным на клетке f06-sovmestnyj-karta-iz-fajla: первый вызов
на A даёт честный исход, повтор на B даёт исход кеша (карта A) вместо
rc 1 TSEL_VYKLYUCHENA именем Y. Для M с той же B стаб может работать
честно — его дефект наблюдаем ТОЛЬКО при смене файла карты того же N
(Н-39).

Дефект вшит в ДВЕРЬ ПОДПРОЦЕССОМ (Б-2 ревью 158): копия probe.py с одной
якорной заменой karta_pakety на sidecar-кеш — клетки судят дверь
подпроцессом, стаб подменяет точку запуска двери (Н-39).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

YAKOR = ('def karta_pakety(toy_root, nomer):\n'
         '    """Карта целей экрана NNN — из ФАЙЛА пачки (источник карты — '
         'пачка)."""\n'
         "    put = os.path.join(toy_root, 'pachki', str(nomer), "
         "'karta.json')\n"
         '    try:\n'
         '        with open(put, encoding=\'utf-8\') as fh:\n'
         '            return json.load(fh)\n'
         '    except (OSError, ValueError):\n'
         '        return None\n')
ZAMENA = ('def karta_pakety(toy_root, nomer):\n'
          '    """ДЕФЕКТ (стаб): карта кешируется в sidecar по номеру '
          'экрана."""\n'
          "    sklad = os.path.join(toy_root, 'pachki', str(nomer), "
          "'.karta-st13')\n"
          '    if os.path.isfile(sklad):\n'
          '        with open(sklad, encoding=\'utf-8\') as fh:\n'
          '            return json.load(fh)\n'
          "    put = os.path.join(toy_root, 'pachki', str(nomer), "
          "'karta.json')\n"
          '    try:\n'
          '        with open(put, encoding=\'utf-8\') as fh:\n'
          '            karta = json.load(fh)\n'
          '    except (OSError, ValueError):\n'
          '        return None\n'
          '    try:\n'
          '        with open(sklad, \'w\', encoding=\'utf-8\') as fh:\n'
          '            json.dump(karta, fh, ensure_ascii=False)\n'
          '    except OSError:\n'
          '        pass\n'
          '    return karta\n')

if __name__ == '__main__':
    put = probe.dver_s_zamenoy(YAKOR, ZAMENA, imya='.dver-st13')
    probe.PUT_DVERI = put
    try:
        sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
    finally:
        if os.path.exists(put):
            os.remove(put)
