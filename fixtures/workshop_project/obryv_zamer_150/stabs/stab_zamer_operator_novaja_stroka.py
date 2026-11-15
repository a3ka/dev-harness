# Обманный стаб: krug4 — у ВТОРОГО работника `true ||` и перевод строки
# перед сбором: настоящий bash пропускает правую команду (перенос после
# незавершённого оператора условность не снимает); первый работник каноничен.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    kljuch = 'npm run ci:zamer -- sbor'
    assert sek.count(kljuch) == 1
    sek = sek.replace(kljuch, 'true ||\n' + ' ' * 12 + kljuch, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
