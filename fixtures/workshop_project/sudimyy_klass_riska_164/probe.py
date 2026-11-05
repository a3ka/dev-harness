#!/usr/bin/env python3
"""164: public risk-verdict seam; oracle stays in memory before invoking the subject."""
import argparse
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
SUBJECT = ROOT / 'scripts' / 'check_judged_risk.sh'
CONTRACT = 'contracts/164-risk.md'
VERDICT = 'verdicts/critic/contracts-164-v1.md'
DECL = 'КЛАСС РИСКА: '
JUDGED = 'СУД-КЛАССА-РИСКА: '
# Existing 140 declaration terminators; only metadata lines, not blockquotes/code.
DECL_RE = re.compile(r'КЛАСС РИСКА:[ \t]*(обычный|рисковый)(?=[ \t.,;]|$)')
JUDGE_RE = re.compile(r'^СУД-КЛАССА-РИСКА: (обычный|рисковый)$')


def metadata(text):
    fenced = False
    lines = []
    for line in text.splitlines():
        if line.startswith('```'):
            fenced = not fenced
        elif not fenced and not line.lstrip().startswith('>'):
            lines.append(line)
    return lines


def declarations(text):
    found = []
    for line in metadata(text):
        found.extend(DECL_RE.findall(line))
    return found


def git(repo, *args):
    return subprocess.run(['git', '-C', str(repo), *args], capture_output=True, text=True, check=True).stdout.strip()


def world(declaration='обычный', judged='обычный', verdict_extra='', contract_extra='',
          verdict_first='accept', mutate_after=False, object_override=None, contract_text=None):
    temp = tempfile.TemporaryDirectory(prefix='risk164-')
    repo = Path(temp.name)
    (repo / 'contracts').mkdir()
    (repo / 'verdicts' / 'critic').mkdir(parents=True)
    git(repo, 'init', '-q')
    git(repo, 'config', 'user.name', 'fixture')
    git(repo, 'config', 'user.email', 'fixture@example.invalid')
    contract = repo / CONTRACT
    contract.write_text(contract_text if contract_text is not None else
                        '# Subject 164\nКЛАСС ЗАДАЧИ: кодовый. ' + DECL + declaration + '\n'
                        + contract_extra, encoding='utf-8')
    git(repo, 'add', CONTRACT)
    git(repo, 'commit', '-qm', 'candidate')
    object_id = git(repo, 'rev-parse', 'HEAD')
    verdict = repo / VERDICT
    verdict.write_text(verdict_first + '\nOBJECT=' + (object_override or object_id)
                       + '\n' + (JUDGED + judged + '\n' if judged is not None else '')
                       + verdict_extra, encoding='utf-8')
    git(repo, 'add', VERDICT)
    git(repo, 'commit', '-qm', 'judge')
    if mutate_after:
        contract.write_text(contract.read_text(encoding='utf-8') + '\nPost-verdict mutation\n', encoding='utf-8')
        git(repo, 'add', CONTRACT)
        git(repo, 'commit', '-qm', 'changed-after-judge')
    return temp, repo


def reference(repo):
    """Tiny honest control, separate from the candidate script, not the oracle."""
    contract = (repo / CONTRACT).read_text(encoding='utf-8')
    verdict = (repo / VERDICT).read_text(encoding='utf-8')
    found = declarations(contract)
    marks = [m.group(1) for line in metadata(verdict) if (m := JUDGE_RE.fullmatch(line))]
    if len(found) != 1:
        return 1, 'RISK_DECLARATION_INVALID'
    if verdict.splitlines()[0] != 'accept' or len(marks) != 1:
        return 1, 'JUDGMENT_MISSING'
    object_lines = [line.removeprefix('OBJECT=') for line in metadata(verdict)
                    if re.fullmatch(r'OBJECT=[0-9a-f]{40}', line)]
    if len(object_lines) != 1:
        return 1, 'JUDGMENT_OBJECT_INVALID'
    try:
        original = git(repo, 'rev-parse', object_lines[0] + ':' + CONTRACT)
        current = git(repo, 'rev-parse', 'HEAD:' + CONTRACT)
        committed_verdict = git(repo, 'rev-parse', 'HEAD:' + VERDICT)
        disk_verdict = git(repo, 'hash-object', str(repo / VERDICT))
    except subprocess.CalledProcessError:
        return 1, 'JUDGMENT_OBJECT_INVALID'
    if original != current or committed_verdict != disk_verdict:
        return 1, 'JUDGMENT_STALE'
    if found[0] != marks[0]:
        return 1, 'RISK_CLASS_MISMATCH'
    return 0, ''


def stab_ignore_judge(repo):
    return 0, ''


def stab_accept_ordinary(repo):
    declared = declarations((repo / CONTRACT).read_text(encoding='utf-8'))
    return (0, '') if declared == ['обычный'] else reference(repo)


def stab_first_marker(repo):
    verdict = (repo / VERDICT).read_text(encoding='utf-8')
    first = [m.group(1) for line in metadata(verdict) if (m := JUDGE_RE.fullmatch(line))]
    if len(first) > 1 and first[0] == 'обычный':
        return 0, ''
    return reference(repo)


def stab_ignore_object(repo):
    verdict = (repo / VERDICT).read_text(encoding='utf-8')
    if 'OBJECT=' in verdict and verdict.splitlines()[0] == 'accept':
        declared = declarations((repo / CONTRACT).read_text(encoding='utf-8'))
        marks = [m.group(1) for line in metadata(verdict) if (m := JUDGE_RE.fullmatch(line))]
        if declared == marks and len(marks) == 1:
            return 0, ''
    return reference(repo)


def stab_accept_comment(repo):
    contract = (repo / CONTRACT).read_text(encoding='utf-8')
    verdict = (repo / VERDICT).read_text(encoding='utf-8')
    if 'СУД-КЛАССА-РИСКА: обычный' in verdict and 'КЛАСС РИСКА: обычный' in contract:
        return 0, ''
    return reference(repo)


CASES = [
    ('ordinary-honest', {}, 0, ''),
    ('risky-honest', {'declaration': 'рисковый', 'judged': 'рисковый'}, 0, ''),
    ('actual-164-contract', {'judged': 'рисковый',
                             'contract_text': (ROOT / 'contracts' /
                                               '164-sudimyy-klass-riska.md').read_text(encoding='utf-8')},
     0, ''),
    ('ordinary-downgrade', {'declaration': 'обычный', 'judged': 'рисковый'}, 1, 'RISK_CLASS_MISMATCH'),
    ('risky-mismatch', {'declaration': 'рисковый', 'judged': 'обычный'}, 1, 'RISK_CLASS_MISMATCH'),
    ('missing-judgment', {'judged': None}, 1, 'JUDGMENT_MISSING'),
    ('rejected-verdict', {'verdict_first': 'FAIL'}, 1, 'JUDGMENT_MISSING'),
    ('two-judgments', {'verdict_extra': JUDGED + 'рисковый\n'}, 1, 'JUDGMENT_MISSING'),
    ('quoted-judgment', {'judged': None, 'verdict_extra': '> ' + JUDGED + 'обычный\n'}, 1, 'JUDGMENT_MISSING'),
    ('fenced-judgment', {'judged': None, 'verdict_extra': '```\n' + JUDGED + 'обычный\n```\n'},
     1, 'JUDGMENT_MISSING'),
    ('duplicate-object', {'verdict_extra': 'OBJECT=' + '0' * 40 + '\n'},
     1, 'JUDGMENT_OBJECT_INVALID'),
    ('invalid-object', {'object_override': '0' * 40}, 1, 'JUDGMENT_OBJECT_INVALID'),
    ('post-verdict-edit', {'mutate_after': True}, 1, 'JUDGMENT_STALE'),
    ('comment-only-declaration', {'declaration': 'непонятный', 'contract_extra':
      '> ' + DECL + 'обычный\n'}, 1, 'RISK_DECLARATION_INVALID'),
    ('two-declarations', {'contract_extra': DECL + 'рисковый\n'}, 1, 'RISK_DECLARATION_INVALID'),
]
STABS = [
    ('ignore-judge', stab_ignore_judge, 'ordinary-downgrade'),
    ('accept-ordinary', stab_accept_ordinary, 'missing-judgment'),
    ('first-marker', stab_first_marker, 'two-judgments'),
    ('ignore-object', stab_ignore_object, 'post-verdict-edit'),
    ('accept-comment', stab_accept_comment, 'comment-only-declaration'),
]


def candidate(repo):
    if not SUBJECT.is_file():
        return 1, 'SUBJECT_ABSENT'
    result = subprocess.run(['bash', str(SUBJECT), '--repo', str(repo), '--contract', CONTRACT,
                             '--verdict', VERDICT], capture_output=True, text=True, timeout=15)
    return result.returncode, result.stdout + result.stderr


def check(actual, expected):
    rc, text = actual
    want_rc, reason = expected
    return rc == want_rc and (not reason or re.search(r'(?m)^' + re.escape(reason) + r'$', text) is not None)


def run(mode):
    failures = []
    if mode == 'repo' and not SUBJECT.is_file():
        print('SUBJECT_ABSENT', file=sys.stderr)
        return 1
    for name, options, rc, reason in CASES:
        temp, repo = world(**options)
        try:
            expected = (rc, reason)  # captured in memory before calling subject
            result = reference(repo) if mode != 'repo' else candidate(repo)
            if not check(result, expected):
                failures.append(f'{name}: expected {expected}, actual {result}')
        finally:
            temp.cleanup()
    if mode == 'stabs':
        for name, stub, cell in STABS:
            options = next(opts for case, opts, _, _ in CASES if case == cell)
            expectation = next((rc, reason) for case, _, rc, reason in CASES if case == cell)
            temp, repo = world(**options)
            try:
                honest = reference(repo)
                deceit = stub(repo)
                if not check(honest, expectation) or check(deceit, expectation):
                    failures.append(f'{name}@{cell}: honest={honest}; stub={deceit}')
                else:
                    print(f'{name}@{cell}: {deceit[0]} != {expectation[0]}')
            finally:
                temp.cleanup()
    for item in failures:
        print(item, file=sys.stderr)
    if not failures and mode == 'stabs':
        print(f'контроль зелёный; стабов {len(STABS)}, непойманных 0')
    if not failures and mode == 'model':
        print(f'контроль зелёный; клеток {len(CASES)}')
    return 1 if failures else 0


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--model', action='store_true')
    group.add_argument('--stabs', action='store_true')
    group.add_argument('--repo', action='store_true', help='exercise actual script on isolated repos')
    args = parser.parse_args()
    sys.exit(run('model' if args.model else 'stabs' if args.stabs else 'repo'))
