# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """без фиксации завершения: таймлайн пишется, но смерть эмулятора не
    фиксируется (emulator-exit.txt пуст) — «exit» п.2 решения владельца
    потерян при живом сэмплере (блокер 3 круга 1)."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'EXITF="$SPOOL/emulator-exit.txt"'
    novyj = 'EXITF="/dev/null"'
    assert staryj in t, 'EXITF ne najden'
    p.write_text(t.replace(staryj, novyj, 1), encoding='utf-8')
