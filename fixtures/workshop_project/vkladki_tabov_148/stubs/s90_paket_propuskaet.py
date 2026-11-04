"""Стаб s90 (paket-1-1, форма): гейт пакета D24-Kompakt-1.1 судьи формы
не судится — возврат пина D 2.4 Final 2 (файлы и sha честны, валидатор
принимает) проходит суд формы (слово владельца 2026-11-02: v+1 пинится
на 1.1; кадры 1.0/D 2.4 к этой сборке не относятся). Дефект наблюдаем
ровно на входе paket-final2 (ветка proverka_paketa судьи формы
model/sud_formy_148.py; Н-39)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'sud_formy_148_stub', HERE.parent / 'model' / 'sud_formy_148.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.proverka_paketa = lambda pack: None
# интерфейс субъекта матрицы — БЕЗ --sud (обёртку честных режимов стабу
# не дают, Н-39): делегат достаётся сам, как у честного судьи --model
argv = sys.argv[:]
if '--sud' not in argv:
    argv[1:1] = ['--sud', str(HERE.parent / 'model' / 'ekran_shablon.py')]
sys.argv = argv
sys.exit(m.main())
