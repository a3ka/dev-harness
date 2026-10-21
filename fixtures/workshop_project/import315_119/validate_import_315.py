#!/usr/bin/env python3
# Toy-валидатор импорта 3.15 (модель tests/spec-3.15/; круг 2 — поведенческие
# проверки: обязан краснеть на импорт-блокерах — несовместимость baseline
# (5.8.2-бандл) и потеря потребителя/поля consumers в index — и НЕ доверяется
# строке stdout: failures=[] печатается только после всех проверок).
# rc 0 — PASS, rc 1 — именованный отказ.
import json, sys
from pathlib import Path

R = Path(__file__).resolve().parents[2]
PUB = R / 'docs/contracts/BrokerOS_Unified_OpenAPI_v3.yaml'
BIND = R / 'docs/contracts/frontend-consumer-bindings.json'
INDEX = R / 'docs/contracts/operation-index.json'
MANI = R / 'docs/VERSION_MANIFEST.json'
SRC = R / 'docs/sources/backend-3.15'
KF = R / 'tests/tools/contract-validator-known-failures.json'


def die(msg):
    print('ВАЛИДАТОР ОТКАЗ:', msg)
    sys.exit(1)


pub = PUB.read_text()
ops = set()
for ln in pub.split('\n'):
    if ln.strip().startswith('operationId:'):
        ops.add(ln.strip().split(':', 1)[1].strip())
manifest = json.loads(MANI.read_text())
if manifest['operations'] != len(ops):
    die('manifest-operations=%d факт=%d' % (manifest['operations'], len(ops)))

# импорт-блокер 1: baseline-совместимость фиксируется относительно НАШЕЙ 5.8.4
lock = json.loads((SRC / 'baseline-lock.json').read_text())
if lock.get('compatibility_baseline') != '5.8.4':
    die('baseline-lock compatibility_baseline=%r — совместимость относительно не нашей базы'
        % lock.get('compatibility_baseline'))

# импорт-блокер 2: потеря потребителей и поля consumers в index
bindings = json.loads(BIND.read_text())
wc = bindings['workflow_consumers']
if manifest['consumers'] != len(wc):
    die('manifest-consumers расходится')
index = json.loads(INDEX.read_text())
idx = {e['operation_id']: e for e in index['operations']}
newc = json.loads((SRC / 'new-consumers.json').read_text()).get('new_operation_consumers', [])
bind_ops = {c.get('operation_id') for c in wc}
for c in newc:
    if c['operation_id'] not in bind_ops:
        die('новый потребитель %s потерян в bindings' % c['operation_id'])
for c in wc:
    op = c.get('operation_id')
    if op and op in idx and idx[op].get('consumers') is None:
        die('consumers-проекция %s потеряна в index' % op)
    if op and op not in ops and op not in idx:
        die('потребитель %s ссылается на неизвестную операцию' % op)

# known-failures обязан быть пуст; известные M1-проблемы — явный реестр
kf = json.loads(KF.read_text())
if kf['failure_ids'] or kf['fingerprints']:
    die('known-failures не пуст')
declared = json.loads((SRC / 'provenance/KNOWN-ISSUES-DECLARED.json').read_text()).get('ids', [])
registry = set(json.loads(Path(R / 'tests/spec-3.15/known-issues-315.json').read_text()).get('ids', []))
missing = [i for i in declared if i not in registry]
if missing:
    die('known-issues реестр неполон: %s' % ', '.join(missing))
print('PASS_IMPORT315 failures=[] known_failures=0 consumers=%d total=%d' % (
    len(wc) - len(newc), len(wc)))
