#!/usr/bin/env python3
"""991: compare trusted Git snapshots, never execute code from the candidate.

Usage: --repo R --base B --head C --phase negative|freeze|positive [--matrix]
PyYAML is required. rc=0 accepted, rc=1 named violation, rc=2 unreadable input.

Delta grammar (all other YAML nodes are immutable): D1 is upload-artifact using
an apk-${{ github.sha }}-${{ github.run_id }}-${{ github.run_attempt }} name;
D2 uses the same suffix with maestro-. github.sha is the checkout SHA, not C.
D3/D4 new run steps carry id rehearsal_version/rehearsal_evidence respectively.
Their optional fields are name, shell, working-directory; they have no if/env/
continue-on-error. Bodies are judged by the contract's independent replay, not
by a substring pretending to establish shell semantics. D3 install is manually
reviewed. New scripts must be invoked directly by these steps as bash/python3
scripts/<file> (mobile cwd) or mobile/scripts/<file> (root cwd).

Ds5 is required exactly once in positive, only in mobile-cloud-e2e.yml job
android-e2e-cloud, immediately between existing KVM and emulator steps. Its
entire YAML object (including run whitespace) must equal DISK_SPACE below.
It is the only permitted new step before the emulator; negative/freeze forbid it.

--matrix loads the real B once and constructs independent C snapshots in memory;
it does not modify the Complior checkout or claim to run Android/evidence code.
Every countermodel's binding and expected diagnosis lives in matrix_carriers.py.
"""
import argparse
from pathlib import Path, PurePosixPath
import re
import shlex
import subprocess
import sys

try:
    import yaml
except ImportError as error:
    print(f'991 UNREADABLE_INPUT: {error}', file=sys.stderr)
    sys.exit(2)

HERE = Path(__file__).resolve().parent
MOBILE = '.github/workflows/mobile.yml'
CLOUD = '.github/workflows/mobile-cloud-e2e.yml'
WORKFLOWS = (MOBILE, CLOUD)
PRODUCT = 'mobile/src/features/start/start-screen.tsx'
PINS = {
    'mobile/src/features/start/__tests__/rehearsal.test.tsx': ('rehearsal.test.tsx', 'JEST_BYTES_MISMATCH'),
    'mobile/.maestro/rehearsal.yaml': ('rehearsal.yaml', 'FLOW_BYTES_MISMATCH'),
}
EXISTING = ('mobile/src/features/start/__tests__/start-screen.test.tsx', 'mobile/.maestro/start.yaml')
SCRIPTS = 'mobile/scripts/'
NATIVE = 'Эмулятор API 36 + сценарии Maestro'
ARTIFACTS = 'Артефакты (скриншоты, отчёт)'
SUFFIX = '${{ github.sha }}-${{ github.run_id }}-${{ github.run_attempt }}'
APK = 'mobile/android/app/build/outputs/apk/release/app-release.apk'
RUN_IDS = {'freeze': 'rehearsal_version', 'positive': 'rehearsal_evidence'}
DISK_SPACE = {
    'name': 'Освобождение диска перед cloud-эмулятором',
    'id': 'rehearsal_disk_space',
    'shell': 'bash',
    'working-directory': '.',
    'run': (
        'df -h /\n'
        'sudo rm -rf -- /usr/share/dotnet /usr/local/lib/android/sdk/ndk '
        '/opt/ghc /usr/local/.ghcup /opt/hostedtoolcache/CodeQL\n'
        'df -h /\n'
    ),
}


class Violation(Exception):
    pass


class Unreadable(Exception):
    pass


class WorkflowLoader(yaml.SafeLoader):
    """GitHub's on is a string, not YAML 1.1's boolean; reject duplicate keys."""


WorkflowLoader.yaml_implicit_resolvers = {
    key: [(tag, regex) for tag, regex in entries if tag != 'tag:yaml.org,2002:bool']
    for key, entries in yaml.SafeLoader.yaml_implicit_resolvers.items()
}
WorkflowLoader.add_implicit_resolver('tag:yaml.org,2002:bool', re.compile(r'^(?:true|false)$', re.I), list('tTfF'))


def mapping(loader, node):
    result = {}
    for key_node, value_node in node.value:
        key = loader.construct_object(key_node, deep=True)
        if not isinstance(key, str) or key in result:
            raise Unreadable('YAML key is duplicate or not a string')
        result[key] = loader.construct_object(value_node, deep=True)
    return result


WorkflowLoader.add_constructor('tag:yaml.org,2002:map', mapping)


def parse(data):
    try:
        obj = yaml.load(data, Loader=WorkflowLoader)
        if not isinstance(obj, dict) or not isinstance(obj.get('jobs'), dict) or not obj['jobs']:
            raise Unreadable('workflow has no jobs mapping')
        for job in obj['jobs'].values():
            if not isinstance(job, dict) or not isinstance(job.get('steps'), list):
                raise Unreadable('job has no steps list')
            if not all(isinstance(step, dict) for step in job['steps']):
                raise Unreadable('step is not a mapping')
        return obj
    except (yaml.YAMLError, UnicodeError, RecursionError) as error:
        raise Unreadable(f'YAML: {error}') from error


def equal(a, b):
    # Python normally equates True and 1; that is not YAML-object equality.
    if type(a) is not type(b):
        return False
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(equal(a[k], b[k]) for k in a)
    if isinstance(a, list):
        return len(a) == len(b) and all(equal(x, y) for x, y in zip(a, b))
    return a == b


def git(repo, *args):
    proc = subprocess.run(['git', '-C', str(repo), *args], capture_output=True)
    if proc.returncode:
        raise Unreadable(proc.stderr.decode(errors='replace').strip())
    return proc.stdout


def resolve(repo, ref):
    return git(repo, 'rev-parse', '--verify', '--end-of-options', ref + '^{commit}').decode().strip()


def selected(path):
    return path in (*WORKFLOWS, PRODUCT, *PINS, *EXISTING) or path.startswith(SCRIPTS)


def snapshot(repo, commit):
    files = {}
    for entry in git(repo, 'ls-tree', '-r', '-z', commit).split(b'\0'):
        if not entry:
            continue
        header, raw_path = entry.split(b'\t', 1)
        path = raw_path.decode('utf-8')
        if selected(path):
            mode, kind, _ = header.decode().split()
            if kind != 'blob' or mode not in ('100644', '100755'):
                raise Unreadable(f'not a regular blob: {path}')
            files[path] = git(repo, 'show', f'{commit}:{path}')
    return files


def carrier(path, job, node):
    raise Violation(f'CARRIER_CHANGED: {path}:{job}:{node}')


def without(obj, *keys):
    return {k: v for k, v in obj.items() if k not in keys}


def artifact_name(value, prefix):
    # Whitespace within Actions expressions has no semantic significance.
    return isinstance(value, str) and re.sub(r'\s+', '', value) == re.sub(r'\s+', '', prefix + '-' + SUFFIX)


def delta_existing(base, head, path, phase):
    if phase != 'freeze':
        return False
    if base.get('name') == ARTIFACTS:
        bw, cw = base.get('with'), head.get('with')
        return (isinstance(bw, dict) and isinstance(cw, dict)
                and equal(without(base, 'with'), without(head, 'with'))
                and equal(without(bw, 'name', 'if-no-files-found'), without(cw, 'name', 'if-no-files-found'))
                and artifact_name(cw.get('name'), 'maestro') and cw.get('if-no-files-found') == 'error')
    if path == CLOUD and base.get('name') == 'Maestro':
        # Side effects of this install body are the explicitly named manual risk.
        return (equal(without(base, 'run'), without(head, 'run'))
                and isinstance(head.get('run'), str) and bool(head['run'].strip())
                and re.search(r'(?<![\d.])2\.11\.0(?![\d.])', head['run']) is not None)
    return False


def new_delta(step, path, phase):
    if phase in ('negative', 'freeze') and (phase != 'negative' or path == MOBILE):
        if (set(step) <= {'name', 'uses', 'if', 'with'}
                and step.get('uses') == 'actions/upload-artifact@v7'
                and step.get('if') in ('always()', '${{ always() }}')):
            opts = step.get('with')
            if (isinstance(opts, dict) and set(opts) <= {'name', 'path', 'if-no-files-found', 'retention-days'}
                    and artifact_name(opts.get('name'), 'apk') and opts.get('path') == APK
                    and opts.get('if-no-files-found') == 'error'):
                return 'apk'
    if (phase in RUN_IDS and step.get('id') == RUN_IDS[phase]
            and set(step) <= {'id', 'name', 'run', 'shell', 'working-directory'}
            and isinstance(step.get('run'), str) and step['run'].strip()
            and step.get('shell', 'bash') in ('bash', 'bash --noprofile --norc -eo pipefail {0}')
            and step.get('working-directory', 'mobile') in ('.', 'mobile')):
        return RUN_IDS[phase]
    return None


def compare_workflow(base, head, path, phase):
    if not equal(without(base, 'jobs'), without(head, 'jobs')):
        carrier(path, 'top', 'keys')
    if base['jobs'].keys() != head['jobs'].keys():
        carrier(path, 'jobs', 'set')
    disk_required = phase == 'positive' and path == CLOUD
    if disk_required and 'android-e2e-cloud' not in head['jobs']:
        carrier(path, 'android-e2e-cloud', 'missing-Ds5')
    new_runs = []
    for name, bj in base['jobs'].items():
        cj = head['jobs'][name]
        if name in ('quality', 'expo-versions'):
            if not equal(bj, cj):
                carrier(path, name, 'whole-job')
            continue
        if not equal(without(bj, 'steps'), without(cj, 'steps')):
            carrier(path, name, 'keys')
        cursor = 0
        native_seen = False
        additions = set()
        for index, cs in enumerate(cj['steps']):
            bs = bj['steps'][cursor] if cursor < len(bj['steps']) else None
            if (disk_required and name == 'android-e2e-cloud'
                    and equal(cs, DISK_SPACE)
                    and 'rehearsal_disk_space' not in additions
                    and cursor > 0 and bj['steps'][cursor - 1].get('name') == 'KVM'
                    and bs is not None and bs.get('name') == NATIVE
                    and index > 0 and cj['steps'][index - 1].get('name') == 'KVM'):
                additions.add('rehearsal_disk_space')
                continue
            if bs is not None and (equal(bs, cs) or delta_existing(bs, cs, path, phase)):
                native_seen |= bs.get('name') == NATIVE
                cursor += 1
                continue
            delta = new_delta(cs, path, phase)
            if not native_seen or delta is None or delta in additions:
                carrier(path, name, f'steps[{index}]')
            additions.add(delta)
            if delta in RUN_IDS.values():
                new_runs.append(cs)
        if cursor != len(bj['steps']):
            carrier(path, name, f'missing-step[{cursor}]')
        if disk_required and name == 'android-e2e-cloud' and 'rehearsal_disk_space' not in additions:
            carrier(path, name, 'missing-Ds5')
    return new_runs


def referenced_scripts(steps):
    paths = set()
    for step in steps:
        for line in step['run'].splitlines():
            try:
                words = shlex.split(line, comments=True)
            except ValueError:
                continue  # replay rejects invalid shell; not an authorization.
            if len(words) >= 2 and words[0] in ('bash', 'python3'):
                root = 'mobile' if step.get('working-directory', 'mobile') == 'mobile' else ''
                path = str(PurePosixPath(root) / words[1])
                if '..' not in PurePosixPath(path).parts:
                    paths.add(path)
    return paths


def compare(base, head, changed, phase, pins):
    # Parse both complete workflows even when a path violation is also present:
    # unreadable measurement must never be confused with a completed comparison.
    required = (*WORKFLOWS, *EXISTING, *(p for p in base if p.startswith(SCRIPTS)))
    for path in required:
        if path not in base or path not in head:
            raise Unreadable(f'missing blob: {path}')
    workflows = {p: (parse(base[p]), parse(head[p])) for p in WORKFLOWS}
    for path in sorted(changed):
        if path not in (*WORKFLOWS, PRODUCT, *PINS) and not path.startswith(SCRIPTS):
            raise Violation(f'PR_ZONE_VIOLATION: {path}')
    for path in (*EXISTING, *(p for p in base if p.startswith(SCRIPTS))):
        if base[path] != head[path]:
            raise Violation(f'EXISTING_CHECK_CHANGED: {path}')
    new_runs = []
    for path, (bw, cw) in workflows.items():
        new_runs.extend(compare_workflow(bw, cw, path, phase))
    for path, (_, reason) in PINS.items():
        if path in head and head[path] != pins[path]:
            raise Violation(reason)
        if path in base and path not in head:
            raise Unreadable(f'missing blob: {path}')
    referenced = referenced_scripts(new_runs)
    for path in head.keys() - base.keys():
        if path.startswith(SCRIPTS) and path not in referenced:
            raise Violation(f'NEW_SCRIPT_NOT_REFERENCED: {path}')


def outcome(base, head, changed, phase, pins):
    try:
        compare(base, head, changed, phase, pins)
        return 0, 'ACCEPTED'
    except Violation as error:
        return 1, str(error)
    except (Unreadable, RecursionError) as error:
        return 2, f'UNREADABLE_INPUT: {error}'


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--base', required=True)
    parser.add_argument('--head')
    parser.add_argument('--phase', choices=('negative', 'freeze', 'positive'))
    parser.add_argument('--matrix', action='store_true')
    args = parser.parse_args()
    pins = {path: (HERE / fixture).read_bytes() for path, (fixture, _) in PINS.items()}
    base_sha = resolve(args.repo, args.base)
    base = snapshot(args.repo, base_sha)
    if args.matrix:
        from matrix_carriers import run_matrix
        return run_matrix(base, pins, base_sha)
    if not args.head or not args.phase:
        parser.error('--head and --phase are required without --matrix')
    head_sha = resolve(args.repo, args.head)
    head = snapshot(args.repo, head_sha)
    changed = {p.decode('utf-8') for p in git(args.repo, 'diff', '--no-ext-diff', '--no-renames', '--name-only', '-z', base_sha, head_sha).split(b'\0') if p}
    rc, reason = outcome(base, head, changed, args.phase, pins)
    print(f'991 carriers phase={args.phase} base={base_sha} head={head_sha} rc={rc} {reason}')
    return rc


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (OSError, UnicodeError, Unreadable, ValueError, RecursionError) as error:
        print(f'991 UNREADABLE_INPUT: {error}', file=sys.stderr)
        sys.exit(2)
