# Обманный стаб: krug1/krug3 — у ВТОРОГО работника with.path артефакта
# ведёт в несуществующий каталог: шаг upload зелёный (if-no-files-found:
# ignore), публикация недоказуема.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = '          path: mobile/zamer-out-proba-drugoj\n'
    assert staryj in sek
    sek = sek.replace(staryj, '          path: mobile/zamer-out-NEVER\n', 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
