# стаб 138 (s64_bez_rasshirenij, арбитраж 138-2 «стаб-на-защиту»):
# выключена РОВНО одна защита — белый список расширений RASSHIRENIJA_KODA
# в ekran_kod (p.suffix в списке → True: любой файл сканируется); клетки
# mesto-d-ts/mesto-snap/mesto-ne-kod зелёнеют (метки .d.ts/.snap удалены
# из NE_EKRAN_IMENA как мёртвые — 138-2 п.2, осталась одна причина)
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def ekran_kod(p):
    """Копия честного ekran_kod БЕЗ белого списка расширений (138-2 C)."""
    return (not any(metka in p.name for metka in m.NE_EKRAN_IMENA)
            and not any(katalog in p.parts for katalog in m.NE_EKRAN_KATALOGI))


m.ekran_kod = ekran_kod

if __name__ == '__main__':
    sys.exit(m.main())
