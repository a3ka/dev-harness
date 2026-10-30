# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """замер после остановки: цикл сэмплера мёртв — таймлайна до обрыва нет."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = '  while :; do'
    assert staryj in t
    p.write_text(t.replace(staryj, '  while false; do', 1), encoding='utf-8')
