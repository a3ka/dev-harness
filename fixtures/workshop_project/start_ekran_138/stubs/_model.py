"""Загрузчик стабов 138: модель-эталон — замороженный эталон 132
(ekran_shablon_132/model/ekran_shablon.py, читается не копируется) + патч
ветви. Стаб импортирует эталон, подменяет ИМЕННО свою ветку (функцию
проверки) и запускает честный main() — на чужих входах ведёт себя честно
(Н-39: дефект стаба наблюдаем на входе его записи stab_vhod в source.json)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'et_model_138',
    HERE.parent.parent / 'ekran_shablon_132' / 'model' / 'ekran_shablon.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)


def run():
    sys.exit(m.main())
