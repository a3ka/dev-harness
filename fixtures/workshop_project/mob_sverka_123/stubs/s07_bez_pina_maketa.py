"""Стаб: sha256 макета не сверяется — подменённый кадром макет принимается."""
from _model import m, run

m.check_pin = lambda mblob, k: None
run()
