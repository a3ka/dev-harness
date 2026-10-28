"""Стаб s38 (profil-kadr-nizhe-poroga): сверка второго профиля не
исполняется — валидатор не вызывает раннер 123 по манифесту профиля;
кадр собранного пути ниже порога проходит незамеченным (фиктивная
сверка профиля)."""
from _model import m, run

m.run_sverka_profil = lambda f, pack, repo, harness: []
run()
