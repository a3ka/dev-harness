#!/usr/bin/env python3
"""Arb229: same append-only ledger at proposed 154 spawn/freeze and 229.

The freeze seam here is accounting ONLY, never the full freeze lifecycle.
Expected records and original bytes are captured before each subject call.
"""
import json
from pathlib import Path
import tempfile

PROPERTIES = ('i2', 'i3', 'i4-missing', 'i4-ambiguous', 'i4-consultant',
              'i5-sanction', 'i5-arbitration', 'i6')
JOINT_CASES = ('joint154-retries', *(f'warn154-{prop}-{phase}'
               for prop in (*PROPERTIES, 'below', 'scope') for phase in ('spawn', 'freeze')))


def accounting(p, source, m, phase, count, position):
    before = m.ledger.read_bytes()
    expected = {'t': 'schet154', 'repoId': 'dev-harness', 'subjectId': '141',
                'phase': phase, 'count': count, 'position': position,
                'warning': position > 2}
    helper = source / 'model154_warn.py'
    if not helper.is_file():
        helper = p.HERE / 'model/model154_warn.py'
    p.check(helper.is_file(), 'WARN154_MODEL_ABSENT')
    result = p.run(['python3', str(helper), '--ledger', str(m.ledger),
                    '--repo-id', 'dev-harness', '--subject', '141', '--phase', phase])
    p.command(result, 0)
    p.check(json.loads(result.stdout) == expected, 'WARN154_POSITION_OR_SCOPE')
    suffix = (json.dumps(expected, ensure_ascii=False, sort_keys=True) + '\n').encode()
    p.check(m.ledger.read_bytes() == before + suffix, 'WARN154_ACCOUNTING_NOT_APPEND_ONLY')
    message = f'ПРЕДУПРЕЖДЕНИЕ: SCHET_154: phase={phase} position={position}\n'.encode()
    p.check(result.stderr == (message if position > 2 else b''), 'WARN154_WARNING')
    print('JOINT154', phase, 'rc', result.returncode, 'count', count, 'position', position)


def joint_case(p, source, name):
    with tempfile.TemporaryDirectory(prefix='jp229-joint-', dir=p.old.GIT_ENV['TMPDIR']) as tmp:
        m, wt, branch, obj = p.world(tmp)
        if name == 'joint154-retries':
            bare = Path(tmp) / 'remote/dev-harness.git'
            bare.parent.mkdir()
            p.command(p.run(['git', 'init', '-q', '--bare', str(bare)]), 0)
            m.git(['remote', 'set-url', 'origin', str(bare)])
            # Crit229c's input: two released technical sessions, no sanctions.
            p.profile(m.repo, dict(p.DATA['defaults'], criticCalls=1))
            p.add_failed(m, obj, 2, 'obryv_bez_verdikta')
            initial = m.ledger.read_bytes()
            accounting(p, source, m, 'spawn', 2, 3)
            before = m.ledger.read_bytes()
            result = p.old.sudit(source / 'scripts/zamok_predmeta.sh', m,
                                  p.attempt(m, 'critic', 'ThirdRetry', obj))
            p.command(result, 0)
            print('JOINT229 spawn rc', result.returncode)
            rows = [json.loads(line) for line in m.ledger.read_bytes()[len(before):].splitlines()]
            starts = [row for row in rows if row.get('t') == 'START']
            p.check(len(starts) == 1 and starts[0]['holder'] == 'ThirdRetry'
                    and starts[0]['rol'] == 'critic' and starts[0]['klass'] == 'sudja'
                    and starts[0]['repoId'] == 'dev-harness' and starts[0]['subjectId'] == '141'
                    and starts[0]['object'] == obj, 'THIRD_START_NOT_IN_154_ACCOUNT')
            p.check(m.ledger.read_bytes().startswith(initial), 'OLD_STARTS_CHANGED')
            accounting(p, source, m, 'freeze', 3, 3)
            # Real release clears both the session lock and its own START.
            m.zhurnal('ThirdRetry', sdal=True)
            p.command(p.old.osvobodit(source / 'scripts/zamok_predmeta.sh',
                                     m, '141', 'ThirdRetry'), 0)
            before = m.ledger.read_bytes()
            result = p.old.sudit(source / 'scripts/zamok_predmeta.sh', m,
                                  p.attempt(m, 'critic', 'FourthRetry', obj))
            p.command(result, 1, 'ARBITRATION_REQUIRED')
            p.check(m.ledger.read_bytes() == before, 'G3_EXHAUSTION_WROTE_START')
            print('JOINT229 exhausted rc', result.returncode, 'START unchanged')
            return
        prop, phase = name[len('warn154-'):].rsplit('-', 1)
        # Distinct conformant journals exercise each replaced refusal property.
        # No receipt/permission can turn this accounting warning into a grant.
        position = {'i2': 3, 'i3': 4, 'i4-missing': 3, 'i4-ambiguous': 3,
                    'i4-consultant': 5, 'i5-sanction': 3, 'i5-arbitration': 4,
                    'i6': 5, 'below': 2, 'scope': 3}[prop]
        count = position - (phase == 'spawn')
        p.add_failed(m, obj, count, 'obryv_bez_verdikta')
        if prop in ('i4-ambiguous', 'i4-consultant', 'i5-sanction', 'i5-arbitration'):
            proof = {'repoId': 'dev-harness', 'subjectId': '141', 'object': obj,
                     'at': '2026-11-26T00:00:00Z', 'basisCommit': obj, 'basisPath': 'HANDOFF.md'}
            events = []
            if prop == 'i4-ambiguous':
                events = [dict(proof, t='ISPOLZOVANO', nomer=3, istochnik=who)
                          for who in ('vladelec', 'orchestrator')]
            elif prop == 'i4-consultant':
                events = [dict(proof, t=kind, nomer=number, istochnik='konsultant')
                          for number in (3, 4, 5) for kind in ('SANKTSIYA', 'ISPOLZOVANO')]
                events.append(dict(proof, t='ARBITRAZH'))
            else:
                events = [dict(proof, t='ARBITRAZH')] if prop == 'i5-arbitration' else [
                    dict(proof, t='SANKTSIYA', nomer=3, istochnik='orchestrator')]
            if prop.startswith('i4-'):
                spec = p.importlib.util.spec_from_file_location(
                    'receipt154', p.ROOT / 'fixtures/workshop_project/schet_vyzovov_154/model/budget.py')
                canonical = p.importlib.util.module_from_spec(spec)
                spec.loader.exec_module(canonical)
                receipt = m.repo / 'HANDOFF.md'
                receipt.write_text('\n'.join(canonical.receipt_line(event) for event in events) + '\n')
                m.git(['add', str(receipt)])
                m.git(['-c', 'user.name=architect', '-c', 'user.email=architect@fixture',
                       'commit', '-qm', 'committed 154 receipt fixture'])
                sha = m.git(['rev-parse', 'HEAD']).stdout.strip()
                for event in events:
                    event['basisCommit'] = sha
            with m.ledger.open('a') as stream:
                stream.write(''.join(json.dumps(event) + '\n' for event in events))
        if prop == 'scope':
            rows = m.ledg()
            for row in rows:
                if row.get('t') == 'START' and row.get('klass') == 'sudja':
                    row['rol'] = 'critic-sol'
            m.ledger.write_text(''.join(json.dumps(row) + '\n' for row in rows))
            p.add_failed(m, obj, 4, 'obryv_bez_verdikta', repo_id='other')
        accounting(p, source, m, phase, count, position)
