#!/usr/bin/env python3
"""Б-5: model stderr at make_task and the public arch187_brief library seam.

Only the pinned model CLI is a double. The --repo subject is always the real
library/caller. Expected bytes are held here before any subject invocation.
"""
import os
import subprocess

from probe import git


PREFIX = b'ARCH_BRIEF_STDERR: '
FIRST = b'ZZ-first-line'
DETAIL = 'вторая\n'.encode()
NOISE = 'шум\n'.encode()
EMPTY = '(stderr модели пуст)'.encode()
BODY = 'PINNED_BRIEF_187 api.identity\npayload: ё\n'.encode()
REFUSAL = ('ОТКАЗ: ARCH_BRIEF_OTKAZ: api.identity '
           '(закреплённая модель не отдала бриф)\n').encode()
# label, CLI rc, CLI stdout, CLI stderr, with-rules, seam, assertion
CASES = (
    ('brief-stderr-plain', 1, b'partial\n', FIRST + b'\n' + DETAIL, False, 'task', 'channels'),
    ('brief-stderr-rules', 1, b'partial\n', FIRST + b'\n' + DETAIL, True, 'task', 'channels'),
    ('brief-stderr-empty', 1, b'', b'', False, 'task', 'channels'),
    ('brief-stderr-leading-blank', 1, b'', b'\n\n' + FIRST + b'\n' + DETAIL, False, 'task', 'channels'),
    ('brief-empty-output-noisy', 0, b'', FIRST + b'\n' + DETAIL, False, 'task', 'channels'),
    ('brief-empty-output-quiet', 0, b'', b'', True, 'task', 'channels'),
    ('brief-success-noisy', 0, BODY, NOISE, False, 'library', 'channels'),
    ('brief-success-quiet', 0, BODY, b'', True, 'library', 'channels'),
    ('brief-cleanup-failure', 1, b'', FIRST + b'\n' + DETAIL, False, 'library', 'cleanup'),
    ('brief-cleanup-success', 0, BODY, b'', True, 'library', 'cleanup'),
)
# Branch ownership is executable, not assigned in frozen prose (Н-39).
STABS = {
    **{f'brief-S1-devnull-{branch}': (f'brief-stderr-{branch}', 'devnull')
       for branch in ('plain', 'rules', 'empty')},
    'brief-S2-all-stderr': ('brief-stderr-plain', 'all-stderr'),
    'brief-S3-noisy-success': ('brief-success-noisy', 'print-success'),
    'brief-S4-plain-only': ('brief-stderr-rules', 'plain-only'),
    'brief-S5-empty-missing': ('brief-stderr-empty', 'empty-missing'),
    'brief-S6-leak-failure': ('brief-cleanup-failure', 'leak'),
    **{f'brief-S7-append-{branch}': (f'brief-success-{branch}', 'append')
       for branch in ('noisy', 'quiet')},
    'brief-empty-output-skipped': ('brief-empty-output-noisy', 'devnull'),
    'brief-empty-output-quiet-skipped': ('brief-empty-output-quiet', 'empty-missing'),
}
CONFIG = {label: {'rc': rc, 'stdout': out.decode(), 'stderr': err.decode(),
                  'rules': rules}
          for label, rc, out, err, rules, _, _ in CASES}

LIBRARY_CALL = '''ARCH187_LIB=1
source "$1" || exit 2
trap 'arch187_cleanup' EXIT
arch187_model_prepare "$2" || exit 2
arch187_brief api.identity "$3"
'''


def expected(case):
    _, rc, out, err, _, seam, _ = case
    failed = rc != 0 or not out
    if not failed:
        return subprocess.CompletedProcess([], 0, out, b'')
    diagnostic = PREFIX + next((line for line in err.splitlines() if line), EMPTY) + b'\n'
    return subprocess.CompletedProcess([], 1, b'', diagnostic + (REFUSAL if seam == 'task' else b''))


def observed(case, result, scratch):
    # The cleanup property is independent of diagnostic presence: no placebo red
    # is demanded on a base that never allocated a stderr capture file.
    if case[-1] == 'cleanup':
        return result.returncode == expected(case).returncode and not list(scratch.iterdir())
    wanted = expected(case)
    return (result.returncode, result.stdout, result.stderr) == (
        wanted.returncode, wanted.stdout, wanted.stderr)


def model(case, scratch, mutant=''):
    _, rc, out, err, rules, seam, _ = case
    failed = bool(rc) or not out
    diagnostic = b''
    if failed:
        first = err.lstrip(b'\n').partition(b'\n')[0] or EMPTY
        diagnostic = PREFIX + first + b'\n'
        if seam == 'task':
            diagnostic += REFUSAL
    answer = subprocess.CompletedProcess([], int(failed), b'' if failed else out, diagnostic)
    if mutant == 'devnull' or (mutant == 'plain-only' and rules):
        answer.stderr = REFUSAL if seam == 'task' else b''
    elif mutant == 'all-stderr':
        answer.stderr = PREFIX + err + (REFUSAL if seam == 'task' else b'')
    elif mutant == 'print-success':
        answer.stderr = PREFIX + err
    elif mutant == 'empty-missing':
        answer.stderr = PREFIX + b'\n' + (REFUSAL if seam == 'task' else b'')
    elif mutant == 'append':
        answer.stdout = out + b'\n'
    elif mutant == 'leak':
        (scratch / 'arch-brief-leaked').mkdir()
    return answer


def run_cases(base, tools, model_mode, stabs_mode, world, architecture, prepare, live):
    failures = []
    for case in CASES:
        label, _, _, _, rules, seam, _ = case
        root = world(base, label)
        arch, pinned = architecture(base, root, label)
        task, trace, _ = prepare(root, arch, pinned, label)
        role = 'architect' if rules else 'implementer'
        trace.write_text(role + '\tzai/glm-5.3\tallowed\n')
        if role == 'implementer' and seam == 'task':
            # Same prerequisite as the existing no-rules world: executable
            # work is delivered only after this toy contract is frozen.
            git(root, 'tag', 'frozen/contracts/777/1')
        scratch = base / (label + '-tmp')
        scratch.mkdir()
        if model_mode or stabs_mode:
            result = model(case, scratch)
        elif seam == 'task':
            result = live(tools, root, arch, pinned, 'task', task, trace, role, label)
            result.stdout = result.stdout.encode()
            result.stderr = result.stderr.encode()
        else:
            env = {key: value for key, value in os.environ.items() if not key.startswith('GIT_')}
            env.update(TMPDIR=str(scratch), ARCHITECTURE_ROOT=str(arch),
                       GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null')
            result = subprocess.run(['bash', '-c', LIBRARY_CALL, 'brief-b5',
                                     str(tools / 'scripts/check_architecture_contract.sh'),
                                     str(root), str(int(rules))], cwd=root, env=env,
                                    capture_output=True, timeout=45)
        ok = observed(case, result, scratch)
        if not ok:
            failures.append(label)
        print(f'{"GREEN" if ok else "RED"} {label}: rc={result.returncode} '
              f'expected={expected(case).returncode}' +
              (f' stdout={result.stdout!r} stderr={result.stderr!r} '
               f'scratch={[p.name for p in scratch.iterdir()]!r}' if not ok else ''))
        if stabs_mode:
            for name, (branch, mutation) in STABS.items():
                if branch != label:
                    continue
                fake = model(case, scratch, mutation)
                caught = not observed(case, fake, scratch)
                print(f'STAB {name} {"caught" if caught else "ZHIV"} @ {label}')
                if not caught:
                    failures.append(name)
                if mutation == 'leak':
                    (scratch / 'arch-brief-leaked').rmdir()
    # Exact static predicate from Fable; no hand-written shell/YAML parser.
    subject = tools / 'scripts/check_architecture_contract.sh'
    if model_mode or stabs_mode:
        subject = base / 'fable-brief-control.sh'
        subject.write_text('node tooling/checks/cli.js brief --compact 2>\"$stderr_file\"\\n')
    result = subprocess.run(
        ['bash', '-c', "! grep -n 'cli.js brief' \"$1\" | grep -q '2>/dev/null'",
         'fable-b5', str(subject)], capture_output=True, timeout=10)
    rc = result.returncode
    label = 'brief-stderr-fable-static'
    print(f'{"GREEN" if rc == 0 else "RED"} {label}: rc={rc} expected=0')
    if rc:
        failures.append(label)
    return failures
