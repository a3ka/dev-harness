# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """без logcat-кольца: сэмплер жив и пишет таймлайн, но предостановочный
    logcat не читается В ПРОЦЕССЕ работы — после смерти транспорта уже
    поздно (Astra §10; блокер 3 круга 1)."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'KOLCO="$SPOOL/logcat-kolco.txt"'
    novyj = 'KOLCO="/dev/null"'
    assert staryj in t, 'KOLCO ne najden'
    p.write_text(t.replace(staryj, novyj, 1), encoding='utf-8')
