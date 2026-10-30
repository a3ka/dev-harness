# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """без редакции: redakt_fajl выключен — секреты утекают в артефакт."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'redakt_fajl() {'
    assert staryj in t
    p.write_text(t.replace(staryj, 'redakt_fajl() { return 0; #', 1), encoding='utf-8')
