# Обманный стаб батареи 150: мутация модели КОДОМ (Н-39); привязка к клетке —
# ТОЛЬКО source.json:.stab_vhod. Мутирует копию model/ ХИРУРГИЧЕСКИ (текст
# второй строки — без пересериализации YAML: канон z05 байтовый).
# krug3 (арбитраж 150 П1): у ВТОРОГО работника `true ||` перед сбором —
# правая ветвь не исполняется, журнал сбора пуст; первый работник каноничен.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    kljuch = 'npm run ci:zamer -- sbor'
    assert sek.count(kljuch) == 1, 'kanon vyzova sbora (F2) ne najden'
    sek = sek.replace(kljuch, 'true || ' + kljuch, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
