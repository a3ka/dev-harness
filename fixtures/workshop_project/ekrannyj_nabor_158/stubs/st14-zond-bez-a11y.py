#!/usr/bin/env python3
"""Стаб st14-zond-bez-a11y (SPEC §7): зонд объявляет всякую цель с
`nadpis:null` корректной независимо от имени хозяина и объявления карты —
цель-иконка без доступного имени (или с пустым/пробельным) проходит
зелёной.

Ожидается пойманным на клетках f34-nadpis-a11y-net,
f36-nadpis-null-bez-objavlenija и f37-nadpis-null-pustoe-imja: образцы
обязаны остаться отклонёнными на живой копии — стаб их не видит.

Дефект вшит в шов probe.kopirovat_zond: стаб кладёт в копию референса зонд
с ЯКОРНОЙ заменой ветви цели-иконки (кодом, Н-39). Полная копия хелпера не
заводится: правка хелпера не тянет вторую копию файла.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402

YAKOR = '    const prichina = a11yNadpis(hozjain, tsel, shirina, vysota);\n'
ZAMENA = '    const prichina: string | null = null;\n'

_real_kopirovat_zond = probe.kopirovat_zond


def kopirovat_zond_s_defektom(kopija, helper=None):
    """ДЕФЕКТ: ветвь цели-иконки не сверяет ни объявление карты, ни имя
    хозяина; Text-ветви (видимая надпись) не меняются."""
    cel = _real_kopirovat_zond(kopija, helper=helper)
    put = os.path.join(cel, 'nabor-zond-158.test.tsx')
    with open(put, encoding='utf-8') as fh:
        tekst = fh.read()
    if tekst.count(YAKOR) != 1:
        raise RuntimeError('STAB_YAKOR: якорь ветви цели-иконки найден %d раз'
                           % tekst.count(YAKOR))
    with open(put, 'w', encoding='utf-8') as fh:
        fh.write(tekst.replace(YAKOR, ZAMENA))
    return cel


probe.kopirovat_zond = kopirovat_zond_s_defektom

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
