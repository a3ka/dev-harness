# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """без предела объёма: ограничители файлов/артефакта выключены."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'ogranych() {'
    assert staryj in t
    t = t.replace(staryj, 'ogranych() { return 0; #', 1)
    staryj2 = 'if [ "${razmer_itog:-0}" -gt "$ARTEFAKT_MAKS_BAJT" ]; then'
    assert staryj2 in t
    t = t.replace(staryj2, 'if false; then', 1)
    staryj3 = 'if [ "$razmer" -gt "$FAJL_MAKS_BAJT" ]; then'
    assert staryj3 in t
    t = t.replace(staryj3, 'if false; then', 1)
    p.write_text(t, encoding='utf-8')
