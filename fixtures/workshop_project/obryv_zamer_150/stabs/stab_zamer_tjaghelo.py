# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """тяжёлый сэмплер: 20 Гц и проба гостя каждые 3 с — сам нагружает раннер."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'PROBA_KAZHDYH=15'
    assert staryj in t
    t = t.replace(staryj, 'PROBA_KAZHDYH=3', 1)
    staryj2 = '    sleep 1'
    assert staryj2 in t
    t = t.replace(staryj2, '    sleep 0.05', 1)
    p.write_text(t, encoding='utf-8')
