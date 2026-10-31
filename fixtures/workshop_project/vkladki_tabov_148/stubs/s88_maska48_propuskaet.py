"""Стаб s88 (maska-48, форма): инвариант ТОЧНОГО значения маски
профиля 393 не судится — манифест с chrome_verh_pt=47 (визуально
зелёный: пилюля выреза закрыта) проходит суд формы (вердикт
Crit148v2, блок 3: точное mera.chrome_verh_pt = 48 независимо от
визуальной меры). Дефект наблюдаем ровно на входе profil-maska-ne-48
(ветка proverka_maski_profilja судьи формы model/sud_formy_148.py;
Н-39)."""
import importlib.util
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
_spec = importlib.util.spec_from_file_location(
    'sud_formy_148_stub', HERE.parent / 'model' / 'sud_formy_148.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)

m.proverka_maski_profilja = lambda pack: None
# интерфейс субъекта матрицы — БЕЗ --sud (обёртку честных режимов стабу
# не дают, Н-39): делегат достаётся сам, как у честного судьи --model
argv = sys.argv[:]
if '--sud' not in argv:
    argv[1:1] = ['--sud', str(HERE.parent / 'model' / 'ekran_shablon.py')]
sys.argv = argv
sys.exit(m.main())
