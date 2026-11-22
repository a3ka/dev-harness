"""Стаб s101 (porog, форма): инвариант порога сверки не судится —
запись kadry.json с porog=0.5 (валидатор и визуальный суд зелены)
проходит суд формы. Дефект наблюдаем ровно на входе porog-oslablen
(ветка proverka_poroga судьи формы model/sud_formy_148.py; v6, слово
владельца 22.11 «без ослабления порога»; Н-39)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'sud_formy_148_stub', HERE.parent / 'model' / 'sud_formy_148.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.proverka_poroga = lambda pack: None
# интерфейс субъекта матрицы — БЕЗ --sud (Н-39): делегат достаётся сам
argv = sys.argv[:]
if '--sud' not in argv:
    argv[1:1] = ['--sud', str(HERE.parent / 'model' / 'ekran_shablon.py')]
sys.argv = argv
sys.exit(m.main())
