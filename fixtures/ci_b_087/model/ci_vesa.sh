#!/usr/bin/env bash
# МОДЕЛЬ scripts/ci_vesa.sh (контракт 087 И-8) — НЕ субъект. Веса строк step/legkij
# реестра registry/ci-steps.tsv (cwd = корень) — максимум замеров ключа по логам:
#   ci_vesa.sh --write <лог>...  — переписать поле веса, прочие байты реестра не трогать
#   ci_vesa.sh --check <лог>...  — rc 1 с именем ключа, если вес ≠ замеру
# Строка замера в логе: «замер: <ключ> <секунды>», допустимый префикс — «<джоба>\t<шаг>\t»
# (gh run view --log) и/или «<ISO-время> » (лог джобы). Ключ реестра без замера — отказ
# rc 1 (вес не держится молча); пустая выборка логов — отказ. Стаб M087_STAB=derzhit-staryj.
set -uo pipefail
exec python3 - "$@" <<'PY'
import os, re, sys
STAB = os.environ.get('M087_STAB', '')
REG = 'registry/ci-steps.tsv'
RE = re.compile(r'^(?:[^\t\n]*\t[^\t\n]*\t)?(?:\d{4}-\d\d-\d\dT[0-9:.]+Z )?'
                r'замер: ([a-z0-9][a-z0-9._:-]*) ([0-9]+)$')
def die(m):
    sys.stderr.write('ОТКАЗ: %s\n' % m); sys.exit(1)
a = sys.argv[1:]
if len(a) < 1 or a[0] not in ('--write', '--check'):
    die('использование: ci_vesa.sh --write|--check <лог>...')
if len(a) < 2:
    die('пустая выборка: логов замера нет')
meas = {}
for lp in a[1:]:
    with open(lp, encoding='utf-8', errors='replace') as f:
        for line in f.read().split('\n'):
            m = RE.match(line.rstrip('\r'))
            if m:
                meas[m.group(1)] = max(meas.get(m.group(1), 0), int(m.group(2)))
if not meas:
    die('пустая выборка: в логах нет строк «замер: <ключ> <секунды>»')
with open(REG, encoding='utf-8') as f:
    lines = f.read().split('\n')
missing, diff = [], []
for i, line in enumerate(lines):
    p = line.split('\t')
    if len(p) >= 4 and p[0] in ('step', 'legkij'):
        k, w = p[1], p[2]
        if k not in meas:
            if STAB == 'derzhit-staryj':
                continue
            missing.append(k)
            continue
        if not w.isdigit() or int(w) != meas[k]:
            diff.append('%s (реестр %s, замер %d)' % (k, w, meas[k]))
            p[2] = str(meas[k])
            lines[i] = '\t'.join(p)
if missing:
    die('нет замера: %s' % ' '.join(missing))
if a[0] == '--check':
    if diff:
        die('вес не по замеру: %s' % '; '.join(diff))
    print('веса по замеру: %d ключей' % len(meas))
    sys.exit(0)
with open(REG, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print('веса записаны: изменено %d' % len(diff))
PY
