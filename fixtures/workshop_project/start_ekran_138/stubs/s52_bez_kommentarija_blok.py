# стаб 138 (s52_bez_kommentarija_blok, арбитраж 138-2 «стаб-на-защиту»):
# выключена РОВНО одна защита — ветвь «/* */» лексера kod_maska (блок-
# комментарий считается кодом); клетки kommentarij-blok/-blok-mnogostrochnyj/
# -jsdoc/-jsx/-jsx-mnogostrochnyj зелёнеют
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def kod_maska(tekst):
    """Копия честного kod_maska БЕЗ ветви «/* */» (одна защита, 138-2 C)."""
    out = list(tekst)
    i, n = 0, len(tekst)
    while i < n:
        c = tekst[i]
        if c == '/' and tekst.startswith('//', i):
            while i < n and tekst[i] != '\n':
                out[i] = ' '
                i += 1
        elif c in '\'"':
            nachalo = i
            i += 1
            while i < n:
                if tekst[i] == '\\' and i + 1 < n:
                    i += 2
                    continue
                if tekst[i] in (c, '\n'):
                    break
                i += 1
            if i < n and tekst[i] == c:
                i += 1
            for k in range(nachalo, i):
                if tekst[k] != '\n':
                    out[k] = ' '
        elif c == '`':
            nachalo = i
            i += 1
            while i < n:
                if tekst[i] == '\\' and i + 1 < n:
                    i += 2
                    continue
                if tekst[i] == '`':
                    break
                i += 1
            if i < n:
                i += 1
            for k in range(nachalo, i):
                if tekst[k] != '\n':
                    out[k] = ' '
        else:
            i += 1
    return ''.join(out)


m.kod_maska = kod_maska

if __name__ == '__main__':
    sys.exit(m.main())
