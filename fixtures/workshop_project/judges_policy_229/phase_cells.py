"""Public lock observations for substantive phase budgets; expectations precede CLI."""
import json
from pathlib import Path
import tempfile

ROLES = ('critic', 'adversary', 'reviewer')
# limit, completed substantive calls, expected refusal (not recomputed by subject).
BOUNDARIES = {
    'one': (1, 1, True),
    'below': (2, 1, False),
    'at': (2, 2, True),
    'above': (2, 3, True),
    'interruption': (1, 0, False),
    'environment': (1, 0, False),
    'other-role': (1, 1, False),
    'other-object': (1, 1, True),
    'unsanctioned': (2, 1, False),
}
PHASE_CASES = {f'phase-{role}-{action}-{boundary}': (role, action, boundary)
               for role in ROLES for action in ('stop', 'arbiter') for boundary in BOUNDARIES}
INVALID = {
    **{f'policy-{role}-limit-{label}': {role + 'Calls': value}
       for role in ROLES for label, value in
       (('zero', 0), ('negative', -1), ('boolean', True), ('string', '1'), ('fraction', 1.5), ('null', None))},
    **{f'policy-exhaustion-{label}': {'onExhaustion': value}
       for label, value in (('unknown', 'unexpected'), ('empty', ''), ('null', None),
                            ('number', 1), ('upper-stop', 'STOP'), ('mixed-arbiter', 'Arbiter'),
                            ('spaces', ' '), ('padded', ' stop '))},
}


def phase_case(p, source, name):
    role, action, boundary = PHASE_CASES[name]
    limit, count, exhausted = BOUNDARIES[boundary]
    expected_code = 'BUDGET_EXHAUSTED' if action == 'stop' else 'ARBITRATION_REQUIRED'
    if boundary == 'unsanctioned':
        expected_code = 'OBJECT_UZHE_SUZHEN'
    refused = exhausted or boundary == 'unsanctioned'
    with tempfile.TemporaryDirectory(prefix='jp229-phase-', dir=p.old.GIT_ENV['TMPDIR']) as tmp:
        m, wt, branch, obj = p.world(tmp)
        p.profile(m.repo, dict(p.DATA['defaults'], **{role + 'Calls': limit, 'onExhaustion': action}))
        counted_role = ('adversary' if role == 'critic' else 'critic') if boundary == 'other-role' else role
        counted_obj = m.git(['rev-parse', 'HEAD']).stdout.strip() if boundary == 'other-object' else obj
        for i in range(count):
            holder = 'DonePhase' + str(i)
            m.start('141', holder, klass='sudja', rol=counted_role, obj=counted_obj, zanyat=False)
            m.release('141', holder, 'verdikt_zakommiten')
        if boundary in ('interruption', 'environment'):
            m.start('141', 'TechnicalPhase', klass='sudja', rol=role, obj=obj, zanyat=False)
            m.release('141', 'TechnicalPhase', 'obryv_bez_verdikta' if boundary == 'interruption' else 'blok_sredy')
        if boundary == 'below':
            with m.ledger.open('a') as ledger:
                ledger.write(json.dumps({'t': 'SANKCIJA', 'repoId': 'dev-harness', 'subjectId': '141',
                                         'rol': role, 'object': obj}) + '\n')
        before = m.ledger.read_bytes()
        result = p.old.sudit(source / 'scripts/zamok_predmeta.sh', m, p.attempt(m, role, 'PhaseNext', obj))
        p.command(result, 1 if refused else 0, ('ОТКАЗ: ' + expected_code + ':') if refused else None)
        if refused:
            p.check(m.ledger.read_bytes() == before, 'PHASE_REFUSAL_WROTE_LEDGER')
            if exhausted:
                for field in (f'role={role}', f'limit={limit}', f'fact={count}', 'repo=dev-harness', 'subject=141', f'object={obj}'):
                    p.check(field in result.stderr.split(), 'PHASE_MISSING_FIELD ' + field)
                other = 'ARBITRATION_REQUIRED' if action == 'stop' else 'BUDGET_EXHAUSTED'
                p.check(other not in result.stderr, 'PHASE_WRONG_ACTION')
        else:
            new = [row for row in m.ledg() if row.get('holder') == 'PhaseNext']
            p.check(len(new) == 1 and new[0]['t'] == 'START' and new[0]['rol'] == role and new[0]['object'] == obj,
                    'PHASE_WRONG_START ' + repr(new))
            p.check(m.ledger.read_bytes().startswith(before), 'PHASE_REWROTE_HISTORY')
