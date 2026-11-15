# Обманный стаб: krug3 — у ВТОРОГО работника вызов сбора спрятан в
# определении невызываемой функции: лексически присутствует, не исполняется.
def mutiruj(koren):
    p = koren / '.github' / 'workflows' / 'mobile.yml'
    tekst = p.read_text(encoding='utf-8')
    nach = tekst.index('  e2e-proba-drugoj:\n')
    kon = tekst.index('  e2e-proba-matrica:\n')
    sek = tekst[nach:kon]
    staryj = ('          set -u\n'
              '          npm run ci:zamer -- sbor \\\n'
              '            --ekran "$ZAMER_EKRAN" --ns "$ZAMER_NS" --serial "$ZAMER_SERIAL" \\\n'
              '            --spool .zamer-$ZAMER_EKRAN --out mobile/zamer-out-$ZAMER_EKRAN\n')
    novyj = ('          set -u\n'
             '          zamer_sbora() {\n'
             '            npm run ci:zamer -- sbor \\\n'
             '              --ekran "$ZAMER_EKRAN" --ns "$ZAMER_NS" --serial "$ZAMER_SERIAL" \\\n'
             '              --spool .zamer-$ZAMER_EKRAN --out mobile/zamer-out-$ZAMER_EKRAN\n'
             '          }\n')
    assert staryj in sek, 'kanonicheskij run sbora (F2) ne najden'
    sek = sek.replace(staryj, novyj, 1)
    p.write_text(tekst[:nach] + sek + tekst[kon:], encoding='utf-8')
