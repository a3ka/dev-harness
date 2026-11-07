#!/usr/bin/env python3
# Негативный образец s5 «вывод в stderr ДО вызова гейта» (159,
# уровень проводки; воспроизводит контрпример 2 вердикта Crit159:
# --repo-ветвь сначала пишет предупреждение в stderr, ЗАТЕМ
# действительно вызывает общий гейт и печатает его причину в stdout).
# Гейт вызывается честно (трасса пишется гейтом), rc пробрасывается;
# дефект — вывод ДО первого действия: строка прибывает раньше записи
# трассы и стоит первой в объединённом потоке.
# Демаркация: на конформном rc 0 (предупреждение остаётся частью
# обмана, rc-поведение честно).
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        sys.stderr.write('использование: %s <гейт> <корень продукта>\n'
                         % sys.argv[0])
        return 2
    sys.stderr.write('EARLY_CHECK_BEFORE_GATE\n')
    sys.stderr.flush()
    p = subprocess.run(['bash', sys.argv[1], sys.argv[2]],
                       capture_output=True, text=True, timeout=60)
    sys.stdout.write(p.stdout)
    sys.stderr.write(p.stderr)
    return p.returncode


if __name__ == '__main__':
    sys.exit(main())
