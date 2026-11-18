#!/usr/bin/env bash
# Контракт 197: адресные клетки интерфейса сверки, настоящий кандидат 143.
# Запуск: bash proverka_sverki_143.sh --ref <кандидат/новый frozen 143>
set -u
ZDES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
PYTHONDONTWRITEBYTECODE=1 exec python3 - "$ZDES" "$@" <<'PYEOF'
import io
import json
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

zdes = Path(sys.argv[1]).resolve()
repo = zdes.parents[2]
if len(sys.argv) != 4 or sys.argv[2] != '--ref':
    sys.exit('PREDPOSYLKA: требуется --ref кандидата/нового frozen 143')
ref = sys.argv[3]
put = Path('fixtures/workshop_project/mob_ci_artifacts_local_197')
put143 = 'fixtures/workshop_project/mob_ci_143'
src = json.loads((zdes / 'source.json').read_text())
# Оракул до запуска субъекта; ожидания не считываются из его вывода.
pin = src['batareja_143_do']
expected = sorted(src['krasnye_143_posle_197'])
archive = subprocess.run(['git', '-C', str(repo), 'archive', ref, put143], capture_output=True)
if archive.returncode:
    print('PREDPOSYLKA: кандидат 143 отсутствует: ' + ref, file=sys.stderr)
    sys.exit(2)
gitdir = subprocess.check_output(['git', '-C', str(repo), 'rev-parse', '--absolute-git-dir'], text=True).strip()
n = 0
with tempfile.TemporaryDirectory(prefix='proverka-sverki-143-') as t:
    root = Path(t)
    # Только семья 197, git-объекты исходного клона; соседней батареи 143 НЕТ.
    (root / '.git').write_text('gitdir: ' + gitdir + '\n')
    family = root / put
    shutil.copytree(zdes, family)
    with tarfile.open(fileobj=io.BytesIO(archive.stdout)) as tar:
        tar.extractall(root / 'candidate', filter='data')
    candidate = root / 'candidate' / put143

    def check(name, args, rc, token):
        global n
        p = subprocess.run(['bash', str(family / 'sverka_inventarja_143.sh'), *args],
                           capture_output=True, text=True)
        output = p.stdout + p.stderr
        if p.returncode != rc or token not in output:
            print(f'КЛЕТКА_СВЕРКИ {name} КРАСНА: rc={p.returncode}, ожидался {rc}; {token}\n{output}', file=sys.stderr)
            sys.exit(1)
        print(f'КЛЕТКА_СВЕРКИ {name} ЗЕЛЕНА: rc={p.returncode}; {token}', flush=True)
        n += 1
        return p.stdout

    def metadata(value):
        (family / 'source.json').write_text(json.dumps(value, ensure_ascii=False))

    before = check('do-bez-sosednej-batarei', [], 0, 'ИНВЕНТАРЬ_143_СОВПАЛ: красных 6 из 6')
    actual = sorted(s.removeprefix('КРАСНАЯ_143: ') for s in before.splitlines() if s.startswith('КРАСНАЯ_143: '))
    if actual != expected:
        sys.exit('ИНВЕНТАРЬ_143_РАСХОДИТСЯ: контроль поимённого оракула')
    print(before, end='', flush=True)
    check('posle-ref', ['после', '--ref', ref], 0, 'ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных')
    check('posle-katalog-ekvivalent', ['после', '--dir', str(candidate)], 0, 'ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных')
    check('posle-staraja-versija', ['после', '--ref', pin['commit']], 1, 'БАТАРЕЯ_143_ОТКАЗ: rc=1, ожидался 0')
    check('posle-bez-istochnika', ['после'], 2, 'REZHIM_143')
    check('posle-net-ref', ['после', '--ref', 'refs/197-net-takogo-kandidata'], 2, 'BATAREJA_143_COMMIT_NET')
    bad = json.loads(json.dumps(src))
    bad['batareja_143_do']['commit'] = '0' * 40
    metadata(bad)
    check('do-net-commita', ['до'], 2, 'BATAREJA_143_COMMIT_NET')
    bad['batareja_143_do']['commit'] = pin['commit']
    bad['batareja_143_do']['tree'] = '0' * 40
    metadata(bad)
    check('do-tree-rashozhdenie', ['до'], 2, 'BATAREJA_143_TREE_RASHOZHDENIE')
    # Соседняя подмена закреплённой версии при неизменном tree-пине.
    bad['batareja_143_do'] = dict(pin, commit=ref)
    metadata(bad)
    check('do-drugaja-versija', ['до'], 2, 'BATAREJA_143_TREE_RASHOZHDENIE')
    metadata(src)
    # Каждый стаб привязан в коде к наблюдаемому нарушению интерфейса.
    entry = candidate / 'red_mob_ci_143.sh'
    honest = entry.read_bytes()
    stabs = [
        ('posle-pustoj-vyvod', '#!/bin/sh\nexit 0\n', 'БАТАРЕЯ_143_ОТКАЗ'),
        ('posle-oshibka-sredy', '#!/bin/sh\nexit 2\n', 'БАТАРЕЯ_143_ОТКАЗ'),
        ('posle-lishnjaja-krasnaja', '#!/bin/sh\nprintf "%s\\n" "клеток 1, зелёных 0, красных 1" "КЛЕТКА dop КРАСНА: DOP"\nexit 0\n', 'ИНВЕНТАРЬ_143_РАСХОДИТСЯ'),
    ]
    for name, code, token in stabs:
        entry.write_text(code)
        check(name, ['после', '--dir', str(candidate)], 1, token)
    entry.write_bytes(honest)
print(f'клеток сверки {n}, зелёных {n}, красных 0')
PYEOF
