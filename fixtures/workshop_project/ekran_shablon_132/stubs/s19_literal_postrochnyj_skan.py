"""Стаб s19 (literal-postrochnyj-skan): сверка литералов ПОСТРОЧНО, маска
дайджеста — любой hex-набор 16+ по одной длине, БЕЗ требования буквы a–f
(реализация эталона круга 3 дословно). Дефект наблюдаем на входах записи
stab_vhod source.json: перенос строки внутри функциональной записи
(А1) и числа из ведущих нулей — размер (А2) и аргументы функции (А3) —
построчный скан либо маска по длине пропускают (арбитраж 132 А1–А3)."""
import re

from _model import m, run

_STARYJ_ZHIST = re.compile(r'[0-9a-fA-F]{16,}')


def _check_literal_postrochno(pack):
    bad = []
    for p in sorted(pack.rglob('*')):
        if not p.is_file():
            continue
        try:
            tekst = p.read_text(encoding='utf-8')
        except (OSError, UnicodeDecodeError):
            continue
        for i, line in enumerate(tekst.splitlines(), 1):
            zaslon = _STARYJ_ZHIST.sub(' ', line)
            if m.RE_CVET.search(zaslon) or m.RE_RAZMER.search(zaslon):
                bad.append(m.otkaz('LITERAL_VNE_AUDITA',
                                   '%s:%d' % (p.relative_to(pack), i)))
                break
    return bad


m.check_literal = _check_literal_postrochno
run()
