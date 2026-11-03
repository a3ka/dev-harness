#!/usr/bin/env python3
# Негативный образец s7 «побочный эффект ДО вызова гейта» (159,
# уровень проводки; воспроизводит образец early-action вердикта
# Crit159b check_first_action.py: проводка пишет файл ВНЕ продукта,
# но в дереве прогона, до действительного вызова гейта). Состав:
# argv[1] — путь гейта, argv[2] — корень продукта R; файл пишется в
# dirname(R); гейт ЗАТЕМ вызывается честно (трасса пишется самим
# гейтом), вывод пробрасывается, rc пробрасывается.
# Демаркация: на конформном продукте rc 0 (rc-поведение честно);
# дефект наблюдаем на каждом пустом входе: дерево прогона меняется до
# записи трассы — ветка POBOCHNYJ_EFFEKT (снимок всего дерева прогона
# до/после, а не только продукта).
import os
import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        sys.stderr.write('использование: %s <гейт> <корень продукта>\n'
                         % sys.argv[0])
        return 2
    gate, r = sys.argv[1], sys.argv[2]
    # побочный эффект ДО вызова гейта (образец early-action Crit159b);
    # имя уникально входу — эффект обязан быть НОВЫМ относительно
    # снимка «до», а не перезаписью существующего
    svidetel = os.path.join(
        os.path.dirname(os.path.abspath(r)),
        'pobochnyj-effekt-do-gejta-' + os.path.basename(
            os.path.abspath(r)))
    with open(svidetel, 'w') as fh:
        fh.write('early\n')

    p = subprocess.run(['bash', gate, r], capture_output=True,
                       text=True, timeout=60)
    sys.stdout.write(p.stdout)
    sys.stderr.write(p.stderr)
    return p.returncode


if __name__ == '__main__':
    sys.exit(main())
