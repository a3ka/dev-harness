# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """сэмплер не остановлен: блок стопа выключен — процесс переживает сбор."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = "  if [ -f \"$SPOOL/pid\" ]; then"
    assert staryj in t
    p.write_text(t.replace(staryj, '  if false; then', 1), encoding='utf-8')
