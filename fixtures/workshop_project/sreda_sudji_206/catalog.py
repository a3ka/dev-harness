#!/usr/bin/env python3
"""Render binding catalog or exact precision intersections; no file edits."""
import argparse
from pathlib import Path
import sys
from probe import HERE, ROOT, MUTATIONS, model

p = argparse.ArgumentParser()
p.add_argument('--zones', type=Path)
p.add_argument('--check', action='store_true')
a = p.parse_args()
if a.zones:
    owned = {'implementer': {'.omp/extensions/path-guard.ts', 'scripts/pre_judge.sh', 'roles/critic.md', 'roles/adversary.md', 'roles/reviewer.md', '.omp/agents/critic.md', '.omp/agents/adversary.md', '.omp/agents/reviewer.md'}, 'orchestrator': {'registry/ci-steps.tsv', 'registry/ci-zamery.tsv', '.github/workflows/ci.yml'}}
    rows = set()
    for row in a.zones.read_text().splitlines():
        author, path, number = row.split('\t')
        for ours, paths in owned.items():
            if path in paths and author != ours and number != '206':
                rows.add((ours, path, number))
    if not rows:
        sys.exit('EMPTY_ZONE_SNAPSHOT')
    for author, path, number in sorted(rows):
        reason = 'производная материализация scripts/gen_ci_steps.sh из registry/ci-steps.tsv' if path == '.github/workflows/ci.yml' else ('собственная строка батареи 206 и её замер' if author == 'orchestrator' else 'среда судьи 206; прежние обязательства сохраняются')
        print(f'ПЕРЕСЕЧЕНИЕ {author}: {path} — {number} только {reason}')
else:
    catalog = 'stab\tcell\tsubject\n' + ''.join(f'{name}\t{cell}\t{path}\n' for name, cell, path, *_ in MUTATIONS)
    if a.check:
        if (HERE / 'stabs.tsv').read_bytes() != catalog.encode():
            sys.exit('STABS_CATALOG_MISMATCH')
        contract = (ROOT / 'contracts/206-sreda-sudji.md').read_text()
        for role in model.ROLES:
            if contract.splitlines().count(f'- role=roles/{role}.md «{model.NORM}»') != 1:
                sys.exit('NORM_CANON_MISMATCH')
        print(f'STABS={len(MUTATIONS)} NORM_CONSUMERS={len(model.ROLES)}')
    else:
        print(catalog, end='')
