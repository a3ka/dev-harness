#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39; цикл 2, вердикт Crit147 v2a блок 2):
# в e2e.sh ПАЧКИ A-дерева отказ запуска второго эмулятора МАСКИРУЕТСЯ —
# ожидание загрузки 393 проглатывается «|| true»: не загрузившийся
# эмулятор не отказывает приёмке, Maestro падает по чужой причине (или
# молча проходит мимо кадров 393). Порядок остановка-запуск не тронут,
# скрипт остаётся синтаксически валиден (bash -n rc 0). Дефект наблюдаем
# на входе клетки s-lekalo-instanciirovano: клетка обязана краснеть
# LEKALO_MASKA_OTKAZA_393; мутант-«пропускник» ловится здесь —
# STAB_ZHIV rc 1.
# argv[1] — каталог копии A-дерева.
import subprocess
import sys
import tempfile
from pathlib import Path

d = Path(sys.argv[1])
p = d / 'mobile' / 'e2e-gespraech-vhod' / 'e2e.sh'
if not p.is_file():
    print('MUTACIJA_NE_NAIDENA: нет %s' % p, file=sys.stderr)
    sys.exit(1)
s = p.read_text(encoding='utf-8')
CALL = 'dozhdatsja "$serial393"'
if s.count(CALL) != 1 or '|| true' in s.split(CALL, 1)[0][-40:]:
    print('MUTACIJA_NE_NAIDENA: ожидание 393 не в канонической форме '
          '(вхождений %d)' % s.count(CALL), file=sys.stderr)
    sys.exit(1)
s2 = s.replace(CALL, CALL + ' || true', 1)
with tempfile.NamedTemporaryFile('w', suffix='.sh', delete=False) as tf:
    tf.write(s2)
    put = tf.name
rc = subprocess.run(['bash', '-n', put]).returncode
if rc != 0:
    print('MUTACIJA_NE_NAIDENA: bash -n rc=%d' % rc, file=sys.stderr)
    sys.exit(1)
p.write_text(s2, encoding='utf-8')
