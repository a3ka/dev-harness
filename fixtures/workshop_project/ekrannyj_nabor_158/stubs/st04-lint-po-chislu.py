#!/usr/bin/env python3
"""Стаб st04-lint-po-chislu (SPEC §7): линт принимает литерал, если его
число РАВНО значению токена (структурная связь не проверяется).

Ожидается пойманным на клетках c01-literal-nav-height и
c04-ravnoe-chislo-bez-svjazi: литерал в месте токена остаётся незамеченным —
исход стаба расходится с эталонным (эталон — красный, стаб — зелёный).

Дефект вшит в шов probe.lint_tokena (кодом, Н-39).
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import probe  # noqa: E402


def lint_po_chislu(fajl, tokeny):
    """ДЕФЕКТ: литерал, равный значению токена, принимается."""
    with open(fajl, encoding='utf-8') as fh:
        tekst = fh.read()
    narusheniya = []
    for imya, tok in tokeny.items():
        if imya.startswith('_'):
            continue
        link = tok.get('link_prii')
        if not link or re.search(link, tekst):
            continue
        for mesto in tok.get('mesta', []):
            najdeno = False
            for lit in re.finditer(r'\b%s\s*:\s*(\d+(?:\.\d+)?)\b'
                                   % re.escape(mesto), tekst):
                if float(lit.group(1)) == float(tok.get('znachenie', -1)):
                    continue
                najdeno = True
                break
            if najdeno:
                narusheniya.append(imya)
                break
    return narusheniya


probe.lint_tokena = lint_po_chislu

if __name__ == '__main__':
    sys.exit(probe.zapustit_stab_kletku(sys.argv[1:]))
