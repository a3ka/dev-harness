# стаб 138 (s58_bez_kataloga_tests, арбитраж 138-2 «стаб-на-защиту»):
# выключена РОВНО одна защита — '__tests__' исключён из NE_EKRAN_KATALOGI
# (тестовый каталог сканируется как код); клетка mesto-tests (форма 138-2
# __tests__/helper.tsx, одна причина) зелёнеет
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.NE_EKRAN_KATALOGI = frozenset(('__mocks__', '__snapshots__'))

if __name__ == '__main__':
    sys.exit(m.main())
