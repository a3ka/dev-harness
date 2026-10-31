# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/, не дерево харнесса.
def mutiruj(koren):
    """PEM-редакция только по строке BEGIN: многострочный блок (тело и END)
    остаётся в опубликованном артефакте — исходный дефект канона, пойманный
    критиком 150 круг 1 (блокер 5): sed-замена одной строки BEGIN пропускала
    тело ключа."""
    p = koren / 'mobile' / 'scripts' / 'zamer_obryva.sh'
    t = p.read_text(encoding='utf-8')
    staryj = 'redakt_pem() {'
    novyj = 'redakt_pem() { return 0; #'
    assert staryj in t, 'redakt_pem ne najden'
    p.write_text(t.replace(staryj, novyj, 1), encoding='utf-8')
