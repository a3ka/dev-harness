# стаб 138 (s62_bez_imeni_spec, арбитраж 138-2 «стаб-на-защиту»):
# выключена РОВНО одна защита — '.spec.' исключён из NE_EKRAN_IMENA;
# клетка mesto-spec-fajl (f.spec.tsx без каталога) зелёнеет
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'proverka_138', HERE.parent / 'teksty' / 'proverka_text.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.NE_EKRAN_IMENA = ('.test.', '.stories.')

if __name__ == '__main__':
    sys.exit(m.main())
