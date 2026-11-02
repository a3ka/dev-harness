#!/usr/bin/env python3
# Обманный стаб батареи 149 (Н-39; сверка состояний кадров с макетом
# D 2.4, 31.10): в обоих экранных флоу снимок GA-13 возвращается на
# ДО-отправочную форму — из флоу снимается отправка (tapOn
# gespraech-otpravit + assertVisible gespraech-soobschenie-polzovatel +
# assertNotVisible чипа), снимок остаётся сразу после ввода текста.
# Макет GA-13 (манифест D 2.4): «Schreiben · iOS-Tastatur offen», в ленте
# — карточка фактов «Aus unserem Gespräch» и следующий вопрос агента —
# следствие ОТПРАВЛЕННОГО сообщения; макетный кадр ПОСЛЕ отправки
# (отправленная реплика + карточка фактов — факт Impl149b §4 п.2), поле
# несёт НОВЫЙ текст. Флоу И пины source.json меняются ВМЕСТЕ (обманный
# ПЕРЕПИН, не порча носителя). Такая пачка проходила прежнюю батарею —
# дефект наблюдаем на входе клетки s-ga13-posle-otpravki: клетка обязана
# краснеть GA13_DO_OTPRAVKI; мутант-«пропускник» ловится здесь —
# STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import sys
from pathlib import Path

import yaml

z = Path(sys.argv[1])
FLOVY = ('gespraech-tekst.yaml', 'gespraech-tekst-393.yaml')
# отправка: нажатие «Nachricht senden», наблюдение реплики в ленте,
# уход отвеченных чипов (390-флоу несёт и assertNotVisible чипа)
OTPRAVKA = ('- tapOn:\n    id: gespraech-otpravit\n'
            '- assertVisible:\n    id: gespraech-soobschenie-polzovatel\n')
CHIP = '- assertNotVisible:\n    id: gespraech-chip-gekauft\n'

novye = {}
for imja in FLOVY:
    p = z / 'pachka' / imja
    tekst = p.read_text(encoding='utf-8')
    if tekst.count(OTPRAVKA) != 1:
        print('MUTACIJA_NE_NAIDENA: блок отправки в %s встречен %d раз'
              % (imja, tekst.count(OTPRAVKA)), file=sys.stderr)
        sys.exit(1)
    tekst2 = tekst.replace(OTPRAVKA, '', 1).replace(CHIP, '', 1)
    # флоу остаётся мастро-формой: тело — список, снимок GA-13 на месте
    docs = [d for d in yaml.safe_load_all(tekst2) if d is not None]
    if len(docs) < 2:
        print('MUTACIJA_NE_PRIMENIMA: %s без тела после снятия '
              'отправки' % imja, file=sys.stderr)
        sys.exit(1)
    shagi = [s for d in docs[1:] for s in d]
    snimok = 'gespraech-tekst-ga-13' + (
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
