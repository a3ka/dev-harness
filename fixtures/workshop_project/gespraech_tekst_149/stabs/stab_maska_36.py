#!/usr/bin/env python3
# Обманный стаб батареи 149 (Н-39, v+1 цикл 2, вердикт Crit149k2a класс
# МАСКА_ПРОФИЛЯ_393): манифест кадров профиля 393 в КОПИИ A-дерева
# возвращается к маске 36 pt (mera.chrome_verh_pt и верх «ekran»-
# элемента ВСЕХ 12 кадров) вопреки утверждённой владельцем маске 48 pt
# (вырез камеры, решение 31.10; урок суда 147 цикла 2: визуальная мера
# 36/47/49 зелёна — значение судится ТОЧНО). Дефект наблюдаем на входе
# клетки s-profil-maska-393: суд значения обязан краснеть
# PROFIL_MASKA_NE_48 независимо от счёта кадров; мутант-«пропускник»
# (клетка зелена при 36) ловится здесь — STAB_ZHIV rc 1.
# argv[1] — каталог копии A-дерева.
import json
import sys
from pathlib import Path

d = Path(sys.argv[1])
p = d / 'mobile' / 'e2e-gespraech-tekst' / 'kadry-393.json'
m = json.loads(p.read_text(encoding='utf-8'))
if m.get('mera', {}).get('chrome_verh_pt') != 48:
    print('MUTACIJA_NE_NAIDENA: mera.chrome_verh_pt != 48 (не зелёный '
          'вход)', file=sys.stderr)
    sys.exit(1)
m['mera']['chrome_verh_pt'] = 36
zamenen = 0
for k in m['kadry']:
    ekran = k['elementy'][0]
    if ekran.get('imja') == 'ekran' and ekran['bbox_pt'][1] == 48:
        ekran['bbox_pt'][1] = 36
        zamenen += 1
if zamenen != 12:
    print('MUTACIJA_NE_NAIDENA: ekran-элементов с верхом 48 — %d (ждали 12)'
          % zamenen, file=sys.stderr)
    sys.exit(1)
p.write_text(json.dumps(m, ensure_ascii=False, indent=1), encoding='utf-8')
print('mutacija: maska 393 → 36 pt (mera + %d кадров)' % zamenen)
