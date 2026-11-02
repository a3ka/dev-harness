#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; перепин опорных флоу 31.10, факт
# Impl147e §4.1): пачку «перепинивают» на СТАРУЮ форму снимка —
# takeScreenshot картой {name: …}. Maestro 2.11.0 такую форму не
# исполняет («Config Field Required: path»; строковая форма работает —
# замер 4/4 Passed), и оба экранных флоу прежней пачки были такой
# формой (флоу прохода снимков не несёт — не трогается). Флоу И пины
# source.json меняются ВМЕСТЕ: это обманный ПЕРЕПИН, а не порча
# носителя (порчу ловит vedro ДО клеток). Такая пачка проходила
# прежнюю батарею целиком — дефект наблюдаем на входе клетки
# s-snimok-strokoj: клетка обязана краснеть SNIMOK_KARTOJ;
# мутант-«пропускник» (клетка зелена без разбора формы) ловится здесь —
# STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import re
import sys
from pathlib import Path

import yaml

z = Path(sys.argv[1])
# снимки живут в двух экранных флоу; проход (prokhod) снимков не несёт
OBIAZATELNO = ('gespraech-vhod.yaml', 'gespraech-vhod-393.yaml')
FLOVY = OBIAZATELNO + ('gespraech-prokhod.yaml',)
KARTA = re.compile(r'^(?P<otp> *)- takeScreenshot: +(?P<imja>\S+)\s*$',
                   re.MULTILINE)


def _kartoj(m):
    return '%s- takeScreenshot:\n%s    name: %s' % (
        m.group('otp'), m.group('otp'), m.group('imja'))


novye = {}
for imja in FLOVY:
    p = z / 'pachka' / imja
    tekst = p.read_text(encoding='utf-8')
    if not KARTA.search(tekst):
        if imja in OBIAZATELNO:
            print('MUTACIJA_NE_NAIDENA: в %s нет строковых takeScreenshot'
                  % imja, file=sys.stderr)
            sys.exit(1)
        continue  # флоу прохода снимков не несёт — не трогаем
    tekst2 = KARTA.sub(_kartoj, tekst)
    # флоу остаётся мастро-формой: тело — список, каждый снимок — карта
    docs = [d for d in yaml.safe_load_all(tekst2) if d is not None]
    if len(docs) < 2:
        print('MUTACIJA_NE_PRIMENIMA: %s без тела после подстановки'
              % imja, file=sys.stderr)
        sys.exit(1)
    shagi = [s for d in docs[1:] for s in d]
    snimki = [s for s in shagi if isinstance(s, dict)
              and 'takeScreenshot' in s]
    if not snimki or not all(isinstance(s['takeScreenshot'], dict)
                             for s in snimki):
        print('MUTACIJA_NE_PRIMENIMA: %s снимки не картой после '
              'подстановки' % imja, file=sys.stderr)
        sys.exit(1)
    p.write_text(tekst2, encoding='utf-8')
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    novye['pachka/' + imja] = h
    novye['mobile/.maestro/' + imja] = h

if not novye:
    print('MUTACIJA_NE_NAIDENA: строкочных takeScreenshot нет ни в одном '
          'флоу', file=sys.stderr)
    sys.exit(1)

s = z / 'source.json'
src = json.loads(s.read_text(encoding='utf-8'))
for kljuch, h in novye.items():
    razdel = 'sha' if kljuch.startswith('pachka/') else 'kanon'
    if kljuch not in src['piny'][razdel]:
        print('MUTACIJA_NE_NAIDENA: пина %s нет' % kljuch,
              file=sys.stderr)
        sys.exit(1)
    src['piny'][razdel][kljuch] = h
s.write_text(json.dumps(src, ensure_ascii=False, indent=1) + '\n',
             encoding='utf-8')
