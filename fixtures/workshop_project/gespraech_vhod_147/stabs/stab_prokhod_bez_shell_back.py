#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; перепин опорных флоу 31.10, факт
# Impl147e §4.3): из флоу прохода снимается возврат из профиля —
# нажатие shell-back между наблюдением профиля и первым переключением
# вкладки. Закреплённая проба 999 (PROFILE_SECONDARY_NOT_TAB) требует,
# чтобы вкладок в профиле НЕ было: нажатие shell-tab-start сразу после
# профиля недостижимо, флоу зависает. Флоу И пины source.json меняются
# ВМЕСТЕ (обманный ПЕРЕПИН, не порча носителя). Такая пачка проходила
# прежнюю батарею — дефект наблюдаем на входе клетки s-profil-vozvrat:
# клетка обязана краснеть PROFIL_BEZ_VOZVRATA; мутант-«пропускник»
# ловится здесь — STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import sys
from pathlib import Path

import yaml

z = Path(sys.argv[1])
p = z / 'pachka' / 'gespraech-prokhod.yaml'
tekst = p.read_text(encoding='utf-8')
BLOK = '- tapOn:\n    id: shell-back\n'
if tekst.count(BLOK) != 1:
    print('MUTACIJA_NE_NAIDENA: возврат shell-back встречен %d раз'
          % tekst.count(BLOK), file=sys.stderr)
    sys.exit(1)
tekst2 = tekst.replace(BLOK, '', 1)
# флоу остаётся мастро-формой: тело — список шагов с нажатием вкладки
docs = [d for d in yaml.safe_load_all(tekst2) if d is not None]
if len(docs) < 2:
    print('MUTACIJA_NE_PRIMENIMA: нет тела после снятия shell-back',
          file=sys.stderr)
    sys.exit(1)
shagi = [s for d in docs[1:] for s in d]
if not any(isinstance(s, dict) and isinstance(s.get('tapOn'), dict)
           and s['tapOn'].get('id') == 'shell-tab-start' for s in shagi):
    print('MUTACIJA_NE_PRIMENIMA: после снятия shell-back нет нажатия '
          'вкладки', file=sys.stderr)
    sys.exit(1)
p.write_text(tekst2, encoding='utf-8')
h = hashlib.sha256(p.read_bytes()).hexdigest()
s2 = z / 'source.json'
src = json.loads(s2.read_text(encoding='utf-8'))
for kljuch in ('pachka/gespraech-prokhod.yaml',
               'mobile/.maestro/gespraech-prokhod.yaml'):
    razdel = 'sha' if kljuch.startswith('pachka/') else 'kanon'
    if kljuch not in src['piny'][razdel]:
        print('MUTACIJA_NE_NAIDENA: пина %s нет' % kljuch,
              file=sys.stderr)
        sys.exit(1)
    src['piny'][razdel][kljuch] = h
s2.write_text(json.dumps(src, ensure_ascii=False, indent=1) + '\n',
              encoding='utf-8')
