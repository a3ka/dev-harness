#!/usr/bin/env bash
# scripts/ci_vesa.sh — веса строк step/legkij реестра registry/ci-steps.tsv по замерам
# (контракт 087, И-9). Cwd = корень worktree. Грамматика строки замера: «замер:
# <ключ> <секунды>», допустимый префикс — `<джоба>\t<шаг>\t` (формат `gh run view
# --log`) и/или `<ISO-время> ` (формат лога джобы). Прочие байты реестра не меняются.
#
#   bash scripts/ci_vesa.sh --write <лог>...  переписать поле веса максимумом по логам
#   bash scripts/ci_vesa.sh --check <лог>...  rc 1 с именем ключа при весе ≠ замеру
#
# Ключ реестра без замера — rc 1 с именем ключа, реестр не тронут (для --write).
# Пустая выборка логов или строк замера — rc 1.
#
# Коды возврата: 0 — успех, 1 — отказ с именованной причиной.
set -uo pipefail
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DATABASE \
      GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_CEILING_DIRECTORIES
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
command -v python3 >/dev/null 2>&1 || { printf 'NOT_IMPLEMENTED: нет python3\n' >&2; exit 2; }

exec python3 - "$@" <<'PY'
import os, re, sys

REG = 'registry/ci-steps.tsv'
# `замер: <ключ> <секунды>` в начале, либо после `<джоба>\t<шаг>\t`, либо после
# `<ISO-время> ` (или после ОБОИХ вместе). Никаких других префиксов: «замер» середины
# строки не считается замером (приманка для test-kla).
RE = re.compile(r'^(?:[^\t\n]*\t[^\t\n]*\t)?(?:\d{4}-\d\d-\d\dT[0-9:.]+Z )?'
                r'замер: ([a-z0-9][a-z0-9._:-]*) ([0-9]+)$')


def die(m):
    sys.stderr.write('ОТКАЗ: %s\n' % m)
    sys.exit(1)


a = sys.argv[1:]
if len(a) < 1 or a[0] not in ('--write', '--check'):
    die('использование: ci_vesa.sh --write|--check <лог>...')
if len(a) < 2:
    die('пустая выборка: логов замера нет')

meas = {}
for lp in a[1:]:
    if not os.path.isfile(lp):
        die('нет файла лога: %s' % lp)
    with open(lp, encoding='utf-8', errors='replace') as f:
        for line in f.read().split('\n'):
            m = RE.match(line.rstrip('\r'))
            if m:
                meas[m.group(1)] = max(meas.get(m.group(1), 0), int(m.group(2)))

if not meas:
    die('пустая выборка: в логах нет строк «замер: <ключ> <секунды>»')

with open(REG, encoding='utf-8') as f:
    text = f.read()
lines = text.split('\n')
missing, diff = [], []
for i, line in enumerate(lines):
    if not line:
        continue
    p = line.split('\t')
    if len(p) >= 4 and p[0] in ('step', 'legkij'):
        k, w = p[1], p[2]
        if k not in meas:
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

# MODE=write: переписать реестр (прочие байты целы: разбиваем по '\n', правим только
# строки step/legkij, склеиваем обратно тем же '\n', которым исходно разъединили).
with open(REG, 'w', encoding='utf-8') as f:
    f.write('\n'.join(lines))
print('веса записаны: изменено %d' % len(diff))
PY