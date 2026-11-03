#!/usr/bin/env python3
# Негативный образец s8 «собственные клетки ПОСЛЕ отказа гейта» (159,
# уровень проводки; воспроизводит образец own-cells-after-fail
# вердикта Crit159b check_first_action.py: получив rc != 0 гейта,
# проводка ПРОДОЛЖАЕТ работу — исполняет собственную клетку и печатает
# её вывод). Состав: argv[1] — путь гейта, argv[2] — R; гейт вызывается
# честно первым действием (трасса пишется самим гейтом), вывод и rc
# пробрасываются; НО при rc != 0 гейта печатается строка собственной
# клетки — батарея обязана после отказа завершиться, не запуская
# клеток и не печатая ничего помимо причины гейта.
# Демаркация: на конформном продукте rc 0 и ни одной лишней строки
# (честен); дефект наблюдаем на каждом пустом входе: лишняя строка
# после единственной причины — ветка KLETKI_POSLE_OTKAZA.
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        sys.stderr.write('использование: %s <гейт> <корень продукта>\n'
                         % sys.argv[0])
        return 2
    p = subprocess.run(['bash', sys.argv[1], sys.argv[2]],
                       capture_output=True, text=True, timeout=60)
    sys.stdout.write(p.stdout)
    sys.stderr.write(p.stderr)
    if p.returncode != 0:
        # собственная клетка исполнена ПОСЛЕ отказа гейта (дефект)
        print('CASE kletka-posle-otkaza-gejta', flush=True)
    return p.returncode


if __name__ == '__main__':
    sys.exit(main())
