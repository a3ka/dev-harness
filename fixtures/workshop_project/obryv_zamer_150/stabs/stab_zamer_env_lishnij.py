# Обманный стаб: управляющее окружение env — у ВТОРОГО работника шаг
# сбора несёт лишний ключ env (переопределение путей): канон env —
# закрытое множество ZAMER_EKRAN/ZAMER_NS/ZAMER_SERIAL (KANON_150_ENV).
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = ("        env:\n"
              "          ZAMER_EKRAN: proba-drugoj\n"
              "          ZAMER_NS: mobile/maestro-out-drugoj\n"
              "          ZAMER_SERIAL: emulator-5573\n"
              "        run: |\n"
              "          set -u\n"
              "          npm run ci:zamer -- sbor")
    novyj = ("        env:\n"
             "          ZAMER_EKRAN: proba-drugoj\n"
             "          ZAMER_NS: mobile/maestro-out-drugoj\n"
             "          ZAMER_SERIAL: emulator-5573\n"
             "          ZAMER_OUT: mobile/zamer-out-DRUGOJ-NE-TOT\n"
             "        run: |\n"
             "          set -u\n"
             "          npm run ci:zamer -- sbor")
    assert staryj in sek
    sek = sek.replace(staryj, novyj, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
