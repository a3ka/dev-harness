#!/usr/bin/env python3
"""Reuse 222 plumbing/zone grammar, inspect the actual latest frozen blobs."""
import importlib.util
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[3]
source = ROOT / 'fixtures/workshop_project/lyubaja_model_222/catalog.py'
spec = importlib.util.spec_from_file_location('catalog222', source)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
latest = {}
for ref in module.git('for-each-ref', '--format=%(refname)', 'refs/tags/frozen/contracts/').splitlines():
    match = re.fullmatch(r'refs/tags/frozen/contracts/(\d{3})/(\d+)', ref)
    if match:
        latest[match[1]] = max(int(match[2]), latest.get(match[1], 0))
own = list(module.zones((ROOT / 'contracts/230-sud-model-drift.md').read_text()))
seen = set()
for number, version in sorted(latest.items()):
    ref = f'frozen/contracts/{number}/{version}'
    files = [p for p in module.git('ls-tree', '-r', '--name-only', ref + '^{commit}', '--', 'contracts/').splitlines()
             if re.fullmatch(f'contracts/{number}-[^/]+[.]md', p)]
    if len(files) != 1:
        continue
    text = module.git('show', ref + '^{commit}:' + files[0])
    for role, path in own:
        for owner, existing in module.zones(text):
            overlap = path == existing or (path.endswith('/') and existing.startswith(path)) or (existing.endswith('/') and path.startswith(existing))
            key = role, path, number
            if overlap and (role != owner or path == 'scripts/models_actual.sh') and key not in seen:
                seen.add(key)
                print(f'ПЕРЕСЕЧЕНИЕ {role}: {path} — {number} только дельта 230; остальные обязательства сохраняются.')
if not seen:
    raise SystemExit('NOT_IMPLEMENTED: empty frozen selection')
print(f'FROZEN_INTERSECTIONS={len(seen)}')
