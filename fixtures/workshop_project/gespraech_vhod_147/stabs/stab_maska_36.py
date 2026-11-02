#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; цикл 2, вердикт Crit147 v2a блок 3):
# в манифесте кадров профиля 393 маска системной шапки ВОЗВРАЩАЕТСЯ к
# 36 pt (отвергнутая форма: пилюля пакета 1.1 x133-258, y11-47 — маска
# 36 оставляла 12 pt чужого хрома в судимой зоне, слово владельца
# 31.10 принял 48). Порог/записи/порядок не тронуты; манифест И пины
# source.json меняются ВМЕСТЕ (sha + kanon) — обманный ПЕРЕПИН, а не
# порча носителя (порчу ловит vedro ДО клеток). Дефект наблюдаем на
# входе клетки s-maska-393-48: клетка обязана краснеть MASKA_393_NE_48;
# мутант-«пропускник» ловится здесь — STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import sys
from pathlib import Path

z = Path(sys.argv[1])
p = z / 'pachka' / 'kadry-393.json'
m = json.loads(p.read_text(encoding='utf-8'))
if m.get('mera', {}).get('chrome_verh_pt') != 48:
    print('MUTACIJA_NE_PRIMENIMA: маска 393 уже не 48 (%r)'
          % m.get('mera', {}).get('chrome_verh_pt'), file=sys.stderr)
    sys.exit(1)
m['mera']['chrome_verh_pt'] = 36
p.write_text(json.dumps(m, ensure_ascii=False, indent=1) + '\n',
             encoding='utf-8')
h = hashlib.sha256(p.read_bytes()).hexdigest()

s = z / 'source.json'
src = json.loads(s.read_text(encoding='utf-8'))
for razdel, put in (('sha', 'pachka/kadry-393.json'),
                    ('kanon', 'mobile/e2e-gespraech-vhod/kadry-393.json')):
    if put not in src['piny'][razdel]:
        print('MUTACIJA_NE_NAIDENA: пина %s/%s нет' % (razdel, put),
              file=sys.stderr)
        sys.exit(1)
    src['piny'][razdel][put] = h
s.write_text(json.dumps(src, ensure_ascii=False, indent=1) + '\n',
             encoding='utf-8')
