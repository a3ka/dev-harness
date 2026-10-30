"""Загрузчик стабов 148 (продукт): продукт-судья produkt_sud.py + патч
ветви. Стаб подменяет свою проверку и запускает честный main() (Н-39)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'produkt_sud_148', HERE.parent / 'produkt_sud.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def run():
    sys.exit(m.main())
