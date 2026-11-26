#!/usr/bin/env python3
"""Исполнительная модель 225. Не production; публичные входы — два bash CLI."""
from contextlib import contextmanager
import fcntl
import json
import os
from pathlib import Path
import re
import shutil
import signal
import stat
import subprocess
import sys
import time


class Refusal(Exception):
    pass


def refuse(reason):
    raise Refusal(reason)


def pairs(items):
    result = {}
    for key, value in items:
        if key in result:
            refuse('CONFIG_INVALID duplicate key')
        result[key] = value
    return result


def canonical(value):
    p = Path(value)
    if (not p.is_absolute() or str(p) != value or '..' in p.parts
            or '\x00' in value or '\n' in value or '\r' in value or p == Path('/')):
        refuse('CONFIG_INVALID path')
    return p


def directory(value):
    p = canonical(value)
    for parent in (*reversed(p.parents), p):
        if parent.is_symlink():
            refuse(f'ROOT_INVALID {p}')
    if not p.is_dir():
        refuse(f'ROOT_INVALID {p}')
    return p


def configuration():
    here = Path(__file__).resolve().parent
    try:
        import jsonschema
    except ImportError:
        print('NOT_IMPLEMENTED: jsonschema', file=sys.stderr)
        sys.exit(2)
    try:
        cfg = json.loads(Path(os.environ.get('CI_CLEAN_CONFIG', str(here / 'ci-clean.json'))).read_text(), object_pairs_hook=pairs)
        schema = json.loads(Path(os.environ.get('CI_CLEAN_SCHEMA', str(here / 'ci-clean.schema.json'))).read_text())
        jsonschema.Draft202012Validator.check_schema(schema)
        jsonschema.Draft202012Validator(schema).validate(cfg)
        paths = [cfg['artifacts']['root']] + [r['root'] for r in cfg['tmp']['runners']]
        canonical(cfg['tmp']['proc_root'])
        canonical(cfg['tmp']['cgroup_root'])
        lock = canonical(cfg['tmp']['lock_path'])
        if any(Path(value) == lock or Path(value) in lock.parents for value in paths):
            refuse('CONFIG_INVALID lock inside cleanup root')
        for value in paths:
            canonical(value)
        for i, value in enumerate(paths):
            for other in paths[i + 1:]:
                a, b = Path(value), Path(other)
                if a == b or a in b.parents or b in a.parents:
                    refuse('CONFIG_INVALID overlapping roots')
        if any(name in ('.', '..') for name in cfg['artifacts']['repos']):
            refuse('CONFIG_INVALID repo')
        units = [r['unit'] for r in cfg['tmp']['runners']]
        if len(set(units)) != len(units):
            refuse('CONFIG_INVALID duplicate unit')
        return cfg
    except Refusal:
        raise
    except (OSError, ValueError, TypeError, jsonschema.exceptions.ValidationError,
            jsonschema.exceptions.SchemaError) as exc:
        refuse(f'CONFIG_INVALID {type(exc).__name__}')


def young(entry, cutoff):
    if entry.lstat().st_mtime >= cutoff:
        return True
    if entry.is_dir() and not entry.is_symlink():
        with os.scandir(entry) as children:
            return any(young(Path(c.path), cutoff) for c in children)
    return False


def remove(entry):
    if entry.is_dir():
        shutil.rmtree(entry)
    else:
        entry.unlink()
    print(f'удалено: {entry}')


def artifacts(cfg):
    conf = cfg['artifacts']
    days = os.environ.get('CI_ARTIFACTS_RETENTION_DAYS') or str(conf['retention_days'])
    if not re.fullmatch(r'[0-9]+', days) or int(days) < 1:
        refuse(f'срок не целое ≥1: {days}')
    repos = (os.environ.get('CI_ARTIFACTS_REPOS') or ' '.join(conf['repos'])).split()
    if not repos:
        refuse('список репо пуст')
    for repo in repos:
        if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9._-]*', repo) or repo in ('.', '..'):
            refuse(f'недопустимое имя репо: {repo}')
    root_value = os.environ.get('CI_ARTIFACTS_ROOT', conf['root'])
    try:
        root = directory(root_value)
    except Refusal:
        refuse(f'корень не каталог: {root_value}')
    cutoff = time.time() - int(days) * 86400
    refused = False
    for repo in repos:
        parent = root / repo
        if not parent.exists() and not parent.is_symlink():
            continue
        if parent.is_symlink() or not parent.is_dir():
            print(f'ОТКАЗ: репо не каталог: {parent}', file=sys.stderr)
            refused = True
            continue
        deleted = kept = 0
        for entry in sorted(parent.iterdir()):
            reason = None
            if not re.fullmatch(r'[0-9]+-[0-9]+', entry.name):
                reason = 'имя прогона вне грамматики <число>-<число>'
            elif entry.is_symlink():
                reason = 'прогон — символьная ссылка'
            elif not entry.is_dir():
                reason = 'прогон не каталог'
            if reason:
                print(f'ОТКАЗ: {reason}: {entry}', file=sys.stderr)
                refused = True
            elif young(entry, cutoff):
                kept += 1
            else:
                remove(entry)
                deleted += 1
        print(f'ci-artifacts: репо {repo}: удалено {deleted}, хранится {kept}')
    return int(refused)


def ctl(conf, *args):
    try:
        proc = subprocess.run([conf['systemctl'], *args], check=False,
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    except OSError:
        refuse('RUNNER_STATE_UNAVAILABLE')
    if proc.returncode:
        refuse(f'RUNNER_CTL_FAILED {args[0]}')
    return proc.stdout


def worker_present(conf, group):
    def unavailable(exc):
        refuse(f'RUNNER_STATE_UNAVAILABLE {exc}')

    present = False
    try:
        proc = directory(conf['proc_root'])
        for parent, dirs, files in os.walk(group, followlinks=False, onerror=unavailable):
            # os.walk may suppress DirEntry.is_dir errors and classify the entry
            # as a file. Explicit lstat keeps such a partial view fail-closed.
            for child in dirs + files:
                if stat.S_ISLNK((Path(parent) / child).lstat().st_mode):
                    refuse('RUNNER_STATE_UNAVAILABLE symlink cgroup')
            for pid in (Path(parent) / 'cgroup.procs').read_text().splitlines():
                if not re.fullmatch(r'[1-9][0-9]*', pid):
                    refuse('RUNNER_STATE_UNAVAILABLE pid')
                name = (proc / pid / 'comm').read_text().removesuffix('\n')
                if name in conf['worker_names']:
                    present = True
    except OSError as exc:
        unavailable(exc)
    return present


@contextmanager
def lock(conf):
    directory(str(Path(conf['lock_path']).parent))
    fd = os.open(conf['lock_path'], os.O_CREAT | os.O_RDWR | os.O_NOFOLLOW, 0o600)
    try:
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            refuse('CLEAN_BUSY')
        yield
    finally:
        os.close(fd)


def tmp(cfg):
    conf = cfg['tmp']
    # Все корни проверены до первой очистки. Нет создания отсутствующих корней.
    roots = [directory(r['root']) for r in conf['runners']]
    cutoff = time.time() - conf['retention_days'] * 86400
    result = 0
    for runner, root in zip(conf['runners'], roots):
        thaw = False
        unit = runner['unit']
        try:
            state = {}
            for row in ctl(conf, 'show', unit, '--property=ActiveState', '--property=ControlGroup').splitlines():
                key, sep, value = row.partition('=')
                if not sep or key in state:
                    refuse('RUNNER_STATE_UNAVAILABLE show')
                state[key] = value
            active = state.get('ActiveState')
            if active == 'active':
                cgroup = state.get('ControlGroup', '')
                if not cgroup.startswith('/') or cgroup == '/' or '..' in Path(cgroup).parts:
                    refuse('RUNNER_STATE_UNAVAILABLE cgroup')
                group = directory(str(directory(conf['cgroup_root']) / cgroup.lstrip('/')))
                # Thaw даже после неуспешной/частично выполненной freeze.
                thaw = True
                ctl(conf, 'freeze', unit)
                if 'frozen 1' not in (group / 'cgroup.events').read_text().splitlines():
                    refuse('RUNNER_NOT_FROZEN')
                if worker_present(conf, group):
                    print(f'ci-tmp: BUSY {unit}')
                    continue
            elif active not in ('inactive', 'failed'):
                refuse('RUNNER_STATE_UNAVAILABLE ActiveState')
            deleted = kept = 0
            for entry in sorted(root.iterdir()):
                if entry.is_symlink():
                    print(f'ОТКАЗ: TMP_SYMLINK {entry}', file=sys.stderr)
                    result = 1
                    continue
                if young(entry, cutoff):
                    kept += 1
                else:
                    remove(entry)
                    deleted += 1
            print(f'ci-tmp: {unit}: удалено {deleted}, хранится {kept}')
        except (Refusal, OSError) as exc:
            print(f'ОТКАЗ: {exc}', file=sys.stderr)
            result = 1
        finally:
            if thaw:
                try:
                    ctl(conf, 'thaw', unit)
                except Refusal:
                    print(f'ОТКАЗ: THAW_FAILED {unit}', file=sys.stderr)
                    result = 1
    return result


def interrupted(signum, _frame):
    raise Refusal(f'INTERRUPTED {signum}')


def main():
    if len(sys.argv) != 2 or sys.argv[1] not in ('check', 'artifacts', 'tmp'):
        print('ОТКАЗ: USAGE ci-clean.py check|artifacts|tmp', file=sys.stderr)
        return 1
    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)
    try:
        cfg = configuration()
        if sys.argv[1] == 'tmp':
            with lock(cfg['tmp']):
                return tmp(cfg)
        return 0 if sys.argv[1] == 'check' else globals()[sys.argv[1]](cfg)
    except (Refusal, OSError, OverflowError) as exc:
        print(f'ОТКАЗ: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
