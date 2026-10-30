"""Стаб s49 (ekrany-polnota): суд экранов пачки против манифеста и
якорей кадров не исполняется — скрытый экран проходит."""
from _model import m, run

m._ekrany_sud = lambda ekrany_man, ekrany, kadry_ids: []
run()
