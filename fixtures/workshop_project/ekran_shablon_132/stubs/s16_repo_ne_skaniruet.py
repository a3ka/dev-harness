"""Стаб s16 (repo-ne-skaniruet): живые пачки ищутся только в харнессе —
живая пачка в переданном продукте (--repo) невидима полноте объявлений
(обход круга 2: замена неполна молча)."""
from _model import m, run

m.zhivye_pachty = lambda harness, repo, pack: m._zhivye_v_korne(harness, pack)
run()
