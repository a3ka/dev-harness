"""Загрузка модели 123 для обманных стабов: стаб = модель с ОДНОЙ подменой."""
import importlib.util
import sys
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    'sverka_model_123', Path(__file__).resolve().parents[1] / 'model' / 'sverka_maketa.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def run():
    sys.exit(m.main())
