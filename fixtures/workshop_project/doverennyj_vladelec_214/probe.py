#!/usr/bin/env python3
"""214 public --sudit seam. Real Git worlds; literal rc/byte expectations."""
import argparse
import hashlib
import importlib.util
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
spec = importlib.util.spec_from_file_location('world211', HERE.parent / 'd52_bootstrap_sudej_211/probe211.py')
p = importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)

CASES = ('arb1', 'arb2', 'arb3', 'arb4', 'arb5', 'arb6',
         'isolated-risk', 'isolated-safe', 'other-origin-risk', 'same-origin-risk',
         'dirty-legacy-risk', 'dirty-legacy-safe', 'dirty-legacy-untracked',
         'unknown-legacy', 'committed-legacy-safe', 'dirty-profile',
         'profile-deleted', 'ambient-profile', 'critic-profile',
         'dirty-author-legacy', 'forged-latest-tag', 'forged-pin',
         'pinned-head', 'missing-source', 'risk-after-adversary', 'adversary-risk',
         'legacy-symlink', 'product-safe', 'product-risk', 'product-dirty-profile',
         'product-station-profile')


def put(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding='utf-8')


def checked(result):
    if result.returncode:
        raise RuntimeError('WORLD_SETUP ' + repr(result.stderr))
    return p.plumbing(result)


def legacy(w, wt, obj, klass, commit=True):
    put(w.repo / 'registry/risk-legacy.tsv', p.legacy_stroka(wt, obj, '211') + '\t' + klass + '\tоснование\tподтвердил\n')
    if commit:
        checked(w.git(['add', 'registry/risk-legacy.tsv']))
        checked(w.git(['commit', '-q', '-m', 'trusted legacy']))


def race_env(w, old, new):
    bindir = w.root / 'bin'
    bindir.mkdir()
    # Forward every Git call to the REAL binary. Only schedule a real ref move
    # after the pinned HEAD has been read, before the clone starts.
    wrapper = bindir / 'git'
    wrapper.write_text('''#!/usr/bin/env python3
import os, subprocess, sys
from pathlib import Path
args = sys.argv[1:]
r = subprocess.run(['/usr/bin/git', *args], capture_output=True)
sys.stdout.buffer.write(r.stdout)
sys.stderr.buffer.write(r.stderr)
if args[:2] == ['-C', os.environ['RACE_REPO']] and any(a == 'HEAD' or a.startswith(('HEAD^', 'HEAD:')) for a in args[2:]) and not Path(os.environ['RACE_MARK']).exists():
    subprocess.run(['/usr/bin/git', '-C', os.environ['RACE_REPO'], 'update-ref', 'HEAD', os.environ['RACE_NEW']], check=True)
    Path(os.environ['RACE_MARK']).touch()
sys.exit(r.returncode)
''')
    wrapper.chmod(0o755)
    checked(w.git(['update-ref', 'HEAD', old]))
    env = dict(p.GIT_ENV, PATH=str(bindir) + os.pathsep + os.environ['PATH'], RACE_REPO=str(w.repo), RACE_NEW=new, RACE_MARK=str(w.root / 'race-fired'))
    return env


def product_case(name, door):
    with tempfile.TemporaryDirectory(prefix='product214-') as tmp:
        w = p.Mir(tmp)
        old_wt, old_br, _, _ = p.mir_bootstrap(w)
        p.avtor_sdal(w, '211', old_wt, old_br)
        worker = w.ledg()[0]
        product_root = w.root / 'product-world'
        product_root.mkdir()
        product = p.Mir(product_root)
        wt, br, f, obj = p.mir_bootstrap(product, '211', 'рисковый' if name == 'product-risk' else 'обычный')
        remote = 'ssh://git@github.com/test/product.git'
        checked(p.wt_git(wt, 'remote', 'set-url', 'origin', remote))
        checked(p.wt_git(wt, 'tag', '-a', 'frozen/contracts/211/1', '-m', 'product frozen', f))
        tag = checked(p.wt_git(wt, 'rev-parse', 'frozen/contracts/211/1'))
        obj = p.kommit(wt, 'delivery.txt', 'payload\n', role='architect')
        if name == 'product-dirty-profile':
            p.profil_proekta(wt, 'absent')
            checked(p.wt_git(wt, 'add', '-A'))
            checked(p.wt_git(wt, 'commit', '-q', '-m', 'author profile after frozen', role='architect'))
            obj = checked(p.wt_git(wt, 'rev-parse', 'HEAD'))
        proof = dict(version=1, repoId=p.REPO_ID, subjectId='211', holder='Impl211',
                     author='architect',
                     workerStart=hashlib.sha256(json.dumps(worker, sort_keys=True, separators=(',', ':'), ensure_ascii=False).encode()).hexdigest(),
                     canonicalRemote=remote, worktree=wt, branch=br, object=obj,
                     frozenTag='frozen/contracts/211/1', frozenObject=tag, frozenCommit=f)
        put(w.repo / 'registry/dostavki/211.json', json.dumps(proof, ensure_ascii=False, indent=2) + '\n')
        put(w.repo / 'registry/contracts.tsv', '211 → ' + tag + '\n')
        checked(w.git(['add', '-A']))
        checked(p.wt_git(w.repo, 'commit', '-q', '-m', 'station receipt', role='orchestrator'))
        receipt = checked(w.git(['rev-parse', 'HEAD']))
        checked(w.git(['update-ref', 'refs/remotes/origin/main', receipt]))
        with w.ledger.open('a') as stream:
            stream.write(json.dumps(dict(t='PEREDACHA', repoId=p.REPO_ID, subjectId='211', receipt=receipt, proof=proof, at='2026-11-23T10:00:00Z')) + '\n')
        if name == 'product-station-profile':
            p.profil_proekta(w.repo)
            file = w.repo / 'harness.project.json'
            profile = json.loads(file.read_text())
            profile['workflowPaths']['registry'] = 'other-registry'
            file.write_text(json.dumps(profile))
        expected = (1, b'', p.otkaz_adv_do_rev('211').encode()) if name == 'product-risk' else (0, p.puschem('Rev211', '211', 'reviewer').encode(), b'')
        before = w.ledger.read_bytes()
        r = p.sudit(door, w, p.vyzov(w, 'reviewer', 'Rev211', obj))
        actual = r.returncode, r.stdout, r.stderr
        errors = [] if actual == expected else ['RESULT expected=%r actual=%r' % (expected, actual)]
        if expected[0] and w.ledger.read_bytes() != before:
            errors.append('LEDGER_CHANGED_ON_REFUSAL')
        if expected[0] == 0:
            starts = [row for row in w.ledg() if row.get('t') == 'START' and row.get('holder') == 'Rev211']
            if len(starts) != 1 or starts[0].get('object') != obj:
                errors.append('START_OBJECT')
        return errors


def case(name, door):
    if name.startswith('product-'):
        return product_case(name, door)
    with tempfile.TemporaryDirectory(prefix='owner214-') as tmp:
        w = p.Mir(tmp)
        env = dict(p.GIT_ENV)
        role, holder = 'reviewer', 'Rev211'
        want_rc, want_err = 0, b''
        arb = name.startswith('arb')
        no_class = arb or name in ('dirty-legacy-risk', 'dirty-legacy-safe', 'dirty-legacy-untracked', 'unknown-legacy', 'committed-legacy-safe', 'dirty-author-legacy', 'pinned-head', 'legacy-symlink')
        klass = None if no_class else ('рисковый' if name in ('isolated-risk', 'other-origin-risk', 'same-origin-risk', 'forged-pin', 'risk-after-adversary', 'adversary-risk') else 'обычный')
        kat = 'x' if name in ('dirty-profile', 'profile-deleted', 'ambient-profile', 'critic-profile') else 'contracts'
        wt, br, f, obj = p.mir_bootstrap(w, '211', klass, kat=kat)
        if kat != 'contracts':
            p.profil_proekta(w.repo, kat)
            checked(w.git(['add', '-A']))
            checked(w.git(['commit', '-q', '-m', 'trusted profile']))
        tag = w.stancija_teg(wt, '211', f)
        if name not in ('arb1', 'arb2', 'arb3', 'arb4', 'arb5', 'arb6', 'dirty-author-legacy', 'forged-latest-tag', 'critic-profile'):
            w.stancija_stroka('211', tag)
        if arb:
            # Arbitration §1, all six input worlds AS WRITTEN: no declaration,
            # station tag unchanged, author has no origin and forges a tag;
            # author pin is committed; legacy remains UNCOMMITTED.
            checked(p.wt_git(wt, 'remote', 'remove', 'origin'))
            checked(p.wt_git(wt, 'tag', '-a', 'frozen/contracts/211/1', '-m', 'fixture', f))
            local_tag = checked(p.wt_git(wt, 'rev-parse', 'frozen/contracts/211/1'))
            if name in ('arb3', 'arb4', 'arb5'):
                obj = p.kommit(wt, 'registry/contracts.tsv', '211 → ' + local_tag + '\n', soobshenie='author pin')
            if name in ('arb1', 'arb2', 'arb3', 'arb4'):
                p.legacy_avtora(w, wt, obj, '211')
            want_rc = 1
            want_err = (p.predupr_neodnoznachno('211') + p.otkaz_adv_do_rev('211')).encode()
        elif name in ('isolated-risk', 'isolated-safe', 'other-origin-risk'):
            checked(p.wt_git(wt, 'remote', 'remove', 'origin'))
            if name == 'other-origin-risk':
                checked(p.wt_git(wt, 'remote', 'add', 'origin', 'ssh://git@github.com/test/other.git'))
            if name != 'isolated-safe':
                # Attacker controls COMMITTED class, pin and tags as well as dirt.
                p.perepisat_kontrakt(wt, '211', 'обычный')
                safe = p.kommit_vse(wt)
                checked(p.wt_git(wt, 'tag', '-a', 'frozen/contracts/211/1', '-m', 'forged', safe))
                forged = checked(p.wt_git(wt, 'rev-parse', 'frozen/contracts/211/1'))
                obj = p.kommit(wt, 'registry/contracts.tsv', '211 → ' + forged + '\n')
                want_rc, want_err = 1, p.otkaz_adv_do_rev('211').encode()
        elif name in ('dirty-legacy-risk', 'dirty-legacy-safe', 'dirty-legacy-untracked', 'committed-legacy-safe', 'unknown-legacy', 'pinned-head'):
            if name != 'unknown-legacy':
                if name != 'dirty-legacy-untracked':
                    legacy(w, wt, obj, 'обычный' if name in ('dirty-legacy-safe', 'committed-legacy-safe') else 'рисковый')
                if name not in ('committed-legacy-safe', 'pinned-head'):
                    legacy(w, wt, obj, 'рисковый' if name == 'dirty-legacy-safe' else 'обычный', commit=False)
            if name in ('dirty-legacy-risk', 'pinned-head'):
                want_rc, want_err = 1, p.otkaz_adv_do_rev('211').encode()
            if name in ('unknown-legacy', 'dirty-legacy-untracked'):
                want_rc = 1
                want_err = (p.predupr_neodnoznachno('211') + p.otkaz_adv_do_rev('211')).encode()
            if name == 'pinned-head':
                old = checked(w.git(['rev-parse', 'HEAD']))
                legacy(w, wt, obj, 'обычный')
                new = checked(w.git(['rev-parse', 'HEAD']))
                env = race_env(w, old, new)
        elif name == 'legacy-symlink':
            external = w.root / 'external-legacy.tsv'
            put(external, p.legacy_stroka(wt, obj, '211') + '\tобычный\tоснование\tподтвердил\n')
            (w.repo / 'registry/risk-legacy.tsv').symlink_to(external)
            checked(w.git(['add', 'registry/risk-legacy.tsv']))
            checked(w.git(['commit', '-q', '-m', 'legacy symlink']))
            want_rc = 1
            want_err = (p.predupr_neodnoznachno('211') + p.otkaz_adv_do_rev('211')).encode()
        elif name in ('dirty-profile', 'profile-deleted', 'ambient-profile', 'critic-profile'):
            # Same honest x contract, fake risky decoy in contracts on OBJECT.
            obj = p.kommit(wt, 'contracts/211-decoy.md', p.kontrakt_tekst('211', 'рисковый'))
            if name == 'profile-deleted':
                (w.repo / 'harness.project.json').unlink()
            elif name == 'ambient-profile':
                p.profil_proekta(wt, 'contracts')
                env['HARNESS_PROJECT_LAYER_ROOT'] = wt
            elif name == 'critic-profile':
                role, holder = 'critic', 'Crit211'
                checked(w.git(['tag', '-d', 'frozen/contracts/211/1']))
                p.profil_proekta(wt, 'absent')
                p.kommit_vse(wt)
                obj = checked(p.wt_git(wt, 'rev-parse', 'HEAD'))
            else:
                p.profil_proekta(w.repo, 'contracts')
        elif name == 'dirty-author-legacy':
            legacy(w, wt, obj, 'рисковый')
            p.legacy_avtora(w, wt, obj, '211')
            want_rc, want_err = 1, p.otkaz_adv_do_rev('211').encode()
        elif name == 'forged-latest-tag':
            checked(p.wt_git(wt, 'tag', '-a', 'frozen/contracts/211/2', '-m', 'forged', obj))
        elif name == 'forged-pin':
            p.perepisat_kontrakt(wt, '211', 'обычный')
            safe = p.kommit_vse(wt)
            checked(p.wt_git(wt, 'tag', '-a', 'frozen/contracts/211/1', '-m', 'forged', safe))
            forged = checked(p.wt_git(wt, 'rev-parse', 'frozen/contracts/211/1'))
            obj = p.kommit(wt, 'registry/contracts.tsv', '211 → ' + forged + '\n')
            checked(w.git(['fetch', '-q', wt, obj]))
            # Also copy only the immutable object, NOT the author-controlled ref.
            checked(w.git(['fetch', '-q', wt, 'refs/tags/frozen/contracts/211/1']))
            want_rc, want_err = 1, p.otkaz_adv_do_rev('211').encode()
        elif name == 'missing-source':
            checked(w.git(['symbolic-ref', 'HEAD', 'refs/heads/unborn']))
            want_rc = 1
            want_err = 'ОТКАЗ: ISTOCHNIK_RISKA_NEDOSTUPEN: предмет 211: нет закреплённого состояния владельца\n'.encode()
        elif name == 'risk-after-adversary':
            p.krug_adv(w, '211', obj)
        elif name == 'adversary-risk':
            role, holder = 'adversary', 'Adv211'
        elif name == 'same-origin-risk':
            want_rc, want_err = 1, p.otkaz_adv_do_rev('211').encode()
        p.avtor_sdal(w, '211', wt, br)
        before = w.ledger.read_bytes()
        expected = (want_rc, b'' if want_rc else p.puschem(holder, '211', role).encode(), want_err)
        # All expectations are immutable in memory BEFORE the subject invocation.
        event = p.vyzov(w, role, holder, obj)
        result = p.sudit(door, w, event, env=env)
        actual = result.returncode, result.stdout, result.stderr
        errors = []
        if result.returncode == 2 or b'NOT_IMPLEMENTED' in result.stderr or b'syntax error' in result.stderr:
            raise RuntimeError('SUBJECT_UNAVAILABLE ' + name + ' ' + repr(actual))
        if actual != expected:
            errors.append('RESULT expected=%r actual=%r' % (expected, actual))
        if want_rc and w.ledger.read_bytes() != before:
            errors.append('LEDGER_CHANGED_ON_REFUSAL')
        if not want_rc:
            starts = [row for row in w.ledg() if row.get('t') == 'START' and row.get('holder') == holder]
            if len(starts) != 1 or starts[0].get('object') != obj:
                errors.append('START_OBJECT')
        if arb and checked(w.git(['rev-parse', 'frozen/contracts/211/1'])) != tag:
            errors.append('TRUSTED_TAG_CHANGED')
        if name == 'pinned-head' and not (w.root / 'race-fired').is_file():
            errors.append('RACE_NOT_EXERCISED')
        return errors


def carriers():
    src = json.loads((HERE / 'source.json').read_text())
    expected_tsv = ''.join('%s\t%s\t%s\n' % (link['name'], link['path'], c) for link in src['links'] for c in link['cases'])
    if (HERE / 'stabs.tsv').read_text() != expected_tsv:
        raise RuntimeError('STABS_TSV_DRIFT')
    for path, digest in src['files'].items():
        if hashlib.sha256((HERE / path).read_bytes()).hexdigest() != digest:
            raise RuntimeError('CARRIER_DRIFT ' + path)
    if not CASES or not src['links']:
        raise RuntimeError('EMPTY_CENSUS')
    for link in src['links']:
        if not link['cases'] or not set(link['cases']) <= set(CASES):
            raise RuntimeError('INVALID_LINK ' + link['name'])
    return src


def suite(door, cases):
    bad = []
    for name in cases:
        errors = case(name, door)
        if errors:
            bad.append(name)
            print(name, 'RED', '; '.join(errors))
    print('KLETKI', len(cases), 'KRASNYH', len(bad))
    return bad


def main():
    ap = argparse.ArgumentParser()
    modes = ap.add_mutually_exclusive_group()
    modes.add_argument('--repo', type=Path)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--sintaksis', action='store_true')
    modes.add_argument('--catalog', action='store_true')
    modes.add_argument('--context', action='store_true')
    modes.add_argument('--regress', action='store_true')
    args = ap.parse_args()
    scratch = ROOT / 'tmp/scratch-arch214'
    scratch.mkdir(parents=True, exist_ok=True)
    os.environ['TMPDIR'] = str(scratch)
    p.tempfile.tempdir = str(scratch)
    p.GIT_ENV['TMPDIR'] = str(scratch)
    src = carriers()
    for binary in ('git', 'jq', 'bash'):
        if not shutil.which(binary):
            raise RuntimeError('MISSING_DEPENDENCY ' + binary)
    if args.regress:
        return subprocess.run([sys.executable, '-B', str(HERE / 'regress.py')], cwd=ROOT).returncode
    if args.context:
        return subprocess.run([sys.executable, '-B', str(HERE / 'context.py')], cwd=ROOT).returncode
    if args.catalog:
        print('KLETKI', len(CASES), 'STABS', len(src['links']), 'LINKS', sum(len(x['cases']) for x in src['links']))
        print('\n'.join(CASES))
        return 0
    if args.sintaksis:
        for path in [HERE / 'red_doverennyj_vladelec_214.sh', *(HERE / f for f in src['files'])]:
            subprocess.run(['bash', '-n', str(path)], check=True)
        validator = ROOT / 'scripts/validate_std.sh'
        subprocess.run(['bash', str(validator), 'bash', str(HERE / 'red_doverennyj_vladelec_214.sh')], check=True, cwd=ROOT)
        # Compile in memory: never leave __pycache__ scaffolding.
        for path in HERE.glob('*.py'):
            compile(path.read_bytes(), str(path), 'exec')
        print('SINTAKSIS', len(src['files']) + 1)
        return 0
    model = HERE / 'model/zamok_predmeta.sh'
    if args.stabs:
        for path in src['files']:
            subprocess.run(['bash', '-n', str(HERE / path)], check=True)
        if suite(model, CASES):
            raise RuntimeError('HONEST_CONTROL_RED')
        alive = []
        for link in src['links']:
            for name in link['cases']:
                errors = case(name, HERE / link['path'])
                print(link['name'], name, 'RED' if errors else 'ALIVE')
                if not errors:
                    alive.append((link['name'], name))
        print('STABS', len(src['links']), 'LINKS', sum(len(x['cases']) for x in src['links']), 'ZHIVYH', len(alive))
        return int(bool(alive))
    door = model if args.model else (args.repo or ROOT).resolve() / 'scripts/zamok_predmeta.sh'
    if not door.is_file():
        raise RuntimeError('SUBJECT_ABSENT ' + str(door))
    return int(bool(suite(door, CASES)))


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, subprocess.SubprocessError, AssertionError, OSError, ValueError) as exc:
        print('ORACLE_UNAVAILABLE', str(exc), file=sys.stderr)
        sys.exit(2)
