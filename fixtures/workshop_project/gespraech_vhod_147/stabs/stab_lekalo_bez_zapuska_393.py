#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39, блок Crit147c scoped-обход): из A-дерева
# удаляется ТОЛЬКО запуск второго эмулятора профиля 393 — строка
# «if ! boot; then diag; exit 1; fi» между переключением
# AVD="$AVD393"; PORT="$PORT393"; SERIAL="$SERIAL393" и export
# GESPRAECH_SERIAL_393. Первый запуск (профиль 390) и запасной запуск
# прежнего AVD остаются; скрипт остаётся синтаксически валиден (bash -n
# rc 0) — поэтому прохождение прежней батареи (rc 0 71/71, вердикт
# contracts-147-v3-scoped-fail: «второй эмулятор ни разу не запускается,
# приёмка профиля 393 не может выполниться») не отличимо от честного
# дерева ни по одному другому аспекту. Дефект наблюдаем на входе клетки
# s-lekalo-instanciirovano: клетка обязана краснеть LEKALO_BEZ_ZAPUSKA_393;
# мутант-«пропускник» (клетка возвращает зелёное без проверок запуска)
# ловится здесь — STAB_ZHIV rc 1.
# argv[1] — каталог копии A-дерева.
import subprocess
import sys
import tempfile
from pathlib import Path

import yaml

d = Path(sys.argv[1])
JOB = 'e2e-gespraech-vhod'
w = d / '.github' / 'workflows' / 'mobile.yml'
wf = yaml.safe_load(w.read_text(encoding='utf-8'))
job = (wf.get('jobs') or {}).get(JOB)
if job is None:
    print('MUTACIJA_NE_NAIDENA: job %s отсутствует' % JOB, file=sys.stderr)
    sys.exit(1)
shag = next((s for s in (job.get('steps') or [])
             if str(s.get('name', '')).startswith('Экранная пачка')), None)
if shag is None:
    print('MUTACIJA_NE_NAIDENA: экранный шаг отсутствует', file=sys.stderr)
    sys.exit(1)
r = str(shag['run'])
PEREK = 'AVD="$AVD393"; PORT="$PORT393"; SERIAL="$SERIAL393"\n'
ZAPUSK = 'if ! boot; then diag; exit 1; fi\n'
i = r.find(PEREK)
if i == -1:
    print('MUTACIJA_NE_NAIDENA: переключения 393 нет', file=sys.stderr)
    sys.exit(1)
j = r.find(ZAPUSK, i + len(PEREK))
if j != i + len(PEREK):
    print('MUTACIJA_NE_NAIDENA: запуск 393 не следует за переключением '
          '(j=%d, ожидался %d)' % (j, i + len(PEREK)), file=sys.stderr)
    sys.exit(1)
do = r.count('if ! boot; then diag; exit 1; fi')
r2 = r[:j] + r[j + len(ZAPUSK):]
posle = r2.count('if ! boot; then diag; exit 1; fi')
if posle != do - 1 or do != 3:
    print('MUTACIJA_NE_NAIDENA: вызовов boot %d -> %d (ожидалось 3 -> 2)'
          % (do, posle), file=sys.stderr)
    sys.exit(1)
with tempfile.NamedTemporaryFile('w', suffix='.sh', delete=False) as tf:
    tf.write(r2)
    put = tf.name
rc = subprocess.run(['bash', '-n', put]).returncode
if rc != 0:
    print('MUTACIJA_NE_NAIDENA: bash -n rc=%d' % rc, file=sys.stderr)
    sys.exit(1)
shag['run'] = r2
w.write_text(yaml.safe_dump(wf, allow_unicode=True, sort_keys=False),
             encoding='utf-8')
