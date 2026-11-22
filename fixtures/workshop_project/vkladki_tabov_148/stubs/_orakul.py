"""Загрузчик стабов 148 (оракул 393): независимый оракул содержания
etalony_safe_area/orakul_soderzhanija.py + патч ветви. Стаб подменяет
свою проверку и запускает честный main() (Н-39; как _produkt.py)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'orakul_soderzhanija_148',
    HERE.parent / 'etalony_safe_area' / 'orakul_soderzhanija.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def run():
    sys.exit(m.main())
