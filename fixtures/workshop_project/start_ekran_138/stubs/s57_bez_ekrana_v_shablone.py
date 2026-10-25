# стаб 138 (s57_bez_ekrana_v_shablone, арбитраж 138-2 «стаб-на-защиту»):
# выключено РОВНО одно правило — \-экранирование в ветви бэктика лексера
# kod_maska (шаблон рвётся на первом бэктике, как до 138-2); клетки
# stroka-shablon-ekran-backtick (блокер B1) и -ekran-bekslesh зелёнеют
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def kod_maska(tekst):
    """Копия честного kod_maska: шаблон БЕЗ \-правила — закрытие на
    первом бэктике (одна защита, 138-2 C)."""
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
