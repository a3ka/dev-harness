#!/usr/bin/env python3
"""Exercise real pre-push entry with a file:// origin; no network or live pushes."""
from pathlib import Path
import subprocess
import sys
import tempfile
from probe import ROOT, HERE
from merge_policy import registry_row

SOURCE = ROOT / '.githooks/pre-push'
POLICY = HERE / 'merge_policy.py'
ZERO = '0' * 40


def git(cwd, *args, input=None):
    return subprocess.run(['git', '-c', 'user.name=architect', '-c', 'user.email=architect@dev-harness.local',
                           '-c', 'commit.gpgsign=false', *args], cwd=cwd, input=input, text=True,
                          capture_output=True, timeout=30)


def must(p):
    assert p.returncode == 0, (p.args, p.stdout, p.stderr)
    return p.stdout.strip()


def put(root, path, text):
    f = root / path
    f.parent.mkdir(parents=True, exist_ok=True)
    f.write_text(text)
    must(git(root, 'add', path))
    must(git(root, 'commit', '-qm', 'change ' + path))


def scenario(hook, shape):
    with tempfile.TemporaryDirectory(prefix='merge-167-') as temp:
        root = Path(temp)
        repo, remote = root / 'repo', root / 'remote.git'
        must(git(root, 'init', '--bare', '-q', str(remote)))
        must(git(root, 'init', '-q', '-b', 'main', str(repo)))
        must(git(repo, 'remote', 'add', 'origin', 'file://' + str(remote)))
        (repo / 'scripts').mkdir()
        # Import existing charter ring unchanged.  The hook remains the actual entry.
        for dep in ('check_charter.sh', 'next_id.sh', 'lib_registry.sh', 'lib_incr.sh'):
            (repo / 'scripts' / dep).symlink_to(ROOT / 'scripts' / dep)
        put(repo, 'registry/contracts.tsv', registry_row('001', 'a'))
        initial = must(git(repo, 'rev-parse', 'HEAD'))
        must(git(repo, 'tag', 'ustav/1'))
        must(git(repo, 'push', '-q', 'origin', 'main'))
        must(git(repo, 'branch', 'wip/167/architect'))
        if shape in ('separate', 'partial'):
            put(repo, 'main-only.txt', 'main\n')
        elif shape in ('registry', 'registry_drop'):
            put(repo, 'registry/contracts.tsv', registry_row('001', 'a') + registry_row('002', 'b'))
        else:
            put(repo, 'shared.txt', 'main\n')
        main = must(git(repo, 'rev-parse', 'HEAD'))
        must(git(repo, 'push', '-q', 'origin', 'main'))
        must(git(repo, 'switch', '-q', 'wip/167/architect'))
        if shape in ('separate', 'partial'):
            put(repo, 'branch-only.txt', 'branch\n')
        elif shape in ('registry', 'registry_drop'):
            put(repo, 'registry/contracts.tsv', registry_row('001', 'a') + registry_row('003', 'c'))
        else:
            put(repo, 'shared.txt', 'branch\n')
        merge = git(repo, 'merge', '--no-ff', '-m', 'sync main into PR', '-s', 'ours', 'main') if shape == 'partial' else git(repo, 'merge', '--no-ff', '-m', 'sync main into PR', 'main')
        if shape in ('registry', 'registry_drop'):
            assert merge.returncode != 0, ('REGISTRY_NOT_CONFLICTING', merge.stdout)
            merged = registry_row('001', 'a') + registry_row('002', 'b')
            if shape == 'registry':
                merged += registry_row('003', 'c')
            (repo / 'registry/contracts.tsv').write_text(merged)
            must(git(repo, 'add', 'registry/contracts.tsv'))
            must(git(repo, 'commit', '-qm', 'resolve registry rows'))
        elif shape == 'overlap':
            assert merge.returncode != 0, ('OVERLAP_NOT_CONFLICTING', merge.stdout)
            (repo / 'shared.txt').write_text('main and branch\n')
            must(git(repo, 'add', 'shared.txt'))
            must(git(repo, 'commit', '-qm', 'merge conflicted subject'))
        else:
            must(merge)
        tip = must(git(repo, 'rev-parse', 'HEAD'))
        if shape == 'registry':
            expected = (repo / 'registry/contracts.tsv').read_text()
            assert expected == registry_row('001', 'a') + registry_row('002', 'b') + registry_row('003', 'c')
        if hook in ('--model', '--allow_all'):
            target = root / 'model-hook'
            source = SOURCE.read_text()
            old = '  p1="${parents[1]}"\n'
            assert source.count(old) == 1, 'HOOK_ANCHOR_MISSING'
            # The model reuses every other pre-push check and substitutes ONLY
            # the narrowly scoped merge exception at the real hook's public seam.
            source = source.replace(old, old + ('''  if [ "$ref" = 'refs/heads/wip/167/architect' ]; then return 1; fi
''' if hook == '--allow_all' else '''  if [ "$ref" = 'refs/heads/wip/167/architect' ] &&
     python3 "''' + str(POLICY) + '''" "$ROOT" "$c" "$LIVE_MAIN"; then
    return 1
  fi
'''))
            target.write_text(source)
        else:
            target = SOURCE
        data = f'refs/heads/wip/167/architect {tip} refs/heads/wip/167/architect {ZERO}\n'
        result = subprocess.run(['bash', str(target), 'origin', 'file://' + str(remote)],
                                cwd=repo, input=data, text=True, capture_output=True, timeout=30)
        allowed = shape in ('separate', 'registry')
        if result.returncode != (0 if allowed else 1):
            return f'rc={result.returncode} expected={0 if allowed else 1} stderr={result.stderr.strip()}'
        if not allowed and 'merge main в ветку запрещён' not in result.stderr:
            return f'wrong denial: {result.stderr.strip()}'
        return None


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else '--repo'
    if mode not in ('--model', '--repo', '--stabs'):
        return 2
    errors = []
    for shape in ('separate', 'registry', 'overlap', 'registry_drop', 'partial'):
        error = scenario('--model' if mode in ('--model', '--stabs') else '--repo', shape)
        print(f'MERGE {shape} {"KRASNO " + error if error else "ok"}')
        if error:
            errors.append(shape)
    if mode == '--stabs':
        # The actual pre-push is the restrictive mutant: each allowed case
        # distinguishes it from the model, while overlap remains negative.
        for shape in ('separate', 'registry'):
            error = scenario('--repo', shape)
            if error:
                print(f'STAB forbid_all {shape} caught: {error}')
            else:
                errors.append('forbid_all:' + shape)
                print(f'STAB_ZHIV forbid_all {shape}')
        for shape in ('overlap', 'registry_drop', 'partial'):
            error = scenario('--allow_all', shape)
            if error:
                print(f'STAB allow_all {shape} caught: {error}')
            else:
                errors.append('allow_all:' + shape)
                print(f'STAB_ZHIV allow_all {shape}')
    return int(bool(errors))


if __name__ == '__main__':
    sys.exit(main())
