#!/usr/bin/env python3
# Обманный стаб батареи 149 (Н-39, блок Crit149 круг 1/FAIL): воспроизводит
# ОБХОД критика (атака вердикта contracts-149-v1-krug1-fail.md): канон-байты
# и машина в продукте на месте, а CI-проводки экрана НЕТ — ни записи карты,
# ни job из лекала, ни output выбора, ни needs агрегатов; ekran.json пачки
# опустошён до {}. Такое дерево проходило старую батарею 82/82 (W --repo
# rc 0) — зелень без экранного job и записи карты. Дефект наблюдаем на
# входе клетки s-lekalo-instanciirovano: клетка обязана краснеть
# LEKALO_NE_INSTANCIIROVANO; мутант-«пропускник» (клетка возвращает зелёное
# без проверок) ловится здесь — STAB_ZHIV rc 1.
# argv[1] — каталог копии A-дерева.
import json
import sys
from pathlib import Path

import yaml

d = Path(sys.argv[1])
JOB = 'e2e-gespraech-tekst'

# (1) карта: запись 149 снимается целиком (CI «зелёный», экран не выбирается)
p = d / 'mobile' / 'ci-screens.json'
m = json.loads(p.read_text(encoding='utf-8'))
do = len(m.get('ekrany') or [])
m['ekrany'] = [e for e in (m.get('ekrany') or []) if e.get('job') != JOB]
if len(m['ekrany']) != do - 1:
    print('MUTACIJA_NE_NAIDENA: записи с job %s нет (%d->%d)'
          % (JOB, do, len(m['ekrany'])), file=sys.stderr)
    sys.exit(1)
p.write_text(json.dumps(m, ensure_ascii=False, indent=2) + '\n',
             encoding='utf-8')

# (2) workflow: job лекала, output выбора и needs ОБОИХ агрегатов снимаются
w = d / '.github' / 'workflows' / 'mobile.yml'
wf = yaml.safe_load(w.read_text(encoding='utf-8'))
if JOB not in (wf.get('jobs') or {}):
    print('MUTACIJA_NE_NAIDENA: job %s отсутствует' % JOB, file=sys.stderr)
    sys.exit(1)
del wf['jobs'][JOB]
outs = (wf['jobs'].get('select-screens') or {}).get('outputs') or {}
if outs.pop(JOB, None) is None:
    print('MUTACIJA_NE_NAIDENA: output %s отсутствует' % JOB,
          file=sys.stderr)
    sys.exit(1)
for ag in ('android-e2e', 'mobile-regression-signal'):
    needs = (wf['jobs'].get(ag) or {}).get('needs') or []
    if JOB not in needs:
        print('MUTACIJA_NE_NAIDENA: needs %s без %s' % (ag, JOB),
              file=sys.stderr)
        sys.exit(1)
    wf['jobs'][ag]['needs'] = [n for n in needs if n != JOB]
w.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
             encoding='utf-8')

# (3) пачка: ekran.json -> {} (пустая форма проходила старую батарею)
e = d / 'mobile' / 'e2e-gespraech-tekst' / 'ekran.json'
if not e.is_file():
    print('MUTACIJA_NE_NAIDENA: ekran.json отсутствует', file=sys.stderr)
    sys.exit(1)
e.write_text('{}\n', encoding='utf-8')
