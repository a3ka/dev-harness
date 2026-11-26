#!/usr/bin/env python3
"""227 public CLI, configured Git-world reports and the real CI generator."""
import argparse
import copy
import csv
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

import build

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
DEFAULT = json.loads((HERE / 'model' / build.CONFIG).read_bytes())
ENV = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
ENV.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null', LC_ALL='C')


class Unavailable(RuntimeError):
    pass


def run(command, cwd, env=None):
    try:
        return subprocess.run(command, cwd=cwd, env=ENV if env is None else env,
                              capture_output=True, timeout=45)
    except (OSError, subprocess.TimeoutExpired) as error:
        raise Unavailable(str(error)) from error


def required(command, cwd):
    result = run(command, cwd)
    if result.returncode:
        raise Unavailable(repr((command, result.returncode, result.stdout, result.stderr)))
    return result


def put(root, file, data):
    path = root / file
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(data.encode() if isinstance(data, str) else data)


def case(name, files, records, **options):
    return {'name': name, 'files': files,
            'records': [{'path': p, 'line': n, 'text': t} for p, n, t in records], **options}


def cases():
    return [
        case('nonempty', {'scripts/a.sh': 'clean\nComplior-back Complior-mob\n.harness/x\n',
                          '.omp/extensions/b.ts': 'a3ka/Complior-extra\n',
                          '.githooks/pre-commit': 'complior-mob\n'},
             [('.githooks/pre-commit', 1, 'complior-mob'),
              ('.omp/extensions/b.ts', 1, 'a3ka/Complior-extra'),
              ('scripts/a.sh', 2, 'Complior-back Complior-mob'), ('scripts/a.sh', 3, '.harness/x')]),
        case('empty', {'scripts/clean.sh': 'clean\n'}, []),
        case('excluded-only', {'scripts/proxy/a.sh': 'Complior-back\n'}, []),
        case('exclude-boundary', {'scripts/proxy2/a.sh': 'Complior-mob\n',
                                  'scripts/proxy/a.sh': 'Complior-back\n'},
             [('scripts/proxy2/a.sh', 1, 'Complior-mob')]),
        case('changed-pattern', {'scripts/a.sh': 'CUSTOM_19\nComplior-back\nCUSTOM_x\n'},
             [('scripts/a.sh', 1, 'CUSTOM_19')], config={'pattern': 'CUSTOM_[0-9]+'}),
        case('changed-include', {'extras/a.txt': 'Complior-back\n', 'scripts/a.sh': 'Complior-mob\n'},
             [('extras/a.txt', 1, 'Complior-back')], config={'include': ['extras']}),
        case('changed-exclude', {'scripts/a.sh': 'Complior-back\n', 'scripts/proxy/a.sh': 'Complior-mob\n'},
             [('scripts/proxy/a.sh', 1, 'Complior-mob')], config={'exclude': ['scripts/a.sh']}),
        case('no-excludes', {'scripts/proxy/a.sh': 'Complior-back\n'},
             [('scripts/proxy/a.sh', 1, 'Complior-back')], config={'exclude': []}),
        case('untracked', {'scripts/a.sh': 'clean\n'}, [], untracked={'scripts/loose.sh': 'Complior-back\n'}),
        case('binary', {'scripts/binary.dat': b'\0Complior-back\n'}, []),
        case('same-content', {'scripts/a.sh': 'Complior-back\nComplior-back\n',
                              'scripts/b.sh': 'Complior-back\n'},
             [('scripts/a.sh', 1, 'Complior-back'), ('scripts/a.sh', 2, 'Complior-back'),
              ('scripts/b.sh', 1, 'Complior-back')]),
        case('line-numbers', {'scripts/a.sh': 'clean\n\n  before:Complior-back:after\n'},
             [('scripts/a.sh', 3, '  before:Complior-back:after')]),
        case('comments', {'scripts/a.sh': '# Complior-back\n'}, [('scripts/a.sh', 1, '# Complior-back')]),
        case('substring', {'scripts/a.sh': 'prefixComplior-backsuffix\n'},
             [('scripts/a.sh', 1, 'prefixComplior-backsuffix')]),
        case('unicode-path', {'scripts/имя :\t\n.sh': '  complior-back: хвост\n'},
             [('scripts/имя :\t\n.sh', 1, '  complior-back: хвост')]),
        case('literal-paths', {'other[*]/a.sh': 'Complior-back\n', 'otherX/a.sh': 'Complior-mob\n'},
             [('other[*]/a.sh', 1, 'Complior-back')], config={'include': ['other[*]'], 'exclude': []}),
        case('literal-excludes', {'scripts/a[*].sh': 'Complior-back\n', 'scripts/aX.sh': 'Complior-mob\n'},
             [('scripts/aX.sh', 1, 'Complior-mob')], config={'exclude': ['scripts/a[*].sh']}),
        case('literal-include-star', {'ext*/a.sh': 'Complior-back\n', 'extras/a.sh': 'Complior-mob\n'},
             [('ext*/a.sh', 1, 'Complior-back')], config={'include': ['ext*'], 'exclude': []}),
        case('literal-exclude-question', {'scripts/a?.sh': 'Complior-back\n', 'scripts/ab.sh': 'Complior-mob\n'},
             [('scripts/ab.sh', 1, 'Complior-mob')], config={'exclude': ['scripts/a?.sh']}),
        case('literal-include-question', {'ext?/a.sh': 'Complior-back\n', 'extb/a.sh': 'Complior-mob\n'},
             [('ext?/a.sh', 1, 'Complior-back')], config={'include': ['ext?/a.sh'], 'exclude': []}),
        case('literal-exclude-star', {'scripts/a*.sh': 'Complior-back\n', 'scripts/ab.sh': 'Complior-mob\n'},
             [('scripts/ab.sh', 1, 'Complior-mob')], config={'exclude': ['scripts/a*.sh']}),
        case('literal-include-bracket', {'ext[b]/a.sh': 'Complior-back\n', 'extb/a.sh': 'Complior-mob\n'},
             [('ext[b]/a.sh', 1, 'Complior-back')], config={'include': ['ext[b]/a.sh'], 'exclude': []}),
        case('literal-exclude-bracket', {'scripts/a[b].sh': 'Complior-back\n', 'scripts/ab.sh': 'Complior-mob\n'},
             [('scripts/ab.sh', 1, 'Complior-mob')], config={'exclude': ['scripts/a[b].sh']}),
        case('literal-include-backslash', {'ext\\?/a.sh': 'Complior-back\n', 'ext?/a.sh': 'Complior-mob\n'},
             [('ext\\?/a.sh', 1, 'Complior-back')], config={'include': ['ext\\?/a.sh'], 'exclude': []}),
        case('literal-exclude-backslash', {'scripts/a\\?.sh': 'Complior-back\n', 'scripts/a?.sh': 'Complior-mob\n'},
             [('scripts/a?.sh', 1, 'Complior-mob')], config={'exclude': ['scripts/a\\?.sh']}),
        case('changed-baseline', {'scripts/a.sh': 'Complior-back\n'}, [('scripts/a.sh', 1, 'Complior-back')],
             config={'baseline': {'lines': 7, 'files': 3, 'commit': 'abcdef123'}}),
        case('dirty-worktree', {'scripts/a.sh': 'clean\n'}, [('scripts/a.sh', 1, 'Complior-back')],
             dirty={'scripts/a.sh': 'Complior-back\n'}),
        case('above-baseline', {'scripts/a.sh': 'Complior-back\n' * 90},
             [('scripts/a.sh', n, 'Complior-back') for n in range(1, 91)]),
        case('above-file-baseline', {f'scripts/a{n:02}.sh': 'Complior-back\n' for n in range(21)},
             [(f'scripts/a{n:02}.sh', 1, 'Complior-back') for n in range(21)]),
        case('empty-directories', {'notes.txt': 'Complior-back\n'}, []),
        case('git-failure', {'scripts/a.sh': 'Complior-back\n'}, [], error='git'),
        case('invalid-config', {'scripts/a.sh': 'Complior-back\n'}, [], error='config-json'),
        case('unreadable-config', {'scripts/a.sh': 'Complior-back\n'}, [], error='config-read'),
    ]


CASES = cases()
META = ('default-config', 'ci-wiring', 'ci-measurement', 'ci-generator')
NAMES = [row['name'] for row in CASES] + list(META)


def snapshot(root):
    # Independent witness: bytes and index are captured before the subject.
    return ({p.relative_to(root).as_posix(): p.read_bytes()
             for p in root.rglob('*') if p.is_file() and '.git' not in p.relative_to(root).parts},
            required(['git', 'ls-files', '--stage', '-z'], root).stdout,
            required(['git', 'rev-parse', 'HEAD'], root).stdout)


def world_test(carrier, row, scratch):
    with tempfile.TemporaryDirectory(prefix='world-', dir=scratch) as tmp:
        root = Path(tmp)
        required(['git', 'init', '-q', '--template=', '-b', 'main'], root)
        for file in (build.SCRIPT, build.CONFIG):
            if not (carrier / file).is_file():
                return False, 'SUBJECT_ABSENT: ' + file
            put(root, file, (carrier / file).read_bytes())
        config = copy.deepcopy(DEFAULT)
        config.update(copy.deepcopy(row.get('config', {})))
        put(root, build.CONFIG, json.dumps(config))
        for file, data in row['files'].items():
            put(root, file, data)
        required(['git', 'add', '--all'], root)
        required(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                  'commit', '-qm', '227 real tracked inputs'], root)
        for file, data in {**row.get('untracked', {}), **row.get('dirty', {})}.items():
            put(root, file, data)
        subject_env = ENV.copy()
        if row.get('error') == 'git':
            # Only the subject sees the failing tool; setup and witness use real Git.
            tools = root / 'failing-tools'
            put(root, 'failing-tools/git', '#!/bin/sh\nprintf "git failure\\n" >&2\nexit 128\n')
            (tools / 'git').chmod(0o755)
            subject_env['PATH'] = str(tools) + os.pathsep + ENV['PATH']
        elif row.get('error') == 'config-json':
            put(root, build.CONFIG, '{"pattern":')
        elif row.get('error') == 'config-read':
            # A directory is unreadable as a config even for privileged runners.
            (root / build.CONFIG).unlink()
            (root / build.CONFIG).mkdir()
        records = copy.deepcopy(row['records'])
        expected = {'lines': len(records), 'files': len({r['path'] for r in records}),
                    'matches': records, 'baseline': copy.deepcopy(config['baseline'])}
        before = snapshot(root)
        # The public command is exactly the registered bash command, no model overlay.
        result = run(['bash', build.SCRIPT], root, subject_env)
        failures = []
        if row.get('error'):
            if result.returncode != 2:
                failures.append('MEASUREMENT_ERROR_RC rc=' + str(result.returncode))
            if not any(line.startswith(b'NOT_IMPLEMENTED:') for line in result.stderr.splitlines()):
                failures.append('MEASUREMENT_ERROR_DIAGNOSIS')
            if result.stdout != b'':
                failures.append('MEASUREMENT_ERROR_REPORT ' + repr(result.stdout))
        else:
            if result.returncode != 0:
                failures.append('REPORT_BLOCKS_RESIDUE rc=' + str(result.returncode))
            try:
                actual = json.loads(result.stdout)
            except (ValueError, UnicodeError):
                actual = None
            # Standard JSON parse then full structural comparison; not substring markers.
            if json.dumps(actual, sort_keys=True) != json.dumps(expected, sort_keys=True):
                failures.append('REPORT_CONTENT')
            if result.stderr != b'':
                failures.append('STDERR ' + repr(result.stderr))
        if snapshot(root) != before:
            failures.append('SUBJECT_MUTATED_INPUT')
        return not failures, ','.join(failures)


def read_rows(path):
    if not path.is_file():
        return []
    return list(csv.reader(io.StringIO(path.read_text()), delimiter='\t'))


def metadata(carrier, name, scratch, production=False):
    if name == 'default-config':
        try:
            actual = json.loads((carrier / build.CONFIG).read_bytes())
        except (OSError, ValueError):
            return False, 'CONFIG_ABSENT_OR_INVALID'
        return actual == DEFAULT, 'DEFAULT_CONFIG_DRIFT'
    steps = [r for r in read_rows(carrier / build.STEPS) if len(r) > 1 and r[1] == build.KEY]
    if name == 'ci-wiring':
        valid = len(steps) == 1 and len(steps[0]) == 4 and steps[0][0] == 'step' and steps[0][3] == build.COMMAND
        return valid, 'CI_REPORT_STEP_ABSENT_OR_NONCANON'
    if name == 'ci-measurement':
        rows = [r for r in read_rows(carrier / build.ZAMERY) if r and r[0] == build.KEY]
        valid = len(rows) == 1 and len(rows[0]) == 4 and len(steps) == 1 and rows[0][1] == steps[0][2]
        return valid, 'CI_MEASUREMENT_ABSENT_OR_WEIGHT_DRIFT'
    if production:
        result = run(['bash', 'scripts/gen_ci_steps.sh', '--check'], carrier)
    else:
        with tempfile.TemporaryDirectory(prefix='ci-', dir=scratch) as tmp:
            root = Path(tmp)
            for file in build.FILES:
                put(root, file, (carrier / file).read_bytes())
            put(root, 'scripts/gen_ci_steps.sh', (ROOT / 'scripts/gen_ci_steps.sh').read_bytes())
            put(root, 'package.json', '{"scripts": {}}\n')
            put(root, '.github/workflows/ci.yml',
                '# BEGIN GENERATED CI JOBS (083)\n# END GENERATED CI JOBS (083)\n'
                '# BEGIN GENERATED CI SHARDS (083)\n# END GENERATED CI SHARDS (083)\n')
            required(['bash', 'scripts/gen_ci_steps.sh', '--write'], root)
            result = run(['bash', 'scripts/gen_ci_steps.sh', '--check'], root)
    if result.returncode == 2:
        raise Unavailable('CI_GENERATOR_UNAVAILABLE ' + repr(result.stderr))
    return result.returncode == 0, 'GEN_CI_STEPS_CHECK ' + repr(result.stderr)


def suite(carrier, scratch, names=None, production=False):
    selected = NAMES if names is None else names
    results = {}
    for name in selected:
        row = next((r for r in CASES if r['name'] == name), None)
        result = world_test(carrier, row, scratch) if row else metadata(carrier, name, scratch, production)
        results[name] = result[0]
        print(name, 'GREEN' if result[0] else 'RED ' + result[1])
    return results


def carriers():
    _, canonical = build.expected()
    recorded = json.loads((HERE / 'source.json').read_bytes())
    if recorded != canonical:
        raise Unavailable('SOURCE_MANIFEST_DRIFT')
    for file, sha in recorded['files'].items():
        if build.digest((HERE / file).read_bytes()) != sha:
            raise Unavailable('CARRIER_HASH: ' + file)
    if len(set(NAMES)) != len(NAMES) or not NAMES or not recorded['links']:
        raise Unavailable('EMPTY_OR_DUPLICATE_CATALOG')
    for row in recorded['links']:
        if not row['cells'] or not set(row['cells']) <= set(NAMES):
            raise Unavailable('UNKNOWN_CELL: ' + repr(row))
    carrier_syntax(recorded)
    return recorded


def carrier_syntax(manifest):
    for file in manifest['files']:
        path = HERE / file
        if file.endswith('.sh'):
            required(['bash', '-n', str(path)], ROOT)
            text = path.read_text()
            embedded = text.split("<<'PY'\n", 1)[1].rsplit('\nPY', 1)[0]
            compile(embedded, str(path) + ':python', 'exec')


def syntax(manifest):
    for path in HERE.glob('*.py'):
        compile(path.read_bytes(), str(path), 'exec')
    for path in (HERE / 'red_zashivki_otchet_227.sh', HERE / 'model' / build.SCRIPT):
        required(['bash', 'scripts/validate_std.sh', 'bash', str(path)], ROOT)
    required(['bash', 'scripts/validate_std.sh', 'json', str(HERE / 'config.schema.json'),
              str(HERE / 'model' / build.CONFIG)], ROOT)
    print('SINTAKSIS_OK')


def main():
    parser = argparse.ArgumentParser()
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument('--repo', type=Path)
    for name in ('model', 'stabs', 'sintaksis', 'catalog'):
        mode.add_argument('--' + name, action='store_true')
    args = parser.parse_args()
    for program in ('git', 'bash', 'python3', 'jq'):
        if not shutil.which(program):
            raise Unavailable('MISSING_TOOL: ' + program)
    # All allocated worlds belong to the verifier copy and are removed on exit.
    parent = ROOT / 'tmp' / 'scratch-arch227'
    parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='probe-', dir=parent) as tmp:
        scratch = Path(tmp)
        ENV['TMPDIR'] = str(scratch)
        manifest = carriers()
        if args.catalog:
            print('\n'.join(NAMES))
            print(json.dumps(manifest['links'], ensure_ascii=False, indent=2))
            print('KLETKI', len(NAMES), 'STABY', len(build.MUTATIONS), 'EKVIVALENTY', len(build.EQUIVALENTS),
                  'SVJAZI', sum(len(r['cells']) for r in manifest['links']))
            return 0
        if args.sintaksis:
            syntax(manifest)
            return 0
        if args.stabs:
            control = suite(HERE / 'model', scratch)
            if not all(control.values()):
                raise Unavailable('HONEST_CONTROL_RED')
            alive = 0
            for row in manifest['links']:
                outcomes = suite(HERE / row['carrier'], scratch, row['cells'])
                expected = row['polarity'] == 'green'
                for cell, actual in outcomes.items():
                    caught = actual == expected
                    print(row['carrier'], cell, 'CAUGHT' if caught else 'ZHIV')
                    alive += not caught
            print('STABY', len(build.MUTATIONS), 'EKVIVALENTY', len(build.EQUIVALENTS), 'ZHIVYH', alive)
            return int(alive != 0)
        carrier = args.repo.resolve() if args.repo else HERE / 'model'
        # Missing production is a named red requirement, not an unavailable verifier.
        if not (carrier / build.SCRIPT).is_file():
            print('SUBJECT_ABSENT:', build.SCRIPT)
            return 1
        results = suite(carrier, scratch, production=args.repo is not None)
        red = sum(not value for value in results.values())
        print('KLETKI', len(results), 'KRASNYH', red)
        return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (Unavailable, OSError, ValueError, KeyError, SyntaxError) as error:
        print('NOT_IMPLEMENTED: VERIFIER_UNAVAILABLE:', error, file=sys.stderr)
        sys.exit(2)
