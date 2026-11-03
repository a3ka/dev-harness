#!/usr/bin/env python3
# Негативный образец s4 «батарея без вызова общего гейта» (159,
# уровень проводки; воспроизводит контрпример 1 вердикта Crit159:
# --repo-ветвь проверяет пустоту САМА — вызывает эталон грамматики
# напрямую, минуя scripts/check_pustoj_produkt.sh). Вывод
# поведенчески честен: та же причина первой строкой, тот же rc;
# дефект — общий гейт НЕ вызывается вовсе, трасса гейта не пишется.
# Демаркация: на конформном rc 0, на пустых — честные rc 1 и причина.
import os
import subprocess
import sys

ZDE = os.path.dirname(os.path.abspath(__file__))
ETALON = os.path.abspath(os.path.join(
    ZDE, '..', 'model', 'check_pustoj_produkt_159.py'))


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('использование: %s <корень продукта>\n'
                         % sys.argv[0])
        return 2
    # собственная проверка ТЕМ ЖЕ эталоном вместо общего гейта
    p = subprocess.run([sys.executable, ETALON, sys.argv[1]],
                       capture_output=True, text=True, timeout=60)
    sys.stdout.write(p.stdout)
    sys.stderr.write(p.stderr)
    return p.returncode


if __name__ == '__main__':
    sys.exit(main())
