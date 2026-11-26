"""229-only observations: retry STARTs and warning-only spawn/freeze accounting.

Expectations and original journal bytes are captured before each CLI invocation.
Freeze here is the accounting seam, never an accept or a complete lifecycle.
"""
import json
from pathlib import Path
import tempfile

OWN_CASES = ('own229-retries-interruption', 'own229-retries-environment',
             'own229-warning-journal')


def warning(repo_id, subject, role, obj, limit, fact, phase):
    return {'t': 'JUDGES_POLICY_WARNING', 'repoId': repo_id, 'subjectId': subject,
            'rol': role, 'object': obj, 'limit': limit, 'fact': fact,
            'phase': phase, 'action': 'ARBITRATION_REQUIRED'}


def observe_warning(p, result, rows, expected):
    p.check([r for r in rows if r.get('t') == 'JUDGES_POLICY_WARNING'] == [expected],
            'G4_WARNING_RECORD ' + repr(rows))
    line = ('ПРЕДУПРЕЖДЕНИЕ: ARBITRATION_REQUIRED '
            f'repo={expected["repoId"]} subject={expected["subjectId"]} '
            f'role={expected["rol"]} object={expected["object"]} '
            f'limit={expected["limit"]} fact={expected["fact"]} phase={expected["phase"]}')
    stderr = result.stderr.decode() if isinstance(result.stderr, bytes) else result.stderr
    p.check(line in stderr.splitlines(), 'G4_WARNING_OR_ARBITER_MISSING ' + repr(stderr))


def own_case(p, source, name):
    with tempfile.TemporaryDirectory(prefix='jp229-own-', dir=p.old.GIT_ENV['TMPDIR']) as tmp:
        m, wt, branch, obj = p.world(tmp)
        p.profile(m.repo, dict(p.DATA['defaults'], criticCalls=1))
        door = source / 'scripts/zamok_predmeta.sh'
        if name.startswith('own229-retries-'):
            reason = 'blok_sredy' if name.endswith('environment') else 'obryv_bez_verdikta'
            bare = Path(tmp) / 'remote/dev-harness.git'
            bare.parent.mkdir()
            p.command(p.run(['git', 'init', '-q', '--bare', str(bare)]), 0)
            m.git(['remote', 'set-url', 'origin', str(bare)])
            p.add_failed(m, obj, 2, reason)
            before = m.ledger.read_bytes()
            result = p.old.sudit(door, m, p.attempt(m, 'critic', 'ThirdRetry', obj))
            p.command(result, 0)
            p.check(m.ledger.read_bytes().startswith(before), 'RETRY_REWROTE_HISTORY')
            added = [json.loads(line) for line in m.ledger.read_bytes()[len(before):].splitlines()]
            p.check(len(added) == 1 and added[0].get('t') == 'START'
                    and added[0].get('holder') == 'ThirdRetry' and added[0].get('rol') == 'critic'
                    and added[0].get('klass') == 'sudja' and added[0].get('repoId') == 'dev-harness'
                    and added[0].get('subjectId') == '141' and added[0].get('object') == obj,
                    'RETRY_OWN_START_MISSING ' + repr(added))
            # Real release closes the admitted START and its session lock.
            m.zhurnal('ThirdRetry', sdal=True)
            if reason == 'blok_sredy':
                verdict = m.repo / 'verdicts/critic/contracts-141-v1.md'
                verdict.parent.mkdir(parents=True)
                verdict.write_text(f'БЛОК-СРЕДЫ\nOBJECT={obj}\n'
                                   'СУД: repo=dev-harness; предмет=141; роль=critic; '
                                   'сессия=ThirdRetry; модель-факт=fixture\n'
                                   'СРЕДА-КОМАНДА: node --version\nСРЕДА-RC: 127\n')
                m.git(['add', str(verdict)])
                p.command(p.run(['git', '-c', 'user.name=critic', '-c', 'user.email=judge@fixture',
                                 'commit', '-qm', 'environment verdict'], cwd=m.repo), 0)
            p.command(p.old.osvobodit(door, m, '141', 'ThirdRetry'), 0)
            before = m.ledger.read_bytes()
            result = p.old.sudit(door, m, p.attempt(m, 'critic', 'FourthRetry', obj))
            p.command(result, 1, 'ARBITRATION_REQUIRED')
            p.check(m.ledger.read_bytes() == before, 'G3_EXHAUSTION_WROTE_START')
            print('OWN229', reason, 'third START rc 0; next rc 1; unchanged journal')
            return
        counted_obj = m.git(['rev-parse', 'HEAD']).stdout.strip()
        p.add_failed(m, counted_obj, 1, 'verdikt_zakommiten')
        expected = warning('dev-harness', '141', 'critic', obj, 1, 1, 'spawn')
        before = m.ledger.read_bytes()
        result = p.old.sudit(door, m, p.attempt(m, 'critic', 'ContentNext', obj))
        p.command(result, 0)
        p.check(m.ledger.read_bytes().startswith(before), 'G4_REWROTE_HISTORY')
        rows = [json.loads(line) for line in m.ledger.read_bytes()[len(before):].splitlines()]
        observe_warning(p, result, rows, expected)
        starts = [row for row in rows if row.get('t') == 'START']
        p.check(len(rows) == 2 and len(starts) == 1 and starts[0].get('holder') == 'ContentNext'
                and starts[0].get('rol') == 'critic' and starts[0].get('object') == obj,
                'G4_WARNING_NOT_SPAWN ' + repr(rows))
        print('OWN229 G4 spawn rc', result.returncode, 'warning + own START')
        before = m.ledger.read_bytes()
        expected = warning('dev-harness', '141', 'critic', obj, 1, 2, 'freeze')
        helper = source / 'scripts/judges_policy.py'
        p.check(helper.is_file(), 'POLICY_HELPER_ABSENT')
        result = p.run(['python3', str(helper), 'accounting', '--repo', str(m.repo),
                        '--ledger', str(m.ledger), '--repo-id', 'dev-harness', '--subject', '141',
                        '--role', 'critic', '--object', obj, '--phase', 'freeze'])
        p.command(result, 0)
        p.check(m.ledger.read_bytes().startswith(before), 'G4_FREEZE_REWROTE_HISTORY')
        rows = [json.loads(line) for line in m.ledger.read_bytes()[len(before):].splitlines()]
        observe_warning(p, result, rows, expected)
        p.check(rows == [expected], 'G4_FREEZE_CREATED_START')
        print('OWN229 G4 freeze rc', result.returncode, 'same journal warning; no START')
