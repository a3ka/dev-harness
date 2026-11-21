#!/usr/bin/env python3
"""B-13: full CLI subjects; curl/ls-remote are the existing 992 network seams.

Expectations stay in the parent before invocation. Request records contain only
header digests, never token values. --model/--stabs patch disposable copies of
an explicit base, not production and never a fallback for ordinary acceptance.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import secrets
import shutil
import sys
import tempfile

sys.dont_write_bytecode = True
import fail_closed_992 as fc

ROOT = Path(__file__).resolve().parents[2]
BASE = 'a4f87d04a1d04228d6515b30aaa1e345d0304e5a'
SUBJECTS = {'gate': 'check_ci_gate.sh', 'writer': 'check_ci_gate.sh',
            'land': 'gitw_preflight_071.sh'}
# Explicit expected choices, independent of the implementation expression.
CASES = {
    'gh_unset': (None, 'T', 'T', False),
    'github_only': ('A', None, 'A', False),
    'both': ('A', 'B', 'A', False),
    'gh_empty_github': ('', 'B', 'B', False),
    'no_tokens': (None, None, None, False),
    'empty_tokens': ('', '', None, False),
    'denied': ('A', 'B', 'A', True),
    'denied_gh': (None, 'T', 'T', True),
}
FALLBACK = '${GITHUB_TOKEN:-${GH_TOKEN:-}}'


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()


def curl():
    """API requires the independently supplied authorization, or refuses 403."""
    args = sys.argv[1:]
    headers = [args[i + 1] for i, arg in enumerate(args[:-1])
               if arg in ('-H', '--header')]
    auth = [h for h in headers if h.partition(':')[0].lower() == 'authorization']
    record = {'url': args[-1], 'auth': [digest(h) for h in auth]}
    with open(os.environ['B13_REQUESTS'], 'a') as stream:
        stream.write(json.dumps(record) + '\n')
    if record != json.loads(os.environ['B13_EXPECT_REQUEST']) or os.environ['B13_DENIED'] == '1':
        print('curl: (22) HTTP 403', file=sys.stderr)
        return 22
    print(os.environ['B13_RESPONSE'])
    return 0


def sources(root, model=False):
    result = {}
    for name in set(SUBJECTS.values()):
        if model:
            p = fc.run([fc.GIT, 'show', f'{BASE}:scripts/{name}'], ROOT)
            if p.returncode:
                raise RuntimeError('model base unavailable: ' + p.stderr)
            text = p.stdout
            count = 2 if name == 'check_ci_gate.sh' else 1
            if text.count('${GITHUB_TOKEN:-}') != count or text.count('$GITHUB_TOKEN') != count:
                raise RuntimeError('model base token anchors changed')
            text = text.replace('${GITHUB_TOKEN:-}', FALLBACK).replace('$GITHUB_TOKEN', FALLBACK)
        else:
            text = (root / 'scripts' / name).read_text()
        result[name] = text
    return result


def prepare(base, branch, code):
    root = base / 'repo'
    fc.init(root)
    fc.put(root / 'package.json', '{}\n')
    fc.put(root / 'registry/candidates.tsv', '')
    fc.put(root / 'harness/policy', 'mandatory=unit\nciApp=github-actions\n')
    definition = 'true\n'
    fc.put(root / 'harness/checks/unit.cmd', definition)
    # Real classifier: this toy has no uchet registry, so it performs no API call.
    fc.put(root / 'scripts/ci_klass.sh', (ROOT / 'scripts/ci_klass.sh').read_text())
    fc.commit(root)
    rmain = fc.git(root, 'rev-parse', 'HEAD')
    feature = None
    if branch == 'land':
        fc.git(root, 'checkout', '-qb', 'wip/992/architect')
        fc.put(root / 'feature.txt', 'feature\n')
        fc.commit(root)
        feature = fc.git(root, 'rev-parse', 'HEAD')
        fc.git(root, 'checkout', '-q', 'main')
        fc.put(root / 'main.txt', 'main\n')
        fc.commit(root)
        fc.git(root, 'merge', '--no-ff', '-qm', 'land: wip/992/architect', feature)
    tip = fc.git(root, 'rev-parse', 'HEAD')
    tree = fc.git(root, 'rev-parse', 'HEAD^{tree}')
    fc.git(root, 'remote', 'add', 'origin', 'https://github.com/fixture/fixture.git')
    fc.git(root, 'update-ref', 'refs/remotes/origin/main', tip)
    subject = base / 'scripts' / SUBJECTS[branch]
    fc.put(subject, code[SUBJECTS[branch]])
    fc.put(subject.parent / 'ci_klass.sh', (ROOT / 'scripts/ci_klass.sh').read_text())
    bindir = base / 'bin'
    bindir.mkdir()
    (bindir / 'curl').symlink_to(Path(__file__).resolve())
    fc.put(bindir / 'git', '#!/usr/bin/env python3\nimport os,sys\na=sys.argv[1:]\n'
           + 'if "ls-remote" in a:\n'
           + f' print({(rmain + chr(9) + "refs/heads/main")!r} if "--tags" not in a else "")\n sys.exit(0)\n'
           + f'os.execv({fc.GIT!r}, [{fc.GIT!r}]+a)\n', True)
    url = f'https://api.github.com/repos/fixture/fixture/commits/{tip}/check-runs?per_page=100'
    wfsha = digest(definition)
    response = {'total_count': 1, 'check_runs': [{'name': 'unit', 'id': 73,
                'conclusion': 'success', 'head_sha': tip,
                'app': {'slug': 'github-actions'}, 'wfsha': wfsha}]}
    args = [root, tip]
    if branch == 'writer':
        args += ['--check-row', 'b' * 64, 'unit']
    if branch == 'land':
        args = ['https://github.com/fixture/fixture.git', 'HEAD:main']
        url = f'https://api.github.com/repos/fixture/fixture/actions/runs?event=pull_request&head_sha={feature}'
        response = {'workflow_runs': [{'event': 'pull_request', 'conclusion': 'success'}]}
    expected_row = f'check\t{"b" * 64}\tunit\tok\t73\t{wfsha}\t{tree}\n'
    return root, subject, args, bindir, url, response, expected_row


def observe(parent, branch, case, code):
    with tempfile.TemporaryDirectory(prefix='b13-', dir=parent) as directory:
        base = Path(directory)
        root, subject, args, bindir, url, response, row = prepare(base, branch, code)
        values = {key: 'b13_' + secrets.token_hex(18) for key in ('T', 'A', 'B')}
        github, gh, expected, denied = CASES[case]
        env = dict(fc.BASE_ENV)
        env.pop('GITHUB_TOKEN', None)
        env.pop('GH_TOKEN', None)
        for name, value in (('GITHUB_TOKEN', github), ('GH_TOKEN', gh)):
            if value is not None:
                env[name] = values[value] if value else ''
        request = {'url': url, 'auth': [] if expected is None else
                   [digest('Authorization: Bearer ' + values[expected])]}
        env.update(PATH=f'{bindir}:{env["PATH"]}', TMPDIR=str(base),
                   B13_REQUESTS=str(base / 'requests'), B13_EXPECT_REQUEST=json.dumps(request),
                   B13_RESPONSE=json.dumps(response), B13_DENIED=str(int(denied)),
                   GITW_PREFLIGHT_071_API='https://api.github.com/repos/fixture/fixture')
        # Oracle and initial journal bytes captured before the subject executes.
        expected_rc = 1 if denied else 0
        journal = root / 'registry/candidates.tsv'
        expected_journal = row.encode() if branch == 'writer' and not denied else journal.read_bytes()
        p = fc.run(['bash', subject, *args], root, env)
        records = [json.loads(line) for line in (base / 'requests').read_text().splitlines()] if (base / 'requests').exists() else []
        output = p.stdout + p.stderr
        journal_bytes = journal.read_bytes()
        leak_free = all(token not in output and token.encode() not in journal_bytes for token in values.values())
        request_ok = records == [request]
        effect_ok = journal_bytes == expected_journal
        diagnosis_ok = not denied or ('CI не ответил' if branch != 'land' else 'PR-CI не сверяем: API') in output
        accepted = p.returncode == expected_rc and request_ok and effect_ok and leak_free and diagnosis_ok
        return dict(branch=branch, case=case, rc=p.returncode, expected_rc=expected_rc,
                    request_ok=int(request_ok), effect_ok=int(effect_ok), leak_free=int(leak_free),
                    diagnosis_ok=int(diagnosis_ok), accepted=int(accepted))


def mutants(model):
    # Explicit code binding (Н-39), not prose or all-cases catch-all acceptance.
    for branch in SUBJECTS:
        name = SUBJECTS[branch]
        for label, case, expression in (
            ('S1', 'gh_unset', '${GITHUB_TOKEN:-}'),
            ('S1-empty', 'gh_empty_github', '${GITHUB_TOKEN:-}'),
            ('S2', 'both', '${GH_TOKEN:-${GITHUB_TOKEN:-}}'),
            ('S3', 'gh_empty_github', '${GITHUB_TOKEN-${GH_TOKEN:-}}'),
        ):
            code = dict(model)
            code[name] = code[name].replace(FALLBACK, expression)
            yield f'{label}-{branch}', branch, case, code
        code = dict(model)
        code[name] = 'printf "%s\\n" "${GITHUB_TOKEN:-${GH_TOKEN:-}}" >&2\n' + code[name]
        yield f'S4-{branch}', branch, 'both', code
        code = dict(model)
        code[name] = code[name].replace(f'if [ -n "{FALLBACK}" ]; then', 'if true; then')
        yield f'S6-{branch}', branch, 'no_tokens', code
    # Partial cutovers: each preserved fallback is the only honest request site.
    for kept in SUBJECTS:
        code = dict(model)
        if kept == 'land':
            code['check_ci_gate.sh'] = code['check_ci_gate.sh'].replace(FALLBACK, '${GITHUB_TOKEN:-}')
        else:
            code['gitw_preflight_071.sh'] = code['gitw_preflight_071.sh'].replace(FALLBACK, '${GITHUB_TOKEN:-}')
            text = code['check_ci_gate.sh']
            boundary = text.index('# ── гейт 4б/087')
            writer, gate = text[:boundary], text[boundary:]
            if kept == 'gate':
                writer = writer.replace(FALLBACK, '${GITHUB_TOKEN:-}')
            else:
                gate = gate.replace(FALLBACK, '${GITHUB_TOKEN:-}')
            code['check_ci_gate.sh'] = writer + gate
        for branch in SUBJECTS:
            if branch != kept:
                yield f'S5-only-{kept}-missing-{branch}', branch, 'gh_unset', code


def compatibility(root):
    """Run unchanged neighboring fixtures on live and proposed full scripts."""
    failures = 0
    observations = 0
    for label, code in (('base', sources(root)), ('model', sources(root, True))):
        with tempfile.TemporaryDirectory(prefix='b13-compat-') as directory:
            base = Path(directory)
            subject = base / 'check_ci_gate.sh'
            fc.put(subject, code['check_ci_gate.sh'], True)
            fixtures = sorted((ROOT / 'fixtures/check_ci_gate').glob('case_*.sh'))
            if not fixtures:
                raise RuntimeError('empty compatibility selection')
            for fixture in fixtures:
                work = base / fixture.stem
                work.mkdir()
                env = dict(fc.BASE_ENV, WORK=str(work), BARRIER=str(subject),
                           PATH=f'{work / "bin"}:{os.environ["PATH"]}')
                env.pop('GITHUB_TOKEN', None)
                env.pop('GH_TOKEN', None)
                reason = fixture.read_text().splitlines()[0].removeprefix('# ПРИЧИНА: ')
                p = fc.run(['bash', fixture], ROOT, env)
                accepted = p.returncode == 1 and reason in p.stdout + p.stderr
                print(f'compat={label}/{fixture.name} rc={p.returncode} accepted={int(accepted)}')
                observations += 1
                failures += not accepted
            for case in ('B-ci-ok-write', 'B-ci-fail-write'):
                for fault in (False, True):
                    accepted, rc, _, _ = fc.execute(case, code['check_ci_gate.sh'], fault)
                    print(f'compat={label}/{case} fault={int(fault)} rc={rc} accepted={int(accepted)}')
                    observations += 1
                    failures += not accepted
    print(f'COMPAT observations={observations} failures={failures}')
    return int(failures != 0 or observations == 0)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--list', action='store_true')
    modes.add_argument('--compat', action='store_true')
    parser.add_argument('--root', type=Path, default=ROOT)
    opts = parser.parse_args()
    if opts.list:
        for branch in SUBJECTS:
            for case in CASES:
                print(f'{branch}/{case}')
        return 0
    for binary in ('git', 'jq', 'bash', 'python3', 'npm'):
        if not shutil.which(binary):
            raise RuntimeError('NOT_IMPLEMENTED: missing ' + binary)
    if opts.compat:
        return compatibility(opts.root)
    code = sources(opts.root, opts.model or opts.stabs)
    parent = os.environ.get('TMPDIR')
    failures = 0
    observations = 0
    # Honest control is mandatory before any mutation is judged.
    for branch in SUBJECTS:
        for case in CASES:
            result = observe(parent, branch, case, code)
            print(json.dumps(result, sort_keys=True))
            observations += 1
            failures += not result['accepted']
    print(f'cases={len(SUBJECTS) * len(CASES)} observations={observations} failures={failures}')
    if opts.stabs:
        if failures:
            return 1
        live = 0
        bindings = 0
        for label, branch, case, mutant in mutants(code):
            result = observe(parent, branch, case, mutant)
            caught = not result['accepted']
            # Distinguish a leak mutant by the leak predicate, not incidental rc.
            if label.startswith('S4-'):
                caught = not result['leak_free'] and result['rc'] == 0 and result['request_ok'] and result['effect_ok']
            bindings += 1
            live += not caught
            print(f'stab={label} branch={branch}/{case} caught={int(caught)} ' + json.dumps(result, sort_keys=True))
        print(f'STABS bindings={bindings} LIVE={live}')
        return int(live != 0 or bindings == 0)
    return int(failures != 0 or observations == 0)


if __name__ == '__main__':
    try:
        sys.exit(curl() if Path(sys.argv[0]).name == 'curl' else main())
    except (OSError, RuntimeError, ValueError) as error:
        print(f'B13: {error}', file=sys.stderr)
        sys.exit(2)
