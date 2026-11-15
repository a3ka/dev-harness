# Обманный стаб: krug5 Б1(в) — у ВТОРОГО работника шаг сбора несёт
# `if: ${{ always() && false }}`: раннер пропускает шаг ВСЕГДА (сбор
# теряется на любом исходе); канон требует if: always() (KANON_150_IF).
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = ("      - name: 'Замер обрыва: сбор причинного снимка (150)'\n"
              "        if: always()\n")
    novyj = ("      - name: 'Замер обрыва: сбор причинного снимка (150)'\n"
             "        if: ${{ always() && false }}\n")
    assert staryj in sek
    sek = sek.replace(staryj, novyj, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
