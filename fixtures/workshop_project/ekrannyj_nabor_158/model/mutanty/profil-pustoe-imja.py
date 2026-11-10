#!/usr/bin/env python3
"""Мутатор набора ekrannyj_nabor_158: клетка f37-nadpis-null-pustoe-imja —
у цели-иконки shell-profile-entry доступное имя хозяина объявлено ПУСТЫМ
(пробельной строкой в отдельной фазе).

РОВНО ОДНА замена (якорь count==1) в одноразовой копии референса.
CLI: <имя>.py <корень-копии-референса> [значение имени]
  значение по умолчанию — пустая строка; фаза с пробельной строкой
  передаётся вторым аргументом (' ').
Код возврата 0 — замена применена; 2 — якорь не найден ровно один раз
(мутатор не применён)."""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _mutator import primenit  # noqa: E402

FAJL = 'mobile/src/bootstrap/tab-shell.tsx'
YAKOR = '        accessibilityLabel={profileLabel}\n'


def main(argv):
    if len(argv) < 2:
        sys.stderr.write('MUTATOR_ARG: нужен корень копии референса\n')
        return 2
    imya = argv[2] if len(argv) > 2 else ''
    return primenit(argv[1], FAJL, YAKOR,
                    '        accessibilityLabel="%s"\n' % imya)


if __name__ == '__main__':
    sys.exit(main(sys.argv))
