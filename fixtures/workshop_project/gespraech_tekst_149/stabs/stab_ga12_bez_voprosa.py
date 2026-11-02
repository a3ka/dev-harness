#!/usr/bin/env python3
# Обманный стаб батареи 149 (Н-39; сверка состояний кадров с макетом
# D 2.4, 31.10): из обоих экранных флоу снимаются наблюдения состояния
# GA-12 — assertVisible gespraech-vopros-agenta и assertVisible
# gespraech-chip-gekauft между выбором темы и снимком GA-12. Макет GA-12
# (манифест D 2.4, заголовок кадра): «Plakette «Neues Auto» → Thema im
# Verlauf, Complior fragt zuerst · Antwort-Chips und «Lieber erzählen?»
# kommen zusammen»; замороженный текст называет GA-12 «темой в Verlauf с
# вопросом агента и чипами» — снимок темы-строки БЕЗ вопроса и чипов
# снимает НЕ состояние кадра (факт Impl149b §4 п.2). Флоу И пины
# source.json меняются ВМЕСТЕ (обманный ПЕРЕПИН, не порча носителя).
# Такая пачка проходила прежнюю батарею — дефект наблюдаем на входе
# клетки s-ga12-s-voprosom: клетка обязана краснеть GA12_BEZ_VOPROSA;
# мутант-«пропускник» ловится здесь — STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import sys
from pathlib import Path

import yaml

z = Path(sys.argv[1])
FLOVY = ('gespraech-tekst.yaml', 'gespraech-tekst-393.yaml')
BLOK = ('- assertVisible:\n    id: gespraech-vopros-agenta\n'
        '- assertVisible:\n    id: gespraech-chip-gekauft\n')

novye = {}
for imja in FLOVY:
    p = z / 'pachka' / imja
    tekst = p.read_text(encoding='utf-8')
    if tekst.count(BLOK) != 1:
        print('MUTACIJA_NE_NAIDENA: блок вопроса/чипов GA-12 в %s '
              'встречен %d раз' % (imja, tekst.count(BLOK)),
              file=sys.stderr)
        sys.exit(1)
    tekst2 = tekst.replace(BLOK, '', 1)
    # флоу остаётся мастро-формой: тело — список, снимок GA-12 на месте
    docs = [d for d in yaml.safe_load_all(tekst2) if d is not None]
    if len(docs) < 2:
        print('MUTACIJA_NE_PRIMENIMA: %s без тела после снятия '
              'наблюдений' % imja, file=sys.stderr)
        sys.exit(1)
    shagi = [s for d in docs[1:] for s in d]
    snimok = 'gespraech-tekst-ga-12' + (
        '' if imja == 'gespraech-tekst.yaml' else '-393')
    if not any(isinstance(s, dict) and s.get('takeScreenshot') == snimok
               for s in shagi):
        print('MUTACIJA_NE_PRIMENIMA: %s без снимка %s после снятия'
              % (imja, snimok), file=sys.stderr)
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
