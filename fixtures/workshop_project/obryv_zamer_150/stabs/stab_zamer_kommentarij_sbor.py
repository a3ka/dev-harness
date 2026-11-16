# Обманный стаб: арбитраж 150 П1 — у ВТОРОГО работника ИСПОЛНЯЕМЫЙ --out
# ведёт в чужой каталог, правильная строка сохранена КОММЕНТАРИЕМ в run
# (with.path и env остаются каноническими): upload грузит пустоту молча.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = ('            --spool .zamer-$ZAMER_EKRAN --out mobile/zamer-out-$ZAMER_EKRAN\n')
    assert sek.count(staryj) == 1
    novyj = ('            --spool .zamer-$ZAMER_EKRAN --out mobile/zamer-out-NEVER\n'
             '            # istoricheskij --out mobile/zamer-out-$ZAMER_EKRAN\n')
    sek = sek.replace(staryj, novyj, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
