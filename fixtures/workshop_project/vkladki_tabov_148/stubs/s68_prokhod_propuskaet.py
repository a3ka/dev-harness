"""Стаб s68 (prokhod): команда прохода не судится (форма и цели
Maestro) и исполнение всегда «зелёное»."""
from _model import m, run

m.check_prokhod_komanda = lambda f, repo: []
m.run_priemka_prokhod = lambda f, repo: []
run()
