#!/usr/bin/env python3
# Обманный стаб батареи 147 (Н-39, блок Crit147c scoped-обход; цикл 2 —
# последовательная пара): из A-дерева удаляется ТОЛЬКО запуск второго
# эмулятора профиля 393 — строки emulator-запуска в e2e.sh ПАЧКИ (строка
# с «emulator … -avd "$avd393"» и её продолжения «\» до строки с
# журналом «emulator-gespraech-393.log», кончающейся «&»); ожидание/
# настройка/кадры 393 остаются — приёмка 393 не может выполниться,
# эмулятор не запускается ни разу. Остановка 390, окружение job, create
# AVD393 — не тронуты; скрипт остаётся синтаксически валиден (bash -n
# rc 0). Дефект наблюдаем на входе клетки s-lekalo-instanciirovano:
# клетка обязана краснеть LEKALO_BEZ_ZAPUSKA_393; мутант-«пропускник»
# (клетка зелена без проверок запуска) ловится здесь — STAB_ZHIV rc 1.
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
stroki = p.read_text(encoding='utf-8').splitlines(True)
i0 = [i for i, s in enumerate(stroki)
      if '-avd "$avd393"' in s and 'emulator' in s]
i1 = [i for i, s in enumerate(stroki)
      if 'emulator-gespraech-393.log' in s]
if len(i0) != 1 or len(i1) != 1 or not 0 <= i1[0] - i0[0] <= 2 \
        or not stroki[i1[0]].rstrip('\n').endswith('&'):
    print('MUTACIJA_NE_NAIDENA: запуск 393 не в канонической форме '
          '(i0=%s i1=%s)' % (i0, i1), file=sys.stderr)
    sys.exit(1)
ostatok = stroki[:i0[0]] + stroki[i1[0] + 1:]
s2 = ''.join(ostatok)
if 'emulator-gespraech-393.log' in s2 or '-avd "$avd393"' in s2:
    print('MUTACIJA_NE_NAIDENA: запуск удалён не целиком', file=sys.stderr)
    sys.exit(1)
with tempfile.NamedTemporaryFile('w', suffix='.sh', delete=False) as tf:
    tf.write(s2)
    put = tf.name
rc = subprocess.run(['bash', '-n', put]).returncode
if rc != 0:
    print('MUTACIJA_NE_NAIDENA: bash -n rc=%d' % rc, file=sys.stderr)
    sys.exit(1)
p.write_text(s2, encoding='utf-8')
