#!/usr/bin/env python3
# Обманный стаб батареи 149 (Н-39; перепин опорных флоу 31.10, факт
# стенда Impl149b §1/§4 + урок 147): из всех трёх флоу снимается вход в
# экран — assertVisible first-run-continue + openLink complior://start
# после launchApp. Приложение открывается на корне First-Run: без входа
# ни одна цель экрана недостижима, флоу зависает на первом нажатии.
# Флоу И пины source.json меняются ВМЕСТЕ (обманный ПЕРЕПИН, не порча
# носителя). Такая пачка проходила прежнюю батарею — дефект наблюдаем на
# входе клетки s-vkhod-v-ekran: клетка обязана краснеть VHOD_BEZ_VKHODA;
# мутант-«пропускник» ловится здесь — STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import sys
from pathlib import Path

import yaml

z = Path(sys.argv[1])
FLOVY = ('gespraech-tekst.yaml', 'gespraech-tekst-393.yaml',
         'gespraech-tekst-prokhod.yaml')
VHOD = ('- assertVisible:\n    id: first-run-continue\n'
        '- openLink: complior://start\n')

novye = {}
for imja in FLOVY:
    p = z / 'pachka' / imja
    tekst = p.read_text(encoding='utf-8')
    if tekst.count(VHOD) != 1:
        print('MUTACIJA_NE_NAIDENA: блок входа в %s встречен %d раз'
              % (imja, tekst.count(VHOD)), file=sys.stderr)
        sys.exit(1)
    tekst2 = tekst.replace(VHOD, '', 1)
    # флоу остаётся мастро-формой: тело — список шагов с launchApp
    docs = [d for d in yaml.safe_load_all(tekst2) if d is not None]
    if len(docs) < 2 or not any(s == 'launchApp'
                                for d in docs[1:] for s in d):
        print('MUTACIJA_NE_PRIMENIMA: %s без launchApp после снятия '
              'входа' % imja, file=sys.stderr)
        sys.exit(1)
    p.write_text(tekst2, encoding='utf-8')
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    novye['pachka/' + imja] = h
    novye['mobile/.maestro/' + imja] = h

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
