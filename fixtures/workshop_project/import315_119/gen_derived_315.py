#!/usr/bin/env python3
# Toy-генератор контракта 119 (модель единого генератора импорта 3.15; круг 2 —
# реальная грамматика данных: слияние new_operation_consumers (binding_status/
# runtime_status) в workflow_consumers, расширение operation-index с сохранением
# consumers-проекций базовых операций). Источник: docs/sources/backend-3.15/
# {core.openapi.yaml, platform-extension.yaml, new-consumers.json,
# declared-counts.json}; выходы: published OpenAPI, bindings, operation-index,
# VERSION_MANIFEST.json, FILES.sha256 (последним). --check: пересчёт в память,
# байтовое сравнение с диском, rc 0/1, НИ ОДНОЙ записи. Детерминизм: никаких
# меток времени; VS01-хэш заморожен: при наличии vs01_spec_freeze в манифесте
# sha256(core) обязан совпадать (assert, как у боевого generate_derived.py).
import hashlib, json, subprocess, sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
SRC = R / 'docs/sources/backend-3.15'
CORE, EXT = SRC / 'core.openapi.yaml', SRC / 'platform-extension.yaml'
NEWC = SRC / 'new-consumers.json'
PUB = R / 'docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml'
BIND = R / 'docs/contracts/frontend-consumer-bindings.json'
INDEX = R / 'docs/contracts/operation-index.json'
MANI = R / 'docs/VERSION_MANIFEST.json'
FILES = R / 'FILES.sha256'
CHECK = '--check' in sys.argv


def die(msg):
    print('ГЕНЕРАТОР ОТКАЗ:', msg)
    sys.exit(3)


def parse(text):
    lines = text.split('\n')
    ip = lines.index('paths:')
    ic = lines.index('components:')
    header, paths_zone, comp_zone = lines[:ip], lines[ip + 1:ic], lines[ic + 1:]
    blocks, cur = [], None
    for ln in paths_zone:
        if ln.startswith('  ') and not ln.startswith('   ') and ln[2:3] not in ('', ' '):
            cur = [ln]
            blocks.append(cur)
        elif cur is not None:
            cur.append(ln)
    schemas, cur = [], None
    for ln in comp_zone:
        if ln.strip() == 'schemas:':
            continue
        if ln.startswith('    ') and not ln.startswith('     ') and ln[4:5] not in ('', ' '):
            cur = [ln]
            schemas.append(cur)
        elif cur is not None:
            cur.append(ln)
    title = next(l[9:] for l in header if l.startswith('  title: '))
    version = next(l[11:] for l in header if l.startswith('  version: '))
    return title, version, blocks, schemas


def block_op(block):
    for ln in block:
        if ln.strip().startswith('operationId:'):
            return ln.strip().split(':', 1)[1].strip()
    return None


core_t, core_v, core_paths, core_sch = parse(CORE.read_text())
ext_t, ext_v, ext_paths, ext_sch = parse(EXT.read_text())
pub_text = '# generated: inherited core + platform-extension (single generator) — do not edit\n' \
    'openapi: 3.1.0\ninfo:\n  title: %s\n  version: %s\npaths:\n%s\n%s\ncomponents:\n  schemas:\n%s\n%s\n' % (
        core_t, core_v,
        '\n'.join('\n'.join(b) for b in core_paths),
        '\n'.join('\n'.join(b) for b in ext_paths),
        '\n'.join('\n'.join(b) for b in core_sch),
        '\n'.join('\n'.join(b) for b in ext_sch))
ops = pub_text.count('operationId:')
schemas = len(core_sch) + len(ext_sch)

# слияние потребителей: реальная грамматика — new_operation_consumers
# (operation_id/binding_status/runtime_status/action_id), записи дословно
# добавляются в workflow_consumers; базовые записи не перезаписываются.
bindings = json.loads(BIND.read_text())
have = {json.dumps(c, sort_keys=True, ensure_ascii=False) for c in bindings['workflow_consumers']}
newc = json.loads(NEWC.read_text()).get('new_operation_consumers', [])
appended = []
for c in newc:
    canon = json.dumps(c, sort_keys=True, ensure_ascii=False)
    if canon not in have:
        bindings['workflow_consumers'].append(c)
        appended.append(c)
bind_text = json.dumps(bindings, ensure_ascii=False, indent=2) + '\n'

# operation-index: базовые записи (включая consumers-проекции) сохраняются
# дословно, новым операциям добавляется своя запись с consumers.
index = json.loads(INDEX.read_text())
known_ops = {e['operation_id'] for e in index['operations']}
by_op = {}
for c in newc:
    by_op.setdefault(c['operation_id'], []).append(c)
for op, consumers in by_op.items():
    if op not in known_ops:
        index['operations'].append({'operation_id': op, 'consumers': consumers})
index_text = json.dumps(index, ensure_ascii=False, indent=2) + '\n'

manifest = json.loads(MANI.read_text())
vs01_core = hashlib.sha256(CORE.read_bytes()).hexdigest()
if 'vs01_spec_freeze' in manifest:
    if manifest['vs01_spec_freeze']['sha256'] != vs01_core:
        die('Frozen VS01 specification changed; do not silently update baseline')
else:
    manifest['vs01_spec_freeze'] = {'status': 'FROZEN_FOR_IMPLEMENTATION', 'api': '5.8.4',
                                    'sha256': vs01_core}
manifest.update({'operations': ops, 'schemas': schemas,
                 'consumers': len(bindings['workflow_consumers'])})
mani_text = json.dumps(manifest, ensure_ascii=False, indent=2) + '\n'

names = subprocess.check_output(['git', 'ls-files', '-z', '--cached', '--others',
                                 '--exclude-standard'], cwd=R).decode().split('\0')
inventory = sorted(n for n in names if n and n != 'FILES.sha256' and (R / n).is_file())
new_bytes = {str(p.relative_to(R)): t for p, t in
             [(PUB, pub_text), (BIND, bind_text), (INDEX, index_text), (MANI, mani_text)]}
files_text = ''.join(hashlib.sha256(
    new_bytes[n].encode() if n in new_bytes else (R / n).read_bytes()
).hexdigest() + '  ' + n + '\n' for n in inventory)

outputs = [(PUB, pub_text), (BIND, bind_text), (INDEX, index_text),
           (MANI, mani_text), (FILES, files_text)]
if CHECK:
    bad = [str(p) for p, t in outputs if p.read_text() != t]
    if bad:
        print('ГЕНЕРАТОР ОТКАЗ: --check: расхождение производных:', ', '.join(bad))
        sys.exit(1)
    print('CHECK_OK operations=%d schemas=%d consumers=%d' % (
        ops, schemas, len(bindings['workflow_consumers'])))
    sys.exit(0)

for p, t in outputs:
    p.write_text(t)
print('REGENERATED operations=%d schemas=%d consumers=%d files=%d' % (
    ops, schemas, len(bindings['workflow_consumers']), len(inventory)))
