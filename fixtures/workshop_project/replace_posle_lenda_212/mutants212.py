#!/usr/bin/env python3
"""Adv212 Б-1…Б-3: production mutants in one disposable independent clone.

Full --repo runs cover the three reported mutants; scoped neighbour and honest
controls exercise each new predicate without extending the binding matrix.
"""
import importlib.util
import sys
from pathlib import Path
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('probe212', HERE / 'probe212.py')
sys.dont_write_bytecode = True
probe = importlib.util.module_from_spec(spec)
spec.loader.exec_module(probe)


def command(argv):
    result = subprocess.run([str(x) for x in argv], cwd=ROOT,
                            env=probe.GIT_ENV, capture_output=True, timeout=300)
    if result.returncode:
        raise RuntimeError('%r: rc=%s %r' % (argv, result.returncode, result.stderr))
    return result.stdout


def main():
    scratch = Path(tempfile.mkdtemp(prefix='mutants212-'))
    try:
        clone = scratch / 'repo'
        command(['bash', ROOT / 'scripts/gitw', 'clone', '--quiet',
                 '--no-hardlinks', '--no-checkout', ROOT, clone])
        sha = command(['git', 'rev-parse', 'HEAD']).decode().strip()
        command(['git', '-C', clone, 'checkout', '--quiet', '--detach', sha])
        assert (clone / '.git').is_dir(), 'clone must own its .git'
        subject = clone / 'scripts/replace_line.sh'
        original = subject.read_bytes().decode('utf-8')
        cases = probe.kejsy()
        pairs = (
            ('st44-sverka-peeled-kommitov', 'r23-peremint-tot-zhe-kommit'),
            ('st45-otkat-udalen', 'r24-otkaz-hooka-otkat'),
            ('st46-prjamaja-zapis-s-uborkoj', 'r25-atomarnaja-zamena'),
        )
        for name, case in pairs:
            anchor, replacement = probe.STAB_MUTACII[name]
            subject.write_text(probe._mut(original, anchor, replacement), encoding='utf-8')
            argv = ['bash', HERE / 'red_replace_posle_lenda_212.sh', '--repo', clone]
            result = probe.run(argv, timeout=300)
            print('COMMAND bash %s --repo %s MUTANT=%s' % (argv[1], clone, name), flush=True)
            print(result.stdout.decode('utf-8'), end='', flush=True)
            print('RC %s=%d' % (name, result.returncode), flush=True)
            assert result.returncode == 1, (name, result.stderr)
            assert b'KRASNAJA-KLETKA ' + case.encode() + b':' in result.stdout, name
            assert result.stdout.endswith(b'SUBJEKT 212: KLETKI 31 KRASNYH 1\n'), name

        # Broader than the examples: absent equality; partial rollbacks; direct
        # write followed by mv changes inode but still corrupts the held file.
        neighbours = (
            ('peeled-neighbour', pairs[0][1], probe.STAB_MUTACII[pairs[0][0]][0],
             'if false; then', 'переминт'),
            ('rollback-index-only', pairs[1][1], probe.STAB_MUTACII[pairs[1][0]][0],
             '  git -C "$ROOT" reset -q HEAD -- "$_REG_FILE"', 'манифест worktree'),
            ('rollback-worktree-only', pairs[1][1], probe.STAB_MUTACII[pairs[1][0]][0],
             '  git -C "$ROOT" restore --worktree -- "$_REG_FILE"', 'добавил грязь'),
            ('inode-same-old-bytes', pairs[2][1], probe.STAB_MUTACII[pairs[2][0]][0],
             'rm -f "$TMP"; git -C "$ROOT" checkout HEAD -- "$_REG_FILE"', 'вместо mv'),
            ('old-file-write-then-mv', pairs[2][1], probe.STAB_MUTACII[pairs[2][0]][0],
             'cat "$TMP" > "$ROOT/$_REG_FILE"; mv "$TMP" "$ROOT/$_REG_FILE"',
             'открытый старый файл'),
        )
        for name, case, anchor, replacement, reason in neighbours:
            subject.write_text(probe._mut(original, anchor, replacement), encoding='utf-8')
            problems = probe.prognot_kletku(case, cases, subject)
            print('NEIGHBOUR %s RED=%r' % (name, problems), flush=True)
            assert any(reason in p for p in problems), name

        equivalents = (
            ('tag-equality-reversed', pairs[0][1], probe.STAB_MUTACII[pairs[0][0]][0],
             'if [ "$sha_origin" != "$NEW_SHA" ]; then'),
            ('rollback-restore', pairs[1][1], probe.STAB_MUTACII[pairs[1][0]][0],
             '  git -C "$ROOT" restore --source=HEAD --staged --worktree -- "$_REG_FILE"'),
            ('atomic-mv-force', pairs[2][1], probe.STAB_MUTACII[pairs[2][0]][0],
             'mv -f "$TMP" "$ROOT/$_REG_FILE"'),
        )
        for name, case, anchor, replacement in equivalents:
            subject.write_text(probe._mut(original, anchor, replacement), encoding='utf-8')
            problems = probe.prognot_kletku(case, cases, subject)
            print('EQUIVALENT %s RED=%r' % (name, problems), flush=True)
            assert not problems, (name, problems)
        return 0
    finally:
        shutil.rmtree(scratch)


if __name__ == '__main__':
    raise SystemExit(main())
