"""Общая механика мутаторов набора ekrannyj_nabor_158: одна якорная замена."""
import os
import sys


def primenit(korn, fajl, yakor, zamena):
    put = os.path.join(korn, fajl)
    with open(put, encoding='utf-8') as fh:
        tekst = fh.read()
    if tekst.count(yakor) != 1:
        sys.stderr.write('MUTATOR_YAKOR: %s: якорь найден %d раз (нужно 1)\n'
                         % (fajl, tekst.count(yakor)))
        return 2
    with open(put, 'w', encoding='utf-8') as fh:
        fh.write(tekst.replace(yakor, zamena))
    return 0
