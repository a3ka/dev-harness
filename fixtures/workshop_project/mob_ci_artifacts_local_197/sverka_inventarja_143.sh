#!/usr/bin/env bash
# Контракт 197: проверка шва на одном псевдо-продукте fda1fc8 + модель 197.
# до (по умолчанию): закреплённые commit+tree батареи 143, шесть красных.
# после --ref REF | после --dir DIR: явно выбранная батарея, ноль красных.
# rc 0 — ожидание исполнено и 197 зелена; 1 — расхождение; 2 — предпосылка.
set -u
ZDES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
command -v node >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет node (replay канона)' >&2; exit 2; }
command -v git >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет git' >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 - "$ZDES" "$@" <<'PYEOF'
import hashlib
import io
import json
import re
import shutil
import subprocess
import sys
import tarfile
import tempfile
from pathlib import Path

zdes = Path(sys.argv[1]).resolve()
# Ожидания снимаются в память до вызова любой проверяемой батареи.
src = json.loads((zdes / 'source.json').read_text(encoding='utf-8'))
baza = src['bazovoje_derevo']
pin = src['batareja_143_do']
ozhidanye = sorted(src['krasnye_143_posle_197'])
repo = zdes.parents[2]
put_143 = 'fixtures/workshop_project/mob_ci_143'


def otkaz(prichina):
    print('PREDPOSYLKA: ' + prichina, file=sys.stderr)
    sys.exit(2)


args = sys.argv[2:]
rezhim = args[0] if args else 'до'
if rezhim == 'до' and len(args) <= 1:
    ref, katalog = pin['commit'], None
elif rezhim == 'после' and len(args) == 3 and args[1] in ('--ref', '--dir') and args[2]:
    ref = args[2] if args[1] == '--ref' else None
    katalog = Path(args[2]).resolve() if args[1] == '--dir' else None
else:
    otkaz('REZHIM_143: до | после --ref REF | после --dir DIR; источник после обязателен')
if rezhim == 'после':
    ozhidanye = []


def git(*argv):
    return subprocess.run(['git', '-C', str(repo), *argv], capture_output=True)


def raspakovat(data, kuda):
    with tarfile.open(fileobj=io.BytesIO(data)) as t:
        try:
            t.extractall(kuda, filter='data')
        except TypeError:  # python < 3.12 — tar из git archive доверенный
            t.extractall(kuda)


if ref is not None:
    commit = git('rev-parse', '--verify', '--end-of-options', ref + '^{commit}')
    if commit.returncode:
        otkaz('BATAREJA_143_COMMIT_NET: ' + ref)
    commit = commit.stdout.decode().strip()
    tree = git('rev-parse', '--verify', commit + ':' + put_143)
    if tree.returncode:
        otkaz('BATAREJA_143_TREE_NET: ' + commit)
    tree = tree.stdout.decode().strip()
    if rezhim == 'до' and tree != pin['tree']:
        otkaz(f'BATAREJA_143_TREE_RASHOZHDENIE: {tree} != {pin["tree"]}')
    arkhiv_143 = git('archive', commit, put_143)
    if arkhiv_143.returncode:
        otkaz('BATAREJA_143_ARCHIVE_OTKAZ: ' + arkhiv_143.stderr.decode('utf-8', 'replace').strip())
    print(f'БАТАРЕЯ_143: режим {rezhim}; commit {commit}; tree {tree}', flush=True)
else:
    print(f'БАТАРЕЯ_143: режим после; каталог {katalog}', flush=True)

klon = Path(baza['repo']).resolve()
if not (klon / '.git').exists():
    otkaz(f'клон продукта отсутствует: {klon}')
protsess = subprocess.run(['git', '-C', str(klon), 'cat-file', '-t', baza['commit']],
                          capture_output=True, text=True)
if protsess.returncode != 0 or protsess.stdout.strip() != 'commit':
    otkaz(f"коммит базового дерева не найден в клоне: {baza['commit']}")
arkhiv = subprocess.run(['git', '-C', str(klon), 'archive', baza['commit']], capture_output=True)
if arkhiv.returncode != 0:
    otkaz('git archive не собрался: ' + arkhiv.stderr.decode('utf-8', 'replace').strip())

with tempfile.TemporaryDirectory(prefix='sverka143-197-') as tmp:
    koren = Path(tmp)
    mesto_143 = koren / 'batareja' / put_143
    if ref is not None:
        raspakovat(arkhiv_143.stdout, koren / 'batareja')
    else:
        if not (katalog / 'red_mob_ci_143.sh').is_file():
            otkaz('BATAREJA_143_NET: ' + str(katalog))
        shutil.copytree(katalog, mesto_143)
    batareja = mesto_143 / 'red_mob_ci_143.sh'
    if not batareja.is_file():
        otkaz('BATAREJA_143_NET: ' + str(batareja))
    # Кандидат 143 пинует соседнюю модель 197; даём именно модель этой
    # приёмки, а не случайное содержимое соседнего каталога кандидата.
    shutil.copytree(zdes / 'model', mesto_143.parent / zdes.name / 'model')
    vremennoe = koren / 'produkt'
    raspakovat(arkhiv.stdout, vremennoe)
    sha_bazy = hashlib.sha256((vremennoe / '.github/workflows/mobile.yml').read_bytes()).hexdigest()
    if sha_bazy != baza['mobile_yml_sha256']:
        otkaz(f'sha базового mobile.yml {sha_bazy} != пина {baza["mobile_yml_sha256"]}')
    shutil.copy(zdes / 'model/.github/workflows/mobile.yml', vremennoe / '.github/workflows/mobile.yml')
    shutil.copy(zdes / 'model/mobile/scripts/ci-artefakty.cjs', vremennoe / 'mobile/scripts/ci-artefakty.cjs')
    paket_put = vremennoe / 'package.json'
    paket = json.loads(paket_put.read_text(encoding='utf-8'))
    kanon = json.loads((zdes / 'model/package.json').read_text(encoding='utf-8'))['scripts']
    paket.setdefault('scripts', {}).update(kanon)
    paket_put.write_text(json.dumps(paket, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'ПСЕВДО-ПРОДУКТ: {baza["commit"]} + модель 197 → {vremennoe}', flush=True)

    b197 = subprocess.run(['bash', str(zdes / 'red_mob_ci_artifacts_local_197.sh'),
                           '--repo', str(vremennoe)], capture_output=True, text=True)
    svod = [s for s in b197.stdout.splitlines() if s.startswith('клеток')]
    if b197.returncode != 0:
        print('БАТАРЕЯ_197_КРАСНА: rc=' + str(b197.returncode) + '; ' + '; '.join(svod), file=sys.stderr)
        print(b197.stdout + b197.stderr, file=sys.stderr)
        sys.exit(1)
    print('БАТАРЕЯ_197_ЗЕЛЕНА: ' + '; '.join(svod), flush=True)

    b143 = subprocess.run(['bash', str(batareja), '--repo', str(vremennoe)], capture_output=True, text=True)
    fakt = []
    for stroka in b143.stdout.splitlines():
        m = re.fullmatch(r'КЛЕТКА (.+?)(?: КРАСНА(?:: (.*))?| ЗЕЛЕНА)', stroka)
        if not m or stroka.endswith(' ЗЕЛЕНА'):
            continue
        ident = m.group(1)
        if m.group(2):
            ident += ': ' + m.group(2)
        fakt.append(ident)
    fakt.sort()
    for ident in fakt:
        print('КРАСНАЯ_143: ' + ident)
    # Нулевой набор красных не означает, что батарея исполнилась.
    svod_143 = re.findall(r'^клеток ([0-9]+), зелёных ([0-9]+), красных ([0-9]+)$',
                         b143.stdout, re.MULTILINE)
    nuzhen_rc = 1 if rezhim == 'до' else 0
    if b143.returncode != nuzhen_rc or not svod_143 or any(int(n) == 0 for n, _, _ in svod_143):
        print(f'БАТАРЕЯ_143_ОТКАЗ: rc={b143.returncode}, ожидался {nuzhen_rc}; сводок {len(svod_143)}', file=sys.stderr)
        print(b143.stdout + b143.stderr, file=sys.stderr)
        sys.exit(1)
    lishnie = sorted(set(fakt) - set(ozhidanye))
    otsutstvujushchie = sorted(set(ozhidanye) - set(fakt))
    if fakt != ozhidanye:
        print(f'ИНВЕНТАРЬ_143_РАСХОДИТСЯ: лишние {lishnie}; отсутствуют {otsutstvujushchie}; '
              f'красных {len(fakt)}, ожидалось {len(ozhidanye)}', file=sys.stderr)
        sys.exit(1)
    if rezhim == 'после':
        print('ИНВЕНТАРЬ_143_НОЛЬ_КРАСНЫХ: ноль красных; батарея 143 приняла lane-форму')
    else:
        print(f'ИНВЕНТАРЬ_143_СОВПАЛ: красных {len(fakt)} из {len(ozhidanye)} пина, поимённо')
PYEOF
