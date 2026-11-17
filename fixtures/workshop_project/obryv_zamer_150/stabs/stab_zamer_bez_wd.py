# Обманный стаб: krug5 Б1(г) — у ВТОРОГО работника шаг сбора лишился
# явного working-directory: при root defaults.run.working-directory: mobile
# (согласован с продуктом) шаг исполняется из mobile/, пути
# mobile/scripts/… не существует; канон требует явный cwd корня
# (KANON_150_CWD) — шаги замера не зависят ни от каких defaults.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = ("        if: always()\n"
              "        shell: bash\n"
              "        working-directory: ${{ github.workspace }}\n"
              "        env:\n"
              "          ZAMER_EKRAN: proba-drugoj\n")
    novyj = ("        if: always()\n"
             "        shell: bash\n"
             "        env:\n"
             "          ZAMER_EKRAN: proba-drugoj\n")
    assert staryj in sek
    sek = sek.replace(staryj, novyj, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
