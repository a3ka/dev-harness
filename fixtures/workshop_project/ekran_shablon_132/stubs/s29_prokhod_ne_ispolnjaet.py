"""Стаб s29 (nazhatie-bez-izmenenija): проход Maestro не исполняется —
команда priemka.prokhod не запускается, её rc не судится; нажатие без
наблюдаемого изменения проходит незаметно."""
from _model import m, run

m.run_priemka_prokhod = lambda f, repo: []
run()
