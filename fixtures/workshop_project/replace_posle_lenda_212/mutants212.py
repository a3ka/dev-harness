#!/usr/bin/env python3
"""Adv212 v1–v3: disposable production mutants.

Full --repo runs cover the reported mutants; scoped neighbours and honest
controls exercise each predicate without extending the binding matrix.
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
            ('st44-sverka-peeled-kommitov',
             ('r23-peremint-tot-zhe-kommit', 'r26-peremint-vtoroj-versii')),
            ('st45-otkat-udalen', ('r24-otkaz-hooka-otkat',)),
            ('st46-prjamaja-zapis-s-uborkoj',
             ('r25-atomarnaja-zamena', 'r27-mv-na-toj-zhe-fs', 'r28-tmpdir-cwd-drugaja-fs')),
            ('st47-sverka-tolko-v1', ('r26-peremint-vtoroj-versii',)),
            ('st48-mktemp-drugaja-fs', ('r27-mv-na-toj-zhe-fs', 'r28-tmpdir-cwd-drugaja-fs')),
            ('st49-mktemp-tmpdir', ('r28-tmpdir-cwd-drugaja-fs',)),
            ('st50-mktemp-cwd-rel', ('r28-tmpdir-cwd-drugaja-fs',)),
        )
        # У модели TMP в корне toy (та же ФС), у production — в registry.
        # Мутация Б-2 меняет только настоящий production mktemp.
        temp_anchor = 'mktemp "$ROOT/$_REGISTRY_PATH/.replace-line-$NNN.XXXXXX"'
        for name, case in pairs:
            anchor, replacement = probe.STAB_MUTACII[name]
            if name == 'st48-mktemp-drugaja-fs':
                anchor = temp_anchor
            subject.write_text(probe._mut(original, anchor, replacement), encoding='utf-8')
            argv = ['bash', HERE / 'red_replace_posle_lenda_212.sh', '--repo', clone]
            result = probe.run(argv, timeout=300)
            print('COMMAND bash %s --repo %s MUTANT=%s' % (argv[1], clone, name), flush=True)
            print(result.stdout.decode('utf-8'), end='', flush=True)
            print('RC %s=%d' % (name, result.returncode), flush=True)
            assert result.returncode == 1, (name, result.stderr)
            red_cases = {line.split(b':', 1)[0].split()[1].decode()
                         for line in result.stdout.splitlines()
                         if line.startswith(b'KRASNAJA-KLETKA ')}
            assert red_cases == set(case), (name, red_cases, case)
            summary = 'SUBJEKT 212: KLETKI %d KRASNYH %d\n' % (
                len(cases) + len(probe.ARGV_KEJSY), len(case))
            assert result.stdout.endswith(summary.encode()), name

        # Broader than the examples: absent equality; partial rollbacks; direct
        # write followed by mv changes inode but still corrupts the held file.
        neighbours = (
            ('peeled-neighbour', pairs[0][1][0], probe.STAB_MUTACII[pairs[0][0]][0],
             'if false; then', 'переминт'),
            ('rollback-index-only', pairs[1][1][0], probe.STAB_MUTACII[pairs[1][0]][0],
             '  git -C "$ROOT" reset -q HEAD -- "$_REG_FILE"', 'манифест worktree'),
            ('rollback-worktree-only', pairs[1][1][0], probe.STAB_MUTACII[pairs[1][0]][0],
             '  git -C "$ROOT" restore --worktree -- "$_REG_FILE"', 'добавил грязь'),
            ('inode-same-old-bytes', pairs[2][1][0], probe.STAB_MUTACII[pairs[2][0]][0],
             'rm -f "$TMP"; git -C "$ROOT" checkout HEAD -- "$_REG_FILE"', 'вместо mv'),
            ('old-file-write-then-mv', pairs[2][1][0], probe.STAB_MUTACII[pairs[2][0]][0],
             'cat "$TMP" > "$ROOT/$_REG_FILE"; mv "$TMP" "$ROOT/$_REG_FILE"',
             'открытый старый файл'),
            ('tag-only-vmax-ge2', pairs[0][1][0], probe.STAB_MUTACII[pairs[3][0]][0],
             'if [ "$vmax" -ge 2 ] && [ "$NEW_SHA" != "$sha_origin" ]; then', 'переминт'),
            ('temp-shm-equivalent-option', pairs[4][1][0], temp_anchor,
             'mktemp --tmpdir=/dev/shm', 'между файловыми системами'),
            ('mv-not-observed', pairs[4][1][0], probe.STAB_MUTACII[pairs[2][0]][0],
             'cat "$TMP" > "$ROOT/$_REG_FILE"; rm -f "$TMP"', 'mv реестра не наблюдался'),
            ('temp-env-no-template', 'r28-tmpdir-cwd-drugaja-fs', temp_anchor,
             'mktemp', 'между файловыми системами'),
            ('mv-not-observed-r28', 'r28-tmpdir-cwd-drugaja-fs', probe.STAB_MUTACII[pairs[2][0]][0],
             'cat "$TMP" > "$ROOT/$_REG_FILE"; rm -f "$TMP"', 'mv реестра не наблюдался'),
        )
        for name, case, anchor, replacement, reason in neighbours:
            subject.write_text(probe._mut(original, anchor, replacement), encoding='utf-8')
            problems = probe.prognot_kletku(case, cases, subject)
            print('NEIGHBOUR %s RED=%r' % (name, problems), flush=True)
            assert any(reason in p for p in problems), name

        equivalents = (
            ('tag-equality-reversed', pairs[0][1][0], probe.STAB_MUTACII[pairs[0][0]][0],
             'if [ "$sha_origin" != "$NEW_SHA" ]; then'),
            ('rollback-restore', pairs[1][1][0], probe.STAB_MUTACII[pairs[1][0]][0],
             '  git -C "$ROOT" restore --source=HEAD --staged --worktree -- "$_REG_FILE"'),
            ('atomic-mv-force', pairs[2][1][0], probe.STAB_MUTACII[pairs[2][0]][0],
             'mv -f "$TMP" "$ROOT/$_REG_FILE"'),
            ('tag-v2-equality-reversed', pairs[3][1][0], probe.STAB_MUTACII[pairs[3][0]][0],
             'if [ "$sha_origin" != "$NEW_SHA" ]; then'),
            ('atomic-mv-force-r27', pairs[4][1][0], probe.STAB_MUTACII[pairs[2][0]][0],
             'mv -f "$TMP" "$ROOT/$_REG_FILE"'),
            ('atomic-mv-target-r27', pairs[4][1][0], probe.STAB_MUTACII[pairs[2][0]][0],
             'mv -T -- "$TMP" "$ROOT/$_REG_FILE"'),
            ('temp-in-root-same-fs', pairs[4][1][0], temp_anchor,
             'mktemp "$ROOT/.replace-line-$NNN.XXXXXX"'),
            ('mv-dotdot-r27', 'r27-mv-na-toj-zhe-fs', probe.STAB_MUTACII[pairs[2][0]][0],
             'mv "$TMP" "$ROOT/registry/../registry/contracts.tsv"'),
            ('mv-dotdot-r28', 'r28-tmpdir-cwd-drugaja-fs', probe.STAB_MUTACII[pairs[2][0]][0],
             'mv "$TMP" "$ROOT/registry/../registry/contracts.tsv"'),
            ('temp-in-root-foreign-env', 'r28-tmpdir-cwd-drugaja-fs', temp_anchor,
             'mktemp "$ROOT/.replace-line-$NNN.XXXXXX"'),
        )
        for name, case, anchor, replacement in equivalents:
            subject.write_text(probe._mut(original, anchor, replacement), encoding='utf-8')
            problems = probe.prognot_kletku(case, cases, subject)
            print('EQUIVALENT %s RED=%r' % (name, problems), flush=True)
            assert not problems, (name, problems)
        subject.write_text(probe._mut(original, temp_anchor, 'mktemp -p /tmp'), encoding='utf-8')
        problems = probe.prognot_kletku(pairs[4][1][0], cases, subject)
        same_fs = Path('/tmp').stat().st_dev == scratch.stat().st_dev
        print('TMP-IN-/tmp SAME_FS=%s RED=%r' % (same_fs, problems), flush=True)
        if same_fs:
            assert not problems, problems
        else:
            assert any('между файловыми системами' in p for p in problems), problems
        return 0
    finally:
        shutil.rmtree(scratch)


if __name__ == '__main__':
    raise SystemExit(main())
