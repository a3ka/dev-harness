#!/usr/bin/env python3
"""225: публичные CLI, реальные временные деревья; ожидания в памяти до вызова."""
import configparser
import copy
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
MODEL = HERE / 'model'
FILES = {
    'root/ci-artifacts-clean': ('sbin', 0o755),
    'root/ci-runner-tmp-clean': ('sbin', 0o755),
    'root/ci-clean.py': ('sbin', 0o644),
    'ci-clean.json': ('sbin', 0o644),
    'ci-clean.schema.json': ('sbin', 0o644),
    'root/systemd/ci-runner-tmp-clean.service': ('etc', 0o644),
    'root/systemd/ci-runner-tmp-clean.timer': ('etc', 0o644),
}


class BadWorld(Exception):
    pass


def check(condition, message):
    if not condition:
        raise AssertionError(message)


def age(path, days):
    stamp = time.time() - days * 86400
    if path.is_dir() and not path.is_symlink():
        for child in path.iterdir():
            age(child, days)
    os.utime(path, (stamp, stamp), follow_symlinks=False)


def snapshot(root):
    if not root.exists():
        return None
    result = {}
    for parent, dirs, files in os.walk(root, followlinks=False):
        for name in dirs + files:
            path = Path(parent) / name
            mode = path.lstat().st_mode
            value = os.readlink(path) if path.is_symlink() else (path.read_bytes() if path.is_file() else None)
            result[str(path.relative_to(root))] = (mode, value)
    return result


def run(argv, env):
    clean = {k: v for k, v in os.environ.items()
             if not k.startswith(('CI_ARTIFACTS_', 'CI_CLEAN_', 'OPS_SERVER_'))}
    clean.pop('HOME', None)
    clean.update(env)
    clean['PYTHONDONTWRITEBYTECODE'] = '1'
    proc = subprocess.run(argv, env=clean, cwd=env.get('TMPDIR'),
                          stdin=subprocess.DEVNULL, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, text=True, timeout=30)
    if proc.returncode == 2 and 'NOT_IMPLEMENTED: использование:' not in proc.stderr:
        raise BadWorld(proc.stderr.strip())
    return proc


class World:
    def __init__(self, source, overlay=None):
        self.tmp = tempfile.TemporaryDirectory(prefix='ci225-')
        self.root = Path(self.tmp.name)
        self.src = self.root / 'ops/server'
        shutil.copytree(source, self.src)
        if overlay:
            for path in overlay.rglob('*'):
                if path.is_file():
                    dst = self.src / path.relative_to(overlay)
                    dst.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(path, dst)
        self.bin = self.root / 'bin'
        self.bin.mkdir()
        self.runtime = self.root / 'runtime'
        self.runtime.mkdir()
        for rel in FILES:
            src = self.src / rel
            if src.is_file() and not rel.startswith('root/systemd/'):
                shutil.copyfile(src, self.runtime / src.name)
        self.cfg = copy.deepcopy(json.loads((MODEL / 'ci-clean.json').read_text()))
        self.cfg['artifacts'].update(root=str(self.root / 'artifacts'), retention_days=4, repos=['Repo-A', 'Repo-B'])
        self.cfg['tmp'].update(retention_days=2, proc_root=str(self.root / 'proc'),
                               cgroup_root=str(self.root / 'cgroup'), systemctl=str(self.bin / 'systemctl'))
        self.cfg['tmp']['lock_path'] = str(self.root / 'cleanup.lock')
        self.cfg['tmp']['runners'] = [
            {'root': str(self.root / 'runner one'), 'unit': 'toy-a.service'},
            {'root': str(self.root / 'runner two'), 'unit': 'toy-b.service'},
        ]
        self.state = {'units': {}, 'fail': '', 'race': False}
        for i, runner in enumerate(self.cfg['tmp']['runners']):
            Path(runner['root']).mkdir()
            group = self.root / 'cgroup' / runner['unit']
            group.mkdir(parents=True)
            (group / 'cgroup.procs').write_text('')
            (group / 'cgroup.events').write_text('frozen 0\n')
            self.state['units'][runner['unit']] = {'active': 'active', 'group': '/' + runner['unit']}
        (self.root / 'proc').mkdir()
        Path(self.cfg['artifacts']['root']).mkdir()
        (self.root / 'outside').mkdir()
        (self.root / 'outside/precious').write_bytes(b'outside must survive\x00\xff')
        self.outside = snapshot(self.root / 'outside')
        shutil.copyfile(HERE / 'shims/systemctl.py', self.bin / 'systemctl')
        (self.bin / 'systemctl').chmod(0o755)
        self.config_path = self.root / 'configuration.json'
        self.state_path = self.root / 'state.json'
        self.journal_path = self.root / 'ctl.jsonl'
        self.env = {'CI_CLEAN_CONFIG': str(self.config_path), 'CI225_STATE': str(self.state_path),
                    'CI225_JOURNAL': str(self.journal_path), 'CI225_CGROUP': str(self.root / 'cgroup'),
                    'CI225_PROC': str(self.root / 'proc'), 'TMPDIR': str(self.root),
                    'PATH': str(self.bin) + ':/usr/bin:/bin'}

    def __enter__(self):
        return self

    def __exit__(self, *_):
        self.tmp.cleanup()

    def save(self):
        self.config_path.write_text(json.dumps(self.cfg))
        self.state_path.write_text(json.dumps(self.state))

    def entry(self, index=0, name='job old', days=3, directory=True):
        path = Path(self.cfg['tmp']['runners'][index]['root']) / name
        if directory:
            path.mkdir()
            (path / 'nested').mkdir()
            (path / 'nested/data').write_bytes(b'job bytes')
        else:
            path.write_bytes(b'file bytes')
        age(path, days)
        return path

    def artifact(self, days=5):
        path = Path(self.cfg['artifacts']['root']) / 'Repo-A/111-1'
        path.mkdir(parents=True)
        (path / 'data').write_bytes(b'artifact')
        age(path, days)
        return path

    def execute(self, which='tmp', raw=None):
        self.save()
        if raw is not None:
            self.config_path.write_text(raw)
        script = self.runtime / ('ci-artifacts-clean' if which == 'artifacts' else 'ci-runner-tmp-clean')
        check(script.is_file(), f'SUBJECT_ABSENT {script.name}')
        # До cutover старый cleaner 196 не знает CI_CLEAN_CONFIG. Его запуск
        # без старых ENV-швов полез бы в живой /var/lib; это отсутствие 225,
        # а не допустимый вход нового конфигурируемого шва.
        check((self.runtime / 'ci-clean.py').is_file(), 'SUBJECT_ABSENT ci-clean.py')
        result = run(['bash', str(script)], self.env)
        check(snapshot(self.root / 'outside') == self.outside, 'OUTSIDE_CHANGED')
        return result

    def journal(self):
        if not self.journal_path.exists():
            return []
        return [json.loads(row) for row in self.journal_path.read_text().splitlines()]

    def worker(self, index=0, nested=False):
        runner = self.cfg['tmp']['runners'][index]
        group = self.root / 'cgroup' / runner['unit']
        if nested:
            group = group / 'child.scope'
            group.mkdir()
        (group / 'cgroup.procs').write_text('54321\n')
        proc = self.root / 'proc/54321'
        proc.mkdir(exist_ok=True)
        (proc / 'comm').write_text(self.cfg['tmp']['worker_names'][0] + '\n')


def clean_case(source, overlay, kind):
    with World(source, overlay) as w:
        old = w.entry()
        young = w.entry(name='young', days=0.25)
        before = snapshot(Path(w.cfg['tmp']['runners'][0]['root']))
        expected_rc = 0
        reason = None
        if kind == 'second-root':
            old = w.entry(index=1)
        elif kind == 'young-inside':
            (old / 'nested/data').write_bytes(b'new bytes')
        elif kind == 'file-names':
            old.rmdir() if not list(old.iterdir()) else shutil.rmtree(old)
            entries = [w.entry(name=name, directory=False) for name in ('-rf', 'a b', 'a\nb', 'é;$(x)')]
        elif kind in ('busy', 'busy-nested'):
            w.worker(nested=kind == 'busy-nested')
        elif kind == 'busy-second':
            old = w.entry(index=1)
            before = snapshot(Path(w.cfg['tmp']['runners'][1]['root']))
            w.worker(index=1)
        elif kind == 'race-worker':
            w.state['race'] = True
        elif kind == 'idle-process':
            w.worker()
            (w.root / 'proc/54321/comm').write_text('Runner.Listener\n')
        elif kind == 'configured-worker':
            w.cfg['tmp']['worker_names'] = ['Different.Worker']
            w.worker()
        elif kind == 'inactive':
            w.state['units']['toy-a.service']['active'] = 'inactive'
        elif kind == 'empty-root':
            shutil.rmtree(old)
            shutil.rmtree(young)
        elif kind == 'tmp-retention':
            w.cfg['tmp']['retention_days'] = 5
        elif kind == 'tmp-root-config':
            relocated = w.root / 'relocated root'
            relocated.mkdir()
            w.cfg['tmp']['runners'][0]['root'] = str(relocated)
        elif kind in ('entry-symlink', 'nested-symlink'):
            link = old / 'nested/link' if kind == 'nested-symlink' else Path(w.cfg['tmp']['runners'][0]['root']) / 'link'
            link.symlink_to(w.root / 'outside', target_is_directory=True)
            age(old, 3)
            if kind == 'entry-symlink':
                expected_rc, reason = 1, 'TMP_SYMLINK'
        elif kind in ('freeze-fail', 'thaw-fail', 'not-frozen', 'state-fail'):
            w.state['fail'] = {'freeze-fail': 'freeze', 'thaw-fail': 'thaw', 'not-frozen': 'not-frozen', 'state-fail': 'show'}[kind]
            expected_rc, reason = 1, {'freeze-fail': 'RUNNER_CTL_FAILED freeze', 'thaw-fail': 'THAW_FAILED', 'not-frozen': 'RUNNER_NOT_FROZEN', 'state-fail': 'RUNNER_CTL_FAILED show'}[kind]
        elif kind == 'unknown-state':
            w.state['units']['toy-a.service']['active'] = 'activating'
            expected_rc, reason = 1, 'RUNNER_STATE_UNAVAILABLE'
        elif kind == 'proc-missing':
            w.worker()
            (w.root / 'proc/54321/comm').unlink()
            expected_rc, reason = 1, 'ОТКАЗ:'
        elif kind == 'cgroup-traversal':
            w.state['units']['toy-a.service']['group'] = '/../outside'
            expected_rc, reason = 1, 'RUNNER_STATE_UNAVAILABLE'
        elif kind in ('root-symlink', 'parent-symlink', 'root-missing', 'root-dotdot'):
            root = Path(w.cfg['tmp']['runners'][0]['root'])
            if kind == 'root-dotdot':
                w.cfg['tmp']['runners'][0]['root'] = str(root) + '/../outside'
                reason = 'CONFIG_INVALID'
            elif kind == 'parent-symlink':
                link = w.root / 'parent-link'
                link.symlink_to(w.root, target_is_directory=True)
                w.cfg['tmp']['runners'][0]['root'] = str(link / root.name)
                reason = 'ROOT_INVALID'
            else:
                shutil.rmtree(root)
                if kind == 'root-symlink':
                    root.symlink_to(w.root / 'outside', target_is_directory=True)
                reason = 'ROOT_INVALID'
            expected_rc = 1
        result = w.execute()
        check(result.returncode == expected_rc, f'RC {result.returncode} != {expected_rc}: {result.stderr}')
        if reason:
            check(reason in result.stderr, f'REASON {reason}: {result.stderr}')
        retain = kind in ('young-inside', 'busy', 'busy-nested', 'busy-second', 'configured-worker', 'race-worker', 'tmp-retention', 'tmp-root-config', 'freeze-fail', 'not-frozen', 'state-fail', 'unknown-state', 'proc-missing', 'cgroup-traversal', 'root-dotdot', 'parent-symlink')
        if retain:
            check(old.exists(), 'OLD_LIVE_REMOVED')
        elif kind == 'file-names':
            check(all(not p.exists() for p in entries), 'ODD_FILE_KEPT')
        elif kind not in ('root-symlink', 'root-missing', 'empty-root'):
            check(not old.exists(), 'OLD_NOT_REMOVED')
        if kind not in ('root-symlink', 'root-missing', 'empty-root'):
            check(young.is_dir(), 'YOUNG_REMOVED')
        if kind in ('busy', 'busy-nested', 'busy-second', 'configured-worker', 'race-worker'):
            root = Path(w.cfg['tmp']['runners'][1 if kind == 'busy-second' else 0]['root'])
            check(snapshot(root) == before, 'BUSY_TREE_CHANGED')
            check('ci-tmp: BUSY ' in result.stdout, 'BUSY_NOT_NAMED')
        if kind == 'entry-symlink':
            check(link.is_symlink(), 'SYMLINK_REMOVED')
        if kind == 'tmp-root-config':
            check(old.exists() and list(relocated.iterdir()) == [], 'ROOT_CONFIG_IGNORED')
        if kind in ('old-young', 'idle-process', 'busy', 'busy-nested', 'busy-second', 'race-worker', 'configured-worker', 'freeze-fail', 'not-frozen', 'proc-missing'):
            calls = [(r[0], r[1]) for r in w.journal()]
            for unit in ('toy-a.service', 'toy-b.service'):
                check(('freeze', unit) in calls and ('thaw', unit) in calls, 'QUIESCENCE_OR_RELEASE_MISSING')
                check(calls.index(('freeze', unit)) < calls.index(('thaw', unit)), 'FREEZE_ORDER')


def config_case(source, overlay, kind):
    with World(source, overlay) as w:
        old = w.entry()
        raw = None
        if kind == 'empty': raw = ''
        elif kind == 'empty-object': raw = '{}'
        elif kind == 'duplicate': raw = '{"tmp":{},"tmp":{}}'
        elif kind == 'nul-path': w.cfg['tmp']['runners'][0]['root'] += '\x00bad'
        elif kind == 'overlap': w.cfg['tmp']['runners'][1]['root'] = w.cfg['tmp']['runners'][0]['root']
        elif kind == 'unknown-key': w.cfg['tmp']['typo'] = True
        elif kind == 'zero': w.cfg['tmp']['retention_days'] = 0
        elif kind == 'nonnumeric': w.cfg['tmp']['retention_days'] = 'yesterday'
        elif kind == 'negative': w.cfg['tmp']['retention_days'] = -2
        elif kind == 'fraction': w.cfg['tmp']['retention_days'] = 0.5
        elif kind == 'artifact-zero': w.cfg['artifacts']['retention_days'] = 0
        elif kind == 'config-path-empty': w.env['CI_CLEAN_CONFIG'] = ''
        elif kind == 'missing': w.env['CI_CLEAN_CONFIG'] = str(w.root / 'absent')
        elif kind == 'unit-newline': w.cfg['tmp']['runners'][0]['unit'] += '\n'
        elif kind == 'worker-newline': w.cfg['tmp']['worker_names'][0] += '\n'
        elif kind == 'unit-duplicate': w.cfg['tmp']['runners'][1]['unit'] = w.cfg['tmp']['runners'][0]['unit']
        elif kind == 'relative-root': w.cfg['tmp']['runners'][0]['root'] = 'relative'
        elif kind == 'repo-traversal': w.cfg['artifacts']['repos'] = ['..']
        elif kind == 'lock-inside-root': w.cfg['tmp']['lock_path'] = w.cfg['tmp']['runners'][0]['root'] + '/lock'
        before = snapshot(w.root / 'runner one')
        result = w.execute(raw=raw)
        check(result.returncode == 1 and 'CONFIG_INVALID' in result.stderr, f'CONFIG_ACCEPTED {result.returncode}: {result.stderr}')
        check(old.exists() and snapshot(w.root / 'runner one') == before, 'CONFIG_REFUSAL_WROTE')
        check(not w.journal(), 'CONFIG_REFUSAL_CTL')


def artifact_case(source, overlay, kind):
    with World(source, overlay) as w:
        old = w.artifact(days=3)
        young = old.parent / '222-2'
        shutil.copytree(old, young)
        age(young, 0.25)
        w.cfg['artifacts']['retention_days'] = 2
        if kind == 'artifact-retention':
            w.cfg['artifacts']['retention_days'] = 6
        elif kind == 'artifact-root-config':
            relocated = w.root / 'different artifacts'
            relocated.mkdir()
            w.cfg['artifacts']['root'] = str(relocated)
        elif kind == 'artifact-env':
            w.env['CI_ARTIFACTS_RETENTION_DAYS'] = '8'
        result = w.execute('artifacts')
        check(result.returncode == 0, f'ARTIFACT_RC {result.returncode}: {result.stderr}')
        retained = kind in ('artifact-retention', 'artifact-root-config', 'artifact-env')
        check(old.exists() == retained and young.is_dir(), 'ARTIFACT_CONFIG_IGNORED')
        check(not w.journal(), 'ARTIFACTS_TOUCHED_RUNNER')


def load196():
    spec = importlib.util.spec_from_file_location('ci225_regression196', HERE.parent / 'ops_ci_artifacts_196/probe.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def installer_case(source, overlay, kind):
    old = load196()
    with World(source, overlay) as w:
        prefix = ['bash', str(w.src / ('install-ci-clean.sh' if (w.src / 'install-ci-clean.sh').exists() else 'install.sh'))]
        fw = old.World()
        try:
            env = old.install_env(fw, w.src, euid=1 if kind == 'install-euid' else 0,
                                  systemctl='fail-reload' if kind == 'install-reload-fail' else ('fail-enable' if kind == 'install-enable-fail' else 'ok'))
            env['TMPDIR'] = str(w.root)
            env['HOME'] = str(w.root / 'home')
            destinations = {rel: Path(env['OPS_SERVER_ETC_DST'] if target == 'etc' else env['OPS_SERVER_SBIN_DST']) / Path(rel).name for rel, (target, _) in FILES.items()}
            expected = {rel: (w.src / rel).read_bytes() for rel in FILES if (w.src / rel).is_file()}
            # Неполный source — наблюдаемый отказ предмета, не ошибка мира.
            if kind.startswith('source-missing:'):
                rel = kind.partition(':')[2]
                if (w.src / rel).exists(): (w.src / rel).unlink()
            if kind == 'install-invalid-config':
                (w.src / 'ci-clean.json').write_text('{}')
            if kind == 'artifacts-common':
                if not (w.src / 'install-ci-clean.sh').exists():
                    env['OPS_SERVER_BIN_DST'] = str(old.install_core_files(fw, w.src))
                result = run(prefix + ['artifacts'], env)
                check(result.returncode == 0, f'ARTIFACTS_COMMON_RC {result.stderr}')
                for rel in ('root/ci-artifacts-clean', 'root/ci-clean.py', 'ci-clean.json', 'ci-clean.schema.json'):
                    dst = destinations[rel]
                    check(dst.is_file() and dst.read_bytes() == expected.get(rel), 'ARTIFACTS_COMMON_MISSING ' + rel)
                result = run(prefix + ['verify'], env)
                check(result.returncode == 0 and 'ci-clean:' in result.stdout, 'ARTIFACTS_COMMON_VERIFY ' + result.stderr)
                return
            before = {key: snapshot(fw.path(key)) for key in ('sbin', 'etc/systemd/system')}
            result = run(prefix + ['ci-clean'], env)
            refusal = kind in ('install-euid', 'install-invalid-config') or kind.startswith('source-missing:')
            if refusal:
                check(result.returncode == 1 and 'ОТКАЗ:' in result.stderr, f'INSTALL_PRECONDITION {result.returncode}: {result.stderr}')
                if kind == 'install-euid': check('euid 0' in result.stderr, 'EUID_REASON')
                if kind.startswith('source-missing:'): check(kind.partition(':')[2] in result.stderr, 'SOURCE_REASON')
                for key in before:
                    check(snapshot(fw.path(key)) == before[key], 'PRECONDITION_WROTE')
                check(not fw.journal('chown') and not fw.journal('chmod') and not fw.journal('systemctl'), 'PRECONDITION_EFFECT')
                return
            if kind in ('install-reload-fail', 'install-enable-fail'):
                check(result.returncode == 1 and 'systemctl' in result.stderr, 'SYSTEMCTL_FAILURE_IGNORED')
                return
            check(result.returncode == 0, f'INSTALL_RC {result.returncode}: {result.stderr}')
            for rel, dst in destinations.items():
                check(dst.is_file() and dst.read_bytes() == expected[rel], f'INSTALL_BYTES {rel}')
                check(stat.S_IMODE(dst.stat().st_mode) == FILES[rel][1], f'INSTALL_MODE {rel}')
                check(any('root:root' in row and str(dst) in row for row in fw.journal('chown')), f'INSTALL_OWNER {rel}')
            ctl = fw.journal('systemctl')
            check('systemctl daemon-reload' in ctl and 'systemctl enable --now ci-runner-tmp-clean.timer' in ctl, 'TIMER_NOT_ENABLED')
            check(ctl.index('systemctl daemon-reload') < ctl.index('systemctl enable --now ci-runner-tmp-clean.timer'), 'RELOAD_ORDER')
            if kind.startswith('verify-'):
                # Прочие установленные предметы — исправные предусловия verify.
                if not (w.src / 'install-ci-clean.sh').exists():
                    env['OPS_SERVER_BIN_DST'] = str(old.install_core_files(fw, w.src))
                    prepared = run(prefix + ['artifacts'], env)
                    check(prepared.returncode == 0, f'ARTIFACTS_PREPARATION {prepared.stderr}')
                if kind == 'verify-clean':
                    result = run(prefix + ['verify'], env)
                    check(result.returncode == 0 and 'ci-clean:' in result.stdout, f'VERIFY_FALSE_RED {result.stderr}')
                elif kind == 'verify-not-installed':
                    for rel in ('root/ci-runner-tmp-clean', 'root/systemd/ci-runner-tmp-clean.service', 'root/systemd/ci-runner-tmp-clean.timer'):
                        destinations[rel].unlink()
                    result = run(prefix + ['verify'], env)
                    check(result.returncode == 0 and 'ci-clean: не установлены' in result.stdout, 'OPTIONAL_FALSE_RED ' + result.stderr)
                elif kind.startswith('verify-partial:'):
                    kept = kind.partition(':')[2]
                    group = ('root/ci-clean.py', 'ci-clean.json', 'ci-clean.schema.json') if kept in ('root/ci-clean.py', 'ci-clean.json', 'ci-clean.schema.json') else ('root/ci-runner-tmp-clean', 'root/systemd/ci-runner-tmp-clean.service', 'root/systemd/ci-runner-tmp-clean.timer')
                    for rel in group:
                        if rel != kept: destinations[rel].unlink()
                    if kept in ('root/ci-clean.py', 'ci-clean.json', 'ci-clean.schema.json'):
                        for rel in ('root/ci-runner-tmp-clean', 'root/systemd/ci-runner-tmp-clean.service', 'root/systemd/ci-runner-tmp-clean.timer'):
                            destinations[rel].unlink()
                    result = run(prefix + ['verify'], env)
                    check(result.returncode == 1 and 'расхождение' in result.stderr, 'PARTIAL_ACCEPTED ' + kept)
                else:
                    rel = kind.partition(':')[2]
                    dst = destinations[rel]
                    if kind.startswith('verify-missing:'): dst.unlink()
                    else: dst.write_bytes(expected[rel] + b'\ndrift\n')
                    result = run(prefix + ['verify'], env)
                    check(result.returncode == 1 and 'расхождение' in result.stderr and str(dst) in result.stderr, f'VERIFY_BLIND {rel}: {result.returncode} {result.stderr}')
        finally:
            fw.close()


def defaults_case(source, overlay):
    with World(source, overlay) as w:
        path = w.src / 'ci-clean.json'
        check(path.is_file(), 'CONFIG_ABSENT')
        import jsonschema
        value = json.loads(path.read_text())
        schema = json.loads((MODEL / 'ci-clean.schema.json').read_text())
        jsonschema.Draft202012Validator(schema).validate(value)
        check(value == json.loads((MODEL / 'ci-clean.json').read_text()), 'DEFAULTS_NOT_CONFIG_CANON')


def units_case(source, overlay):
    with World(source, overlay) as w:
        for name in ('ci-runner-tmp-clean.service', 'ci-runner-tmp-clean.timer'):
            rel = 'root/systemd/' + name
            check((w.src / rel).is_file(), 'UNIT_ABSENT ' + name)
            def parsed(path):
                cfg = configparser.ConfigParser(interpolation=None, strict=True)
                cfg.optionxform = str
                cfg.read_string(path.read_text())
                return {section: dict(cfg[section]) for section in cfg.sections()}
            check(parsed(w.src / rel) == parsed(MODEL / rel), 'UNIT_CANON ' + name)


def readme_case(source, overlay):
    with World(source, overlay) as w:
        path = w.src / 'README.md'
        check(path.is_file(), 'README_ABSENT')
        canon = (MODEL / 'README.md').read_text().splitlines()
        rows = path.read_text().splitlines()
        check(canon[0] in rows, 'README_SECTION_ABSENT')
        start = rows.index(canon[0])
        end = next((i for i in range(start + 1, len(rows)) if rows[i].startswith('## ')), len(rows))
        section = rows[start:end]
        check(all(row in section for row in canon if row), 'README_CANON_MISSING')


def lock_case(source, overlay):
    with World(source, overlay) as w:
        old = w.entry()
        before = snapshot(old)
        with Path(w.cfg['tmp']['lock_path']).open('w') as stream:
            fcntl.flock(stream, fcntl.LOCK_EX | fcntl.LOCK_NB)
            result = w.execute()
        check(result.returncode == 1 and 'CLEAN_BUSY' in result.stderr, 'CONCURRENT_CLEAN_ACCEPTED')
        check(snapshot(old) == before and not w.journal(), 'CONCURRENT_CLEAN_EFFECT')


TMP_CASES = ('old-young', 'second-root', 'young-inside', 'file-names', 'busy', 'busy-nested', 'busy-second', 'race-worker', 'idle-process', 'configured-worker', 'inactive', 'empty-root', 'tmp-retention', 'tmp-root-config', 'entry-symlink', 'nested-symlink', 'freeze-fail', 'thaw-fail', 'not-frozen', 'state-fail', 'unknown-state', 'proc-missing', 'cgroup-traversal', 'root-symlink', 'parent-symlink', 'root-missing', 'root-dotdot')
CONFIG_CASES = ('empty', 'empty-object', 'duplicate', 'nul-path', 'overlap', 'unknown-key', 'zero', 'nonnumeric', 'negative', 'fraction', 'artifact-zero', 'config-path-empty', 'missing', 'unit-newline', 'worker-newline', 'unit-duplicate', 'relative-root', 'repo-traversal', 'lock-inside-root')
ARTIFACT_CASES = ('artifact-age', 'artifact-retention', 'artifact-root-config', 'artifact-env')
INSTALL_CASES = ('install-clean', 'install-euid', 'install-invalid-config', 'install-reload-fail', 'install-enable-fail', 'verify-clean', 'verify-not-installed', 'artifacts-common')
CASES = (['defaults', 'units', 'readme', 'lock-busy'] + list(TMP_CASES) + ['config-' + c for c in CONFIG_CASES] + list(ARTIFACT_CASES) + list(INSTALL_CASES)
         + ['source-missing:' + p for p in FILES] + ['verify-drift:' + p for p in FILES] + ['verify-missing:' + p for p in FILES]
         + ['verify-partial:' + p for p in FILES if p != 'root/ci-artifacts-clean'])


def cell(source, overlay, name):
    try:
        if name == 'defaults': defaults_case(source, overlay)
        elif name == 'units': units_case(source, overlay)
        elif name == 'readme': readme_case(source, overlay)
        elif name == 'lock-busy': lock_case(source, overlay)
        elif name.startswith('config-'): config_case(source, overlay, name.removeprefix('config-'))
        elif name in TMP_CASES: clean_case(source, overlay, name)
        elif name in ARTIFACT_CASES: artifact_case(source, overlay, name)
        else: installer_case(source, overlay, name)
        return True, ''
    except (AssertionError, FileNotFoundError) as exc:
        return False, str(exc)


def catalog():
    data = json.loads((HERE / 'source.json').read_text())
    check(data['kletki'] == CASES, 'CATALOG_CASES')
    for rel, digest in data['nositeli'].items():
        check(hashlib.sha256((HERE / rel).read_bytes()).hexdigest() == digest, 'ORACLE_TAMPERED ' + rel)
    check(bool(data['stab_vhod']) and bool(data['nositeli']), 'CATALOG_EMPTY')
    return data


def suite(source, overlay=None, names=CASES):
    red = 0
    for name in names:
        ok, reason = cell(source, overlay, name)
        print(f'{name}: ' + ('OK' if ok else 'KRASNO ' + reason), flush=True)
        red += not ok
    print(f'ИТОГ 225: KLETKI={len(names)} KRASNYH={red}', flush=True)
    return int(red != 0)


def syntax():
    paths = list((HERE / 'model').rglob('*')) + list((HERE / 'stabs').rglob('*')) + [HERE / 'red_ci_clean_225.sh', HERE / 'shims/systemctl.py', HERE / 'probe.py', HERE / 'build.py']
    count = 0
    for path in paths:
        if not path.is_file(): continue
        if path.suffix == '.py':
            compile(path.read_bytes(), str(path), 'exec')
            count += 1
        elif path.read_bytes().startswith(b'#!/usr/bin/env bash'):
            subprocess.run(['bash', '-n', str(path)], check=True)
            if 'stabs' not in path.parts:
                subprocess.run(['bash', str(REPO / 'scripts/validate_std.sh'), 'bash', str(path)], check=True)
            count += 1
    import jsonschema
    schema = json.loads((MODEL / 'ci-clean.schema.json').read_text())
    jsonschema.Draft202012Validator.check_schema(schema)
    jsonschema.Draft202012Validator(schema).validate(json.loads((MODEL / 'ci-clean.json').read_text()))
    print(f'SINTAKSIS={count} JSON_SCHEMA=0')
    return 0


def main():
    args = sys.argv[1:]
    try:
        data = catalog()
        if args == ['--catalog']:
            print(f'KLETKI={len(CASES)} STABY={len(set(row[0] for row in data["stab_vhod"]))} SVJAZI={len(data["stab_vhod"])} NOSITELI={len(data["nositeli"])}')
            return 0
        if args == ['--sintaksis']: return syntax()
        if args == ['--model']: return suite(MODEL)
        if args == ['--stabs']:
            for path in (HERE / 'stabs').rglob('*'):
                if not path.is_file(): continue
                if path.suffix == '.py':
                    compile(path.read_bytes(), str(path), 'exec')
                elif path.read_bytes().startswith(b'#!/usr/bin/env bash'):
                    subprocess.run(['bash', '-n', str(path)], check=True)
            if suite(MODEL): return 2
            live = 0
            for stab, name in data['stab_vhod']:
                ok, reason = cell(MODEL, HERE / 'stabs' / stab, name)
                print(f'{stab} {name}: ' + ('ZHIV' if ok else 'POIMAN ' + reason), flush=True)
                live += ok
            print(f'STABY={len(set(row[0] for row in data["stab_vhod"]))} SVJAZI={len(data["stab_vhod"])} ZHIVYH={live}')
            return int(live != 0)
        if not args: return suite(REPO / 'ops/server')
        if len(args) == 2 and args[0] == '--repo':
            source = Path(args[1]).resolve() / 'ops/server'
            if not source.is_dir(): raise BadWorld('NOT_IMPLEMENTED repository')
            return suite(source)
        raise BadWorld('NOT_IMPLEMENTED usage')
    except (BadWorld, ImportError, subprocess.CalledProcessError, subprocess.TimeoutExpired, ValueError, AssertionError) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
