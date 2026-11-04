#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; цикл 2, вердикт Crit147 v2a блок 1):
# пачку «перепинивают» на сверку кадра GA-01 — записи GA-01 dark/light
# ВОЗВРАЩАЮТСЯ в ОБА манифеста кадров (порог — из живой записи той же
# темы; макеты пакета 1.1, пины maket_sha256 выводятся из пинов
# kompakt11 ЗЕРКАЛА — единый источник, без второго списка байтов) —
# приёмка снова требует совпадения входа со Start-макетом, исключённым
# словом владельца 31.10 (живой замер Impl147e: 0.326/0.299 — красное
# навсегда до предмета Start D 2.4). Записи И пины source.json меняются
# ВМЕСТЕ (sha + kanon): это обманный ПЕРЕПИН, а не порча носителя
# (порву ловит vedro ДО клеток). Дефект наблюдаем на входе клетки
# s-ga01-vne-sverki: клетка обязана краснеть GA01_V_SVERKE;
# мутант-«пропускник» ловится здесь — STAB_ZHIV rc 1.
# argv[1] — корень зеркальной копии зоны.
import hashlib
import json
import sys
from pathlib import Path

z = Path(sys.argv[1])
src = json.loads((z / 'source.json').read_text(encoding='utf-8'))
PINY = src['piny']['sha']

MANIFESTY = {
    'pachka/kadry.json': {
        'dark': ('GA-01_normal_dark_390x844.png', 'gespraech-ga-01'),
        'light': ('GA-01_normal_light_390x844.png', 'gespraech-ga-01'),
    },
    'pachka/kadry-393.json': {
        'dark': ('GA-01_normal_dark_393x852.png', 'gespraech-ga-01-393'),
        'light': ('GA-01_normal_light_393x852.png', 'gespraech-ga-01-393'),
    },
}

novye = {}
for manifest, temy in MANIFESTY.items():
    p = z / manifest
    m = json.loads(p.read_text(encoding='utf-8'))
    if any(k['id'].startswith('GA-01') for k in m['kadry']):
        print('MUTACIJA_NE_PRIMENIMA: %s уже несёт GA-01' % manifest,
              file=sys.stderr)
        sys.exit(1)
    zapisi = []
    for tema, (kadry_png, snimok) in temy.items():
        pin_kljuch = 'nositeli/kompakt11/frames/' + kadry_png
        if pin_kljuch not in PINY:
            print('MUTACIJA_NE_NAIDENA: пина %s нет' % pin_kljuch,
                  file=sys.stderr)
            sys.exit(1)
        # порог/маски/геометрия экрана — из живой записи той же темы
        # (единый источник формы, второй список значений не заводим)
        obrazec = next(k for k in m['kadry'] if k['tema'] == tema)
        zapisi.append({
            'id': 'GA-01 %s' % tema, 'tema': tema, 'snimok': snimok,
            'maket': 'docs/ux/05_Kompakt_D24/frames/' + kadry_png,
            'maket_sha256': PINY[pin_kljuch],
            'porog': obrazec['porog'],
            'maski_pt': list(obrazec.get('maski_pt', [])),
            'elementy': json.loads(json.dumps(obrazec['elementy']))})
    m['kadry'] = zapisi + m['kadry']
    p.write_text(json.dumps(m, ensure_ascii=False, indent=1) + '\n',
                 encoding='utf-8')
    h = hashlib.sha256(p.read_bytes()).hexdigest()
    novye[('sha', manifest)] = h
    if manifest.endswith('kadry.json'):
        novye[('kanon', 'mobile/e2e-gespraech-vhod/kadry.json')] = h
    else:
        novye[('kanon', 'mobile/e2e-gespraech-vhod/kadry-393.json')] = h

for (razdel, put), h in novye.items():
    if put not in src['piny'][razdel]:
        print('MUTACIJA_NE_NAIDENA: пина %s/%s нет' % (razdel, put),
              file=sys.stderr)
        sys.exit(1)
    src['piny'][razdel][put] = h
(z / 'source.json').write_text(
    json.dumps(src, ensure_ascii=False, indent=1) + '\n', encoding='utf-8')
