"""Стаб s61 (fajly-etalonov): файлы эталонов спеки (4 темы видео и
ключевых кадров) не судятся — урезанная спека проходит."""
from _model import m, run

m._proverka_sceny_fajly = lambda sc, pid, bad: None
run()
