"""Стаб s106 (etalon-393, К-11 — оракул-таутология): вместо суждения
содержания по пикселям основы перестраивает эталоны построителем из
САМОГО koren (postroit.py) и сверяет sha256. На честном дереве
неразличим с оракулом; дефект наблюдаем ровно на входе
etalon-393-v6-poterja, где построитель в koren — мутант v6, сам
теряющий содержание: перестройка воспроизводит потерю, sha равны,
оракул-таутология даёт rc 0. Проверка v6 «postroit.py --proverit»
имела ровно этот дефект — вердикт Crit148V6, К-11 (Н-39)."""
import hashlib
import importlib.util
import shutil
import sys
import tempfile
from pathlib import Path

koren = None
for i, a in enumerate(sys.argv):
    if a == '--koren' and i + 1 < len(sys.argv):
        koren = Path(sys.argv[i + 1])
if koren is None:
    print('использование: s106_sha_tavtologija.py --koren DIR',
          file=sys.stderr)
    sys.exit(2)
_spec = importlib.util.spec_from_file_location('postroit_iz_korenja',
                                               koren / 'postroit.py')
m = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(m)
vrem = Path(tempfile.mkdtemp(prefix='s106-'))
try:
    m.postroit_v(vrem)
    rashozhdenija = []
    for f in sorted(vrem.iterdir()):
        kuda = koren / f.name
        h1 = hashlib.sha256(f.read_bytes()).hexdigest()
        h2 = (hashlib.sha256(kuda.read_bytes()).hexdigest()
              if kuda.is_file() else 'нет файла')
        if h1 != h2:
            rashozhdenija.append(f.name)
    if rashozhdenija:
        print('PRICHINA\tETALON_DERIVACIJA_NE_VOSPROIZVODIMA: %s'
              % ', '.join(rashozhdenija), file=sys.stderr)
        sys.exit(1)
    sys.exit(0)
finally:
    shutil.rmtree(vrem, ignore_errors=True)
