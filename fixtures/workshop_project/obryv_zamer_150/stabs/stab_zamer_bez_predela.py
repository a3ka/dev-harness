# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """без предела объёма: ограничители файлов/артефакта/сэмплера выключены."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'ogranych() {'
    assert staryj in t, 'ogranych ne najden'
    t = t.replace(staryj, 'ogranych() { return 0; #', 1)
    staryj2 = 'if [ "${razmer_itog:-0}" -gt "$ARTEFAKT_MAKS_BAJT" ]; then'
    assert staryj2 in t, 'potolok artefakta ne najden'
    t = t.replace(staryj2, 'if false; then', 1)
    staryj3 = ('if [ $((razmer + ${#novaja} + 1 + ZAPAS_METKI)) '
               '-gt "$FAJL_MAKS_BAJT" ]; then')
    assert staryj3 in t, 'potolok semplera ne najden'
    t = t.replace(staryj3, 'if false; then', 1)
    p.write_text(t, encoding='utf-8')
