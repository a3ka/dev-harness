"""Стаб s73 (e2e): исполнение приёмки e2e не судится — падение
команды и отсутствие кадров проходят зелёно."""
from _model import m, run

m.run_priemka_e2e = lambda f, repo: []
run()
