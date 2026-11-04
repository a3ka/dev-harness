#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; цикл 2, вердикт Crit147 v2a блок 2):
# в A-дерево возвращается ПАРАЛЛЕЛЬНАЯ форма запуска второго эмулятора —
# дословный обход вердикта (GA-форма): СРАЗУ после первого boot в job
# вставляется переключение AVD/PORT/SERIAL на 393, вызов boot и возврат
# к 390 — второй эмулятор запускается ДО приёмки, БЕЗ остановки первого
# (два живых одновременно — прямое нарушение слова владельца 31.10).
# e2e.sh, create AVD393, окружение — не тронуты; скрипт остаётся
# синтаксически валиден (bash -n rc 0). Дефект наблюдаем на входе клетки
# s-lekalo-instanciirovano: клетка обязана краснеть
# LEKALO_PARALLELNYJ_ZAPUSK_393; мутант-«пропускник» ловится здесь —
# STAB_ZHIV rc 1.
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
ANCHOR = '\nif ! boot; then diag; exit 1; fi\n'
if r.count(ANCHOR) != 1:
    print('MUTACIJA_NE_NAIDENA: якорь первого boot встречен %d раз'
          % r.count(ANCHOR), file=sys.stderr)
    sys.exit(1)
if 'AVD="$AVD393"' in r:
    print('MUTACIJA_NE_PRIMENIMA: параллельная форма уже есть',
          file=sys.stderr)
    sys.exit(1)
GA = (ANCHOR
      + 'AVD_GL="$AVD"; PORT_GL="$PORT"; SERIAL_GL="$SERIAL"\n'
      + 'AVD="$AVD393"; PORT="$PORT393"; SERIAL="$SERIAL393"\n'
      + 'if ! boot; then diag; exit 1; fi\n'
      + 'AVD="$AVD_GL"; PORT="$PORT_GL"; SERIAL="$SERIAL_GL"\n')
r2 = r.replace(ANCHOR, GA, 1)
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
