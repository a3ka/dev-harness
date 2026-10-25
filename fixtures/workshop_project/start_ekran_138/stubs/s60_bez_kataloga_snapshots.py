# стаб 138 (s60_bez_kataloga_snapshots, арбитраж 138-2 «стаб-на-защиту»):
# выключена РОВНО одна защита — '__snapshots__' исключён из
# NE_EKRAN_KATALOGI; клетка mesto-snapshots (форма 138-2 __snapshots__/
# f.tsx — расширение кода, одна причина) зелёнеет
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.NE_EKRAN_KATALOGI = frozenset(('__tests__', '__mocks__'))

if __name__ == '__main__':
    sys.exit(m.main())
