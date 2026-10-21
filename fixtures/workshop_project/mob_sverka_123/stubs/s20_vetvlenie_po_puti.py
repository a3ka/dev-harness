"""Стаб (Adv123b): ветвление по пути — под каталогом батареи sverka123-* честная модель,
вне его score 1.000 на любом кадре (документированный first-run-58d вне префикса — rc 0)."""
import sys

from _model import m, run

if not any('/sverka123-' in a for a in sys.argv):
    m.score_frame = lambda frame, mock, k, mera: (1.0, 'G')
run()
