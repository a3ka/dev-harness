#!/usr/bin/env python3
"""Black-box toy worlds for the real lock and freeze CLI, with a reference patch in --model."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MODEL = HERE / 'model' / 'budget.py'
REPO_ID = 'repo-origin'
BASELINE = '7fd217d7968a89fd3c72943b64386e20c03baa12'
NNN = '001'


def cmd(argv, cwd=None):
    return subprocess.run(argv, cwd=cwd, capture_output=True, text=True, timeout=90,
                          env={**os.environ, 'GIT_CONFIG_GLOBAL': '/dev/null',
                               'GIT_CONFIG_SYSTEM': '/dev/null'})


def ensure(result, label):
    if result.returncode:
        raise RuntimeError(f'{label}: rc {result.returncode}: {result.stderr[-400:]}')


def prepare_scripts(world, mode, mutation=''):
    scripts = world / 'scripts'
    scripts.mkdir()
    for f in (ROOT / 'scripts').iterdir():
        if f.is_file():
            (scripts / f.name).symlink_to(f)
    if mode == 'model':
        lock = cmd(['git', '-C', str(ROOT), 'show', BASELINE + ':scripts/zamok_predmeta.sh']).stdout
        freeze = cmd(['git', '-C', str(ROOT), 'show', BASELINE + ':scripts/freeze_contract.sh']).stdout
        if not lock.startswith('#!/usr/bin/env bash') or not freeze.startswith('#!/usr/bin/env bash'):
            raise RuntimeError('model baseline unavailable')
    else:
        lock = (ROOT / 'scripts' / 'zamok_predmeta.sh').read_text()
        freeze = (ROOT / 'scripts' / 'freeze_contract.sh').read_text()
    if mode == 'model':
        budget = MODEL
        if mutation:
            body = MODEL.read_text()
            edits = {
                'five-identical': ('count = len(starts)', '''count = len({r['rol'] for r in starts})'''),
                'arbitration-sixth': ('count = len(starts)', '''count = 0 if (pathlib.Path(a.repo) / 'verdicts/arbitration/contracts-001-arbitraz.md').exists() else len(starts)'''),
                'renamed-object': ('count = len(starts)', '''count = 0 if any(r['holder'].endswith('b') for r in starts) else len(starts)'''),
                'aborted-counts': ('count = len(starts)', '''count = sum('yield' in (pathlib.Path(a.zhurnaly) / (r['holder'] + '.jsonl')).read_text() for r in starts)'''),
                'five-plus-accept': ('count > 5', 'count > 6'),
                'freeze-side-effect': (
                    "return refuse('KAP_VYZOVOV_KRITIKA: предмет ' + a.subject + ': ' + str(count) + '/5 при freeze')",
                    "subprocess.run(['git', '-C', a.repo, 'tag', 'frozen/contracts/001/1'], check=True)\n        "
                    "return refuse('KAP_VYZOVOV_KRITIKA: предмет ' + a.subject + ': ' + str(count) + '/5 при freeze')"),
                'unreadable-ledger': ('if not ledger.is_file() or not os.access(ledger, os.R_OK):', 'if ledger.is_file() and not os.access(ledger, os.R_OK): return 0\n    if not ledger.is_file():'),
                'contradictory-ledger': ('''if verdicts and not starts:''', '''if False and verdicts and not starts:'''),
            }
            src, dst = edits[mutation]
            if body.count(src) != 1:
                raise RuntimeError('stab mutation anchor missing: ' + mutation)
            body = body.replace(src, dst)
            if mutation == 'contradictory-ledger':
                body = body.replace('''if a.phase == 'freeze' and count == 0:''', '''if False and a.phase == 'freeze' and count == 0:''')
            budget = world / 'budget_mutant.py'
            budget.write_text(body)
        old_init = '[ -r "$LEDGER" ] || : >> "$LEDGER" || skip "учёт не создать: $LEDGER"'
        new_init = '[ -r "$LEDGER" ] || { [ -e "$LEDGER" ] && otp SCHET_NEIZVESTEN "ledger unreadable"; : >> "$LEDGER" || skip "учёт не создать: $LEDGER"; }'
        if lock.count(old_init) != 1:
            raise RuntimeError('model: lost ledger initialization')
        lock = lock.replace(old_init, new_init)
        if mutation == 'unreadable-ledger':
            lock = lock.replace(new_init, old_init)
        lock = lock.replace('LEDGER="$SOST/uchet.jsonl"\n',
                            'LEDGER="$SOST/uchet.jsonl"\n'
                            'LEDGER_154_EXISTED=1\n'
                            '[ -f "$LEDGER" ] || LEDGER_154_EXISTED=0\n', 1)
        injection = ('      if [ "$klass" = sudja ] && { [ "$rol" = critic ] || '
                     '[ "$rol" = critic-sol ]; }; then\n'
                     '[ "$LEDGER_154_EXISTED" = 1 ] || { '
                     'mutexi_snyat_vse; rm -f "$LEDGER"; otp SCHET_NEIZVESTEN "журнал отсутствовал до вызова"; }\n'
                     f'        python3 "{budget}" --sostojanie "$SOST" --repo "$REPO" --zhurnaly "$ZHUR" '
                     '--subject "$sv" --phase spawn || { mutexi_snyat_vse; exit 1; }\n'
                     '      fi\n')
        anchor = '    if [ "$klass" = ' + chr(39) + 'sudja' + chr(39) + ' ]; then\n      rab="$(poslednij_rabochij "$sv")"'
        if lock.count(anchor) != 1:
            raise RuntimeError('model: lost judge decision insertion point')
        lock = lock.replace(anchor, injection + anchor)
        start = freeze.index('# ── 6в. КАП КРУГОВ:')
        end = freeze.index('# ── 6г. ГЕЙТ ПРЕДПОСЫЛОК', start)
        freeze = (freeze[:start] +
                  '# ── 6в. Счёт реальных START; 4-й аргумент = корень состояния станции.\n'
                  '[ "$#" -ge 4 ] || die "SCHET_NEIZVESTEN: корень состояния не передан"\n'
                  f'python3 "{budget}" --sostojanie "$4" --repo "$ROOT" '
                  '--subject "$NNN" --phase freeze || die "SCHET154: отказ бюджета"\n\n' +
                  freeze[end:])
    for name, data in (('zamok_predmeta.sh', lock), ('freeze_contract.sh', freeze)):
        (scripts / name).unlink()
        (scripts / name).write_text(data)
    return scripts


def world(base, n, outcomes, arbitraz=False, name_variant=False, broken=False, phase='spawn', label=''):
    repo = base / 'repo'
    ensure(cmd(['bash', '-c', 'source "$1"; make_repo "$2"', 'battery',
                str(ROOT / 'fixtures/freeze_contract/_repo.sh'), str(repo)]), 'make_repo')
    contract = repo / 'contracts' / '001-x.md'
    contract.write_text(contract.read_text() + '\nКЛАСС РИСКА: обычный\n')
    verdict = repo / 'verdicts' / 'critic' / 'contracts-001-v1.md'
    ensure(cmd(['git', '-C', str(repo), 'rm', '-q', str(verdict)]), 'remove scaffold verdict')
    ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add risk')
    ensure(cmd(['git', '-C', str(repo), '-c', 'user.name=battery', '-c',
                'user.email=b@t', 'commit', '-q', '-m', 'start with no verdict']), 'commit')
    verdict.parent.mkdir(parents=True, exist_ok=True)
    for i, outcome in enumerate(outcomes):
        if outcome != 'aborted':
            verdict.write_text(f'{outcome}\nsession={i}\n')
            ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add verdict')
            ensure(cmd(['git', '-C', str(repo), '-c', 'user.name=battery', '-c',
                        'user.email=b@t', 'commit', '-q', '-m', f'verdict {i}']), 'commit verdict')
    if not outcomes and phase == 'freeze':
        verdict.write_text('accept\norphan without START\n')
    if label in ('renamed-object', 'verdict-vplus') or (
        label.startswith('domain-spawn-') and name_variant and verdict.exists()
    ):
        dest = verdict.with_name('contracts-001-v1b-fail.md' if label != 'verdict-vplus'
                                 else 'contracts-001-v2.md')
        verdict.rename(dest)
    if label.startswith('domain-freeze-') and name_variant and len(outcomes) > 1:
        # A historical earlier verdict is republished under another filename;
        # the latest accept remains the freeze target for the honest script.
        older = verdict.with_name('contracts-001-v1b-fail.md')
        older.write_text(f'{outcomes[-2]}\nrenamed historical verdict\n')
    if label == 'verdict-copy':
        extra = repo / 'copied'
        extra.mkdir()
        shutil.copyfile(verdict, extra / verdict.name)
    if arbitraz:
        a = repo / 'verdicts' / 'arbitration'
        a.mkdir(exist_ok=True)
        first = ('К ВЛАДЕЛЬЦУ' if label == 'arbitration-owner' else
                 'ВЕРНУТЬ' if label == 'arbitration-return' else 'РЕШЕНИЕ')
        (a / 'contracts-001-arbitraz.md').write_text(first + ' (контракт 001)\n')
    ensure(cmd(['git', '-C', str(repo), 'add', '-A']), 'add scenario')
    if cmd(['git', '-C', str(repo), 'diff', '--cached', '--quiet']).returncode:
        ensure(cmd(['git', '-C', str(repo), '-c', 'user.name=battery', '-c',
                    'user.email=b@t', 'commit', '-q', '-m', 'scenario']), 'commit scenario')
    s = base / 'state'
    j = base / 'journals'
    s.mkdir(); j.mkdir()
    ledger = s / 'uchet.jsonl'
    wt = base / 'worker'
    ensure(cmd(['git', 'clone', '-q', str(repo), str(wt)]), 'worker clone')
    ensure(cmd(['git', '-C', str(wt), 'checkout', '-q', '-b', 'wip/001/architect']), 'branch')
    tip = cmd(['git', '-C', str(wt), 'rev-parse', 'HEAD']).stdout.strip()
    (j / 'Worker154.jsonl').write_text('{"toolName":"yield"}\n')
    rows = [dict(t='START', repoId=REPO_ID, subjectId=NNN, group='harness',
                 holder='Worker154', klass='rabochij', rol='architect',
                 object='-', worktree=str(wt), branch='wip/001/architect')]
    for i, outcome in enumerate(outcomes):
        holder = f'Crit{i}b' if name_variant else f'Crit{i}a'
        rows.append(dict(t='START', repoId=REPO_ID, subjectId=NNN,
                         group='harness', holder=holder, klass='sudja',
                         rol='critic-sol' if label == 'critic-sol-only' or i % 2 else 'critic', object=f'{i + 1:040x}',
                         worktree='-', branch='-'))
        if outcome != 'aborted':
            (j / (holder + '.jsonl')).write_text('{"toolName":"yield"}\n')
        else:
            (j / (holder + '.jsonl')).write_text('{"type":"assistant"}\n')
    ledger.write_text(''.join(json.dumps(r) + '\n' for r in rows))
    if broken == 'missing':
        ledger.unlink()
    elif broken == 'invalid':
        ledger.write_text('{broken json\n')
    elif broken == 'invalid-shape':
        ledger.write_text('null\n')
    elif broken == 'contradictory':
        ledger.write_text('')
    elif broken == 'unreadable':
        ledger.chmod(0)
    event = base / 'event.json'
    event.write_text(json.dumps({'tasks': [{'agent': 'critic', 'name': 'NewCrit154',
                     'task': f'SUBJECT=001\nOBJECT={tip}\n'}]}))
    return repo, s, j, event, ledger


def gate(scripts, repo, state, journals, event):
    return cmd(['bash', str(scripts / 'zamok_predmeta.sh'), '--sudit',
                '--sostojanie', str(state), '--zhurnaly', str(journals),
                '--repo', str(repo), str(event)])


def freeze(scripts, repo, state):
    return cmd(['bash', str(scripts / 'freeze_contract.sh'), 'contracts/001-x.md',
                'criterion accepted', str(repo), str(state)])


def scenario(name, n, phase, outcome='FAIL', arbitraz=False, rename=False,
             broken='', mode='repo', mutation=''):
    with tempfile.TemporaryDirectory(prefix='schet154-') as tmp:
        base = Path(tmp)
        pattern = [outcome] * n
        if name == 'five-alternating':
            pattern = ['FAIL' if i % 2 == 0 else 'accept' for i in range(n)]
        if n and phase == 'freeze':
            pattern[-1] = 'accept'
        repo, state, journals, event, ledger = world(base, n, pattern, arbitraz, rename, broken, phase, name)
        scripts = prepare_scripts(base, mode, mutation)
        before = ledger.read_bytes() if ledger.exists() and broken != 'unreadable' else None
        tag_before = (cmd(['git', '-C', str(repo), 'tag', '-l', 'frozen/contracts/001/*'])
                      if phase == 'freeze' else None)
        if tag_before:
            ensure(tag_before, 'tag before freeze')
        registry = repo / 'registry' / 'contracts.tsv'
        registry_before = registry.read_bytes() if phase == 'freeze' and registry.exists() else None
        result = gate(scripts, repo, state, journals, event) if phase == 'spawn' else freeze(scripts, repo, state)
        # Separate in-memory oracle, captured before the subject; no subject-written file is the oracle.
        expected = ('SCHET_NEIZVESTEN' if broken in ('invalid', 'invalid-shape', 'missing', 'unreadable') else
                    'SCHET_RASHOZHDENIE' if broken == 'contradictory' and n else
                    'KAP_VYZOVOV_KRITIKA' if n >= 5 and phase == 'spawn' else
                    'KAP_VYZOVOV_KRITIKA' if n > 5 and phase == 'freeze' else
                    'SCHET_RASHOZHDENIE' if n == 0 and phase == 'freeze' else '')
        if not expected and result.returncode != 0:
            return f'{name}: expected rc 0, actual {result.returncode}: {result.stderr[-280:]}'
        if expected and (result.returncode == 0 or expected not in result.stderr):
            return f'{name}: expected {expected}, actual rc {result.returncode}: {result.stderr[-280:]}'
        if expected and broken != 'unreadable' and (ledger.read_bytes() if ledger.exists() else None) != before:
            return f'{name}: declined attempt changed ledger'
        if expected and phase == 'freeze':
            tag_after = cmd(['git', '-C', str(repo), 'tag', '-l', 'frozen/contracts/001/*'])
            ensure(tag_after, 'tag after freeze')
            registry_after = registry.read_bytes() if registry.exists() else None
            if tag_after.stdout != tag_before.stdout or registry_after != registry_before:
                return f'{name}: declined freeze changed frozen tag or registry'
        return None


CASES = [
    ('five-identical', 5, 'spawn', 'FAIL', False, False, ''),
    ('five-alternating', 5, 'spawn', 'accept', False, False, ''),
    ('arbitration-sixth', 5, 'spawn', 'FAIL', True, False, ''),
    ('renamed-object', 5, 'spawn', 'FAIL', False, True, ''),
    ('aborted-counts', 5, 'spawn', 'aborted', False, False, ''),
    ('four-plus-accept', 5, 'freeze', 'FAIL', False, False, ''),
    ('five-plus-accept', 6, 'freeze', 'FAIL', False, False, ''),
    ('arbitrated-freeze', 6, 'freeze', 'FAIL', True, False, ''),
    ('freeze-side-effect', 6, 'freeze', 'aborted', True, False, ''),
    ('unreadable-ledger', 5, 'spawn', 'FAIL', False, False, 'unreadable'),
    ('missing-ledger', 5, 'spawn', 'FAIL', False, False, 'missing'),
    ('invalid-ledger', 5, 'spawn', 'FAIL', False, False, 'invalid'),
    ('invalid-shape-ledger', 5, 'spawn', 'FAIL', False, False, 'invalid-shape'),
    ('contradictory-ledger', 5, 'freeze', 'FAIL', False, False, 'contradictory'),
]
CASES += [(f'boundary-spawn-{n}', n, 'spawn', 'FAIL', False, False, '') for n in range(8)]
CASES += [(f'boundary-freeze-{n}', n, 'freeze', 'FAIL', False, False, '') for n in range(8)]
CASES += [
    ('verdict-vplus', 5, 'spawn', 'FAIL', False, False, ''),
    ('verdict-copy', 5, 'spawn', 'FAIL', False, False, ''),
    ('arbitration-owner', 5, 'spawn', 'FAIL', True, False, ''),
    ('arbitration-return', 5, 'spawn', 'FAIL', True, False, ''),
    ('critic-sol-only', 5, 'spawn', 'FAIL', False, False, ''),
]
DOMAIN = [
    (f'domain-{phase}-{n}-{outcome}-a{int(arb)}-r{int(rename)}',
     n, phase, outcome, arb, rename, '')
    for phase in ('spawn', 'freeze')
    for n in range(8)
    for outcome in (('FAIL',) if n == 0 or phase == 'freeze' and n == 1
                    else ('FAIL', 'accept', 'aborted'))
    for arb in (False, True)
    for rename in ((False, True) if n and
                   (phase == 'spawn' and outcome != 'aborted' or
                    phase == 'freeze' and n > 1 and outcome != 'aborted')
                   else (False,))
]


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else 'repo'
    if mode not in ('repo', 'model', 'stabs', 'domain', 'domain-model'):
        print('usage: probe.py [repo|model|stabs|domain|domain-model]', file=sys.stderr)
        return 2
    cases = CASES
    if mode in ('domain', 'domain-model'):
        cases = DOMAIN
    if mode == 'stabs':
        cases = [c for c in CASES if c[0] in (
            'five-identical', 'arbitration-sixth', 'renamed-object', 'aborted-counts',
            'five-plus-accept', 'freeze-side-effect', 'unreadable-ledger', 'contradictory-ledger')]
    failed = 0
    for c in cases:
        name = c[0]
        if mode == 'stabs':
            control = scenario(*c, mode='model')
            if control:
                print(f'MODEL_NOT_GREEN {name}: {control}')
                return 2
        # The pre-implementation baseline is a required red result; each stab is
        # tied to precisely the input where its observable defect differs.
        actual = scenario(*c, mode=('model' if mode in ('stabs', 'domain-model')
                                    else 'repo' if mode == 'domain' else mode),
                          mutation=name if mode == 'stabs' else '')
        if mode == 'stabs':
            if actual is None:
                print(f'STAB_SURVIVED {name}')
                failed += 1
            else:
                print(f'STAB_CAUGHT {name}: {actual}')
        elif actual:
            print(f'RED {actual}')
            failed += 1
        else:
            print(f'GREEN {name}')
    print(f'CELLS={len(cases)} GREEN={len(cases) - failed}' if mode != 'stabs'
          else f'SVJAZI={len(cases)} CAUGHT={len(cases) - failed} LIVE={failed}')
    return 0 if mode == 'stabs' and not failed or mode in ('model', 'domain-model') and not failed else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, ValueError) as e:
        print(f'NOT_IMPLEMENTED: toy world: {e}', file=sys.stderr)
        sys.exit(2)
