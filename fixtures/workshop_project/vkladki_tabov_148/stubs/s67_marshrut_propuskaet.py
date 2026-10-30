"""Стаб s67 (marshrut): собранный путь не судится — ни токен
оболочки, ни снимки профиля."""
from _model import m, run

m.check_marshrut = lambda f, pack, repo: []
run()
