#!/usr/bin/env python3
"""Reproduce frozen compatibility provenance and declarations using lib_zones."""
import argparse
import hashlib
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[3]
FROZEN = {'129': (2, '129-fallback-subagent.md'), '186': (2, '186-hranitel-arhitektury.md'),
          '166': (2, '166-snyatie-ogranichitelya-modelej.md'), '198': (1, '198-modeli-tolko-v-reestre.md'),
          '104': (2, '104-uzkij-doverennyj-gejt-sudi.md')}
PATHS = {'architect': ['contracts/215-otkaz-po-soderzhaniyu-zapasnaya.md',
                       'fixtures/workshop_project/otkaz_po_soderzhaniyu_215/'],
         'implementer': ['.omp/extensions/fallback-route.ts', 'scripts/models_actual.sh'],
         'orchestrator': ['roles/orchestrator.md', '.omp/agents/orchestrator.md']}


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args], text=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--zones', action='store_true')
    args = parser.parse_args()
    if args.zones:
        command = '. "$1/scripts/lib_zones.sh"; LIB_ZONES_ROOT="$1"; trap __lib_zones_cleanup EXIT; Z=$(zones_load "$1") || exit "$?"; cat "$Z/zones_scoped"'
        rows = subprocess.check_output(['bash', '-c', command, 'catalog215', str(ROOT)], text=True).splitlines()
        output = set()
        for line in rows:
            author, path, number = line.split('\t')
            for ours, paths in PATHS.items():
                for target in paths:
                    if ours != author and (target.startswith(path.rstrip('/') + '/') or path.startswith(target.rstrip('/') + '/') or path == target):
                        output.add((ours, target, number))
        for ours, path, number in sorted(output):
            print('ПЕРЕСЕЧЕНИЕ %s: %s — %s только предмет 215; остальные обязательства сохраняются.' % (ours, path, number))
        if not rows:
            return 2
        return 0
    for number, (version, filename) in FROZEN.items():
        ref = 'frozen/contracts/%s/%s' % (number, version)
        refs = git('for-each-ref', '--format=%(refname)', 'refs/tags/frozen/contracts/' + number + '/').splitlines()
        maximum = max(int(r.rsplit('/', 1)[1]) for r in refs)
        if maximum != version:
            raise RuntimeError('FROZEN_VERSION_CHANGED ' + number)
        text = git('show', ref + '^{commit}:contracts/' + filename)
        print(ref, git('rev-parse', ref + '^{commit}').strip(), 'sha256=' + hashlib.sha256(text.encode()).hexdigest())
        selected = [(i, line) for i, line in enumerate(text.splitlines(), 1)
                    if ('fallback-route.ts' in line or 'НЕ в предмете' in line or
                        'Существующее' in line or 'не меня' in line or 'сверк' in line.lower())]
        if not selected:
            return 2
        for i, line in selected:
            print('contracts/%s:%d %s' % (filename, i, line))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
