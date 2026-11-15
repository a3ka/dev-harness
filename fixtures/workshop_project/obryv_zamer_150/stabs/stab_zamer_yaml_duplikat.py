# Обманный стаб: гигиена YAML — дубликат ключа env у шага сбора ВТОРОГО
# работника (safe_load молча берёт последний — неоднозначная запись):
# KANON_150_YAML, неоднозначный разбор не принимается.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = ("          ZAMER_SERIAL: emulator-5573\n"
              "        run: |\n"
              "          set -u\n"
              "          npm run ci:zamer -- sbor")
    novyj = ("          ZAMER_SERIAL: emulator-5573\n"
             "        env:\n"
             "          ZAMER_EKRAN: obman-drugoj\n"
             "        run: |\n"
             "          set -u\n"
             "          npm run ci:zamer -- sbor")
    assert staryj in sek
    sek = sek.replace(staryj, novyj, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
