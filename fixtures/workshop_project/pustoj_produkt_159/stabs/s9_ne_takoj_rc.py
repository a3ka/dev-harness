#!/usr/bin/env python3
# Негативный образец s9 «не тот rc на пустом входе» (159, уровень
# проводки; воспроизводит образец wrong-return вердикта Crit159b
# check_first_action.py: гейт ДЕЙСТВИТЕЛЬНО вызван (трасса пишется
# самим гейтом), причина честна первой строкой, но проводка выходит
# rc 3 вместо обязательного rc 1 — судья проводки принимал любой код
# кроме 0 и 2). Состав: argv[1] — путь гейта, argv[2] — R; вывод
# пробрасывается; при отказе гейта (rc != 0) выход rc 3.
# Демаркация: на конформном продукте rc 0 (честен); дефект наблюдаем
# на каждом пустом входе: rc 3 при честных причине и трассе — ветка
# RC_NE_1 (домен rc: 0 конформный, 1 пуст, 2 нечитаемо fail-closed,
# иное — красно).
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
    if p.returncode == 0:
        return 0
    return 3


if __name__ == '__main__':
    sys.exit(main())
