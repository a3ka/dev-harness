# стаб 138 (s53_bez_stroki, арбитраж 138-2 «стаб-на-защиту»): выключена
# РОВНО одна защита — ветвь кавычек лексера kod_maska (содержимое '…'/"…"
# считается кодом); клетки stroka-odinarnaja и selektor-nositel-v-stroke
# зелёнеют
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def kod_maska(tekst):
    """Копия честного kod_maska БЕЗ ветви кавычек (одна защита, 138-2 C)."""
    out = list(tekst)
    i, n = 0, len(tekst)
    while i < n:
        c = tekst[i]
        if c == '/' and tekst.startswith('//', i):
            while i < n and tekst[i] != '\n':
                out[i] = ' '
                i += 1
        elif c == '/' and tekst.startswith('/*', i):
            sm = tekst[i + 2:].find('*/')
            konec = n if sm < 0 else i + sm + 4
            for k in range(i, konec):
                if tekst[k] != '\n':
                    out[k] = ' '
            i = konec
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
