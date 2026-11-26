"""Public lock observations for G-4 warning budgets; expectations precede CLI."""
import json
import tempfile
from own_cells import observe_warning, warning

ROLES = ('critic', 'adversary', 'reviewer')
# limit, completed substantive calls, expected warning (independent literals).
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
    limit, count, warned = BOUNDARIES[boundary]
    refused = boundary == 'unsanctioned'
    with tempfile.TemporaryDirectory(prefix='jp229-phase-', dir=p.old.GIT_ENV['TMPDIR']) as tmp:
        m, wt, branch, obj = p.world(tmp)
        p.profile(m.repo, dict(p.DATA['defaults'], **{role + 'Calls': limit, 'onExhaustion': action}))
        counted_role = ('adversary' if role == 'critic' else 'critic') if boundary == 'other-role' else role
        # G-4 crosses OBJECT; independent D11 must not mask the warning observation.
        counted_obj = m.git(['rev-parse', 'HEAD']).stdout.strip() if warned else obj
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
        expected = warning('dev-harness', '141', role, obj, limit, count, 'spawn')
        before = m.ledger.read_bytes()
        result = p.old.sudit(source / 'scripts/zamok_predmeta.sh', m, p.attempt(m, role, 'PhaseNext', obj))
        p.command(result, 1 if refused else 0, 'ОТКАЗ: OBJECT_UZHE_SUZHEN:' if refused else None)
        if refused:
            p.check(m.ledger.read_bytes() == before, 'PHASE_REFUSAL_WROTE_LEDGER')
            return
        p.check(m.ledger.read_bytes().startswith(before), 'PHASE_REWROTE_HISTORY')
        new = [json.loads(line) for line in m.ledger.read_bytes()[len(before):].splitlines()]
        starts = [row for row in new if row.get('t') == 'START']
        p.check(len(starts) == 1 and starts[0]['holder'] == 'PhaseNext'
                and starts[0]['rol'] == role and starts[0]['object'] == obj,
                'PHASE_WRONG_START ' + repr(new))
        if warned:
            observe_warning(p, result, new, expected)
            p.check(len(new) == 2, 'PHASE_EXTRA_ACCOUNTING ' + repr(new))
        else:
            p.check(len(new) == 1 and 'ПРЕДУПРЕЖДЕНИЕ: ARBITRATION_REQUIRED' not in result.stderr,
                    'PHASE_SPURIOUS_WARNING ' + repr(new))
        helper = source / 'scripts/judges_policy.py'
        p.check(helper.is_file(), 'POLICY_HELPER_ABSENT')
        # Same journal, independent freeze accounting; no START may be added.
        # Other-role history contributes zero to this role's completed count.
        freeze_fact = 1 if boundary in ('interruption', 'environment', 'other-role') else count + 1
        expected = warning('dev-harness', '141', role, obj, limit, freeze_fact, 'freeze')
        before = m.ledger.read_bytes()
        result = p.run(['python3', str(helper), 'accounting', '--repo', str(m.repo),
                        '--ledger', str(m.ledger), '--repo-id', 'dev-harness', '--subject', '141',
                        '--role', role, '--object', obj, '--phase', 'freeze'])
        p.command(result, 0)
        p.check(m.ledger.read_bytes().startswith(before), 'PHASE_FREEZE_REWROTE_HISTORY')
        new = [json.loads(line) for line in m.ledger.read_bytes()[len(before):].splitlines()]
        if warned:
            observe_warning(p, result, new, expected)
            p.check(new == [expected], 'PHASE_FREEZE_CREATED_START')
        else:
            p.check(new == [] and 'ПРЕДУПРЕЖДЕНИЕ: ARBITRATION_REQUIRED' not in result.stderr.decode(),
                    'PHASE_FREEZE_SPURIOUS_WARNING')
