#!/usr/bin/env bash
# Контракт 197 (Б-3, вердикт Crit197V1): сверка ЗАЯВЛЕННОГО в контракте
# состава красных клеток батареи 143 после ленда 197 с ФАКТИЧЕСКИМ — по
# живому прогону на псевдо-продукте (базовое дерево продукта fda1fc8 +
# модель 197), не по проекции. Пин состава — source.json:.krasnye_143_posle_197.
# На том же псевдо-продукте батарея 197 обязана быть зелёной целиком.
# Коды возврата: 0 — состав совпал и батарея 197 зелёна; 1 — расхождение
# состава либо красная 197; 2 — предпосылка (нет клона продукта/коммита,
# sha базового mobile.yml не совпал, нет батареи/python3/node).
set -u
ZDES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" || exit 2
BATAREJA_197="$ZDES/red_mob_ci_artifacts_local_197.sh"
BATAREJA_143="$ZDES/../mob_ci_143/red_mob_ci_143.sh"
command -v python3 >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет python3' >&2; exit 2; }
command -v node >/dev/null 2>&1 || { echo 'NOT_IMPLEMENTED: нет node (replay канона)' >&2; exit 2; }
[ -f "$BATAREJA_197" ] || { echo "PREDPOSYLKA: нет батареи 197: $BATAREJA_197" >&2; exit 2; }
[ -f "$BATAREJA_143" ] || { echo "PREDPOSYLKA: нет батареи 143: $BATAREJA_143" >&2; exit 2; }
PYTHONDONTWRITEBYTECODE=1 exec python3 - "$ZDES" <<'PYEOF'
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
src = json.loads((zdes / 'source.json').read_text(encoding='utf-8'))
baza = src['bazovoje_derevo']
ozhidanye = sorted(src['krasnye_143_posle_197'])


def otkaz(prichina):
    print('PREDPOSYLKA: ' + prichina, file=sys.stderr)
    sys.exit(2)


klon = Path(baza['repo']).resolve()
if not (klon / '.git').exists():
    otkaz(f'клон продукта отсутствует: {klon}')
protsess = subprocess.run(['git', '-C', str(klon), 'cat-file', '-t', baza['commit']],
                          capture_output=True, text=True)
if protsess.returncode != 0 or protsess.stdout.strip() != 'commit':
    otkaz(f"коммит базового дерева не найден в клоне: {baza['commit']}")
arkhiv = subprocess.run(['git', '-C', str(klon), 'archive', baza['commit']],
                        capture_output=True)
if arkhiv.returncode != 0:
    otkaz('git archive не собрался: ' + arkhiv.stderr.decode('utf-8', 'replace').strip())

vremennoe = Path(tempfile.mkdtemp(prefix='sverka143-197-'))
try:
    with tarfile.open(fileobj=io.BytesIO(arkhiv.stdout)) as t:
        try:
            t.extractall(vremennoe, filter='data')
        except TypeError:  # python < 3.12 — tar из git archive доверенный
            t.extractall(vremennoe)
    sha_bazy = hashlib.sha256((vremennoe / '.github/workflows/mobile.yml').read_bytes()).hexdigest()
    if sha_bazy != baza['mobile_yml_sha256']:
        otkaz(f'sha базового mobile.yml {sha_bazy} != пина {baza["mobile_yml_sha256"]}')
    shutil.copy(zdes / 'model/.github/workflows/mobile.yml',
                vremennoe / '.github/workflows/mobile.yml')
    shutil.copy(zdes / 'model/mobile/scripts/ci-artefakty.cjs',
                vremennoe / 'mobile/scripts/ci-artefakty.cjs')
    paket_put = vremennoe / 'package.json'
    paket = json.loads(paket_put.read_text(encoding='utf-8'))
    kanon = json.loads((zdes / 'model/package.json').read_text(encoding='utf-8'))['scripts']
    paket.setdefault('scripts', {}).update(kanon)
    paket_put.write_text(json.dumps(paket, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(f'ПСЕВДО-ПРОДУКТ: {baza["commit"]} + модель 197 → {vremennoe}')

    b197 = subprocess.run(['bash', str(zdes / 'red_mob_ci_artifacts_local_197.sh'),
                           '--repo', str(vremennoe)], capture_output=True, text=True)
    svod = [s for s in b197.stdout.splitlines() if s.startswith('клеток')]
    if b197.returncode != 0:
        print('БАТАРЕЯ_197_КРАСНА: rc=' + str(b197.returncode) + '; ' + '; '.join(svod), file=sys.stderr)
        print('\n'.join(l for l in b197.stdout.splitlines() if 'KRASNO' in l), file=sys.stderr)
        sys.exit(1)
    print('БАТАРЕЯ_197_ЗЕЛЕНА: ' + '; '.join(svod))

    b143 = subprocess.run(['bash', str(zdes / '../mob_ci_143/red_mob_ci_143.sh'),
                           '--repo', str(vremennoe)], capture_output=True, text=True)
    fakt = []
    for stroka in b143.stdout.splitlines():
        m = re.match(r'^КЛЕТКА (.+?)(?: КРАСНА(?:: (.*))?| ЗЕЛЕНА)$', stroka)
        if not m or 'ЗЕЛЕНА' in stroka:
            continue
        ident = m.group(1)
        if m.group(2):
            ident += ': ' + m.group(2)
        fakt.append(ident)
    fakt.sort()
    lishnie = sorted(set(fakt) - set(ozhidanye))
    otsutstvujushchie = sorted(set(ozhidanye) - set(fakt))
    for ident in fakt:
        print('КРАСНАЯ_143: ' + ident)
    if lishnie or otsutstvujushchie:
        print(f'ИНВЕНТАРЬ_143_РАСХОДИТСЯ: лишние {lishnie}; отсутствуют {otsutstvujushchie}',
              file=sys.stderr)
        sys.exit(1)
    print(f'ИНВЕНТАРЬ_143_СОВПАЛ: красных {len(fakt)} из {len(ozhidanye)} пина, поимённо')
    sys.exit(0)
finally:
    shutil.rmtree(vremennoe, ignore_errors=True)
PYEOF
