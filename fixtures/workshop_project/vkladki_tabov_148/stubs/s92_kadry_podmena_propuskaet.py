"""Стаб s92 (kadry-podmenen, форма): гейт соответствия имени кадра
записи её идентификатору судьи формы не судится — пин «GA-02 dark» на
соседний кадр ТОГО ЖЕ пакета (GA-04_normal_dark_390x844.png, файл и sha
из SHA256SUMS честны, валидатор зелён — членство есть, соответствия нет)
проходит суд формы (вердикт Crit148k2a Б1). Дефект наблюдаем ровно на
входе kadry-podmenen (ветка proverka_imen_kadrov судьи формы
model/sud_formy_148.py; Н-39)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'sud_formy_148_stub', HERE.parent / 'model' / 'sud_formy_148.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.proverka_imen_kadrov = lambda pack: None
# интерфейс субъекта матрицы — БЕЗ --sud (обёртку честных режимов стабу
# не дают, Н-39): делегат достаётся сам, как у честного судьи --model
argv = sys.argv[:]
if '--sud' not in argv:
    argv[1:1] = ['--sud', str(HERE.parent / 'model' / 'ekran_shablon.py')]
sys.argv = argv
sys.exit(m.main())
