#!/usr/bin/env python3
"""Единственный реестр адресных мутаций и генератор каталога 225 (Н-39)."""
import hashlib
import json
from pathlib import Path
import sys

sys.dont_write_bytecode = True
from probe import CASES, FILES

HERE = Path(__file__).resolve().parent
HELPER = 'root/ci-clean.py'
INSTALL = 'install-ci-clean.sh'
# Имя, файл, уникальная замена, предъявления. Отдельный зачёт каждой связи.
MUTATIONS = [
    ('s01-tmp-hardcoded', HELPER, "cutoff = time.time() - conf['retention_days'] * 86400", 'cutoff = time.time() - 2 * 86400', ['tmp-retention']),
    ('s02-artifact-hardcoded', HELPER, "int(days) * 86400", '2 * 86400', ['artifact-retention', 'artifact-env']),
    ('s03-first-root-only', HELPER, "for runner, root in zip(conf['runners'], roots):", "for runner, root in zip(conf['runners'][:1], roots[:1]):", ['second-root']),
    ('s04-top-mtime', HELPER, 'return any(young(Path(c.path), cutoff) for c in children)', 'return False', ['young-inside']),
    ('s05-no-busy', HELPER, "if name in conf['worker_names']:", 'if False:', ['busy', 'busy-second', 'race-worker']),
    ('s06-no-freeze', HELPER, "                ctl(conf, 'freeze', unit)", '                pass', ['old-young']),
    ('s07-no-thaw', HELPER, '            if thaw:', '            if False:', ['old-young', 'busy', 'freeze-fail']),
    ('s08-top-cgroup', HELPER, 'for parent, dirs, files in os.walk(group, followlinks=False, onerror=unavailable):', 'for parent, dirs, files in [(str(group), [], [])]:', ['busy-nested']),
    ('s09-worker-hardcoded', HELPER, "if name in conf['worker_names']:", "if name == 'Runner.Worker':", ['configured-worker']),
    ('s10-skip-schema', HELPER, 'jsonschema.Draft202012Validator(schema).validate(cfg)', 'pass', ['config-zero', 'config-nonnumeric', 'config-unknown-key']),
    ('s11-dotdot', HELPER, "or '..' in p.parts", 'or False', ['root-dotdot']),
    ('s12-symlink-root', HELPER, 'if parent.is_symlink():', 'if False:', ['root-symlink', 'parent-symlink']),
    ('s13-symlink-entry', HELPER, '                if entry.is_symlink():', '                if False:', ['entry-symlink']),
    ('s14-no-frozen-ack', HELPER, "if 'frozen 1' not in (group / 'cgroup.events').read_text().splitlines():", 'if False:', ['not-frozen']),
    ('s15-inactive-on-unknown', HELPER, "elif active not in ('inactive', 'failed'):", 'elif False:', ['unknown-state']),
    ('s16-ignore-freeze-error', HELPER, "    if proc.returncode:", "    if proc.returncode and args[0] != 'freeze':", ['freeze-fail']),
    ('s17-no-root-config', HELPER, "roots = [directory(r['root']) for r in conf['runners']]", "roots = [directory(str(Path(conf['proc_root']).parent / leaf)) for leaf in ('runner one', 'runner two')]", ['tmp-root-config']),
    ('s18-artifact-root-ignored', HELPER, "os.environ.get('CI_ARTIFACTS_ROOT') or conf['root']", "str(Path(cfg['tmp']['proc_root']).parent / 'artifacts')", ['artifact-root-config']),
    ('s19-no-euid', INSTALL, '[ "$(id -u)" -eq 0 ] ||', 'true ||', ['install-euid']),
    ('s20-no-validation', INSTALL, '    validate_config || exit $?', '    :', ['install-invalid-config']),
    ('s21-no-owner', INSTALL, ' && chown root:root -- "$dst"', '', ['install-clean']),
    ('s22-no-mode', INSTALL, ' && chmod "$mode" -- "$dst"', '', ['install-clean']),
    ('s23-no-enable', INSTALL, '    "$CTL" enable --now ci-runner-tmp-clean.timer ||', '    true ||', ['install-clean']),
    ('s24-no-reload', INSTALL, '    "$CTL" daemon-reload ||', '    true ||', ['install-clean']),
    ('s25-swallow-reload', INSTALL, "printf 'ОТКАЗ: systemctl daemon-reload\\n' >&2; exit 1;", "printf 'ОТКАЗ: systemctl daemon-reload\\n' >&2;", ['install-reload-fail']),
    ('s26-swallow-enable', INSTALL, "printf 'ОТКАЗ: systemctl enable\\n' >&2; exit 1;", "printf 'ОТКАЗ: systemctl enable\\n' >&2;", ['install-enable-fail']),
    ('s27-no-persistent', 'root/systemd/ci-runner-tmp-clean.timer', 'Persistent=true', 'Persistent=false', ['units']),
    ('s35-no-lock', HELPER, 'fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)', 'pass', ['lock-busy']),
    ('s36-no-readme', 'README.md', '## Очистка CI (контракт 225)', '## Иной раздел', ['readme']),
    ('s37-artifacts-no-common', INSTALL, 'FILES="root/ci-artifacts-clean $COMMON"', 'FILES="root/ci-artifacts-clean"', ['artifacts-common']),
    ('s38-optional-false-red', INSTALL, 'if [ "$present" -eq 0 ]; then', 'if [ "$present" -eq 0 ]; then exit 1;', ['verify-not-installed']),
    ('s39-common-partial', INSTALL, '      FILES="$COMMON"', "      FILES=''", ['verify-partial:ci-clean.json']),
    ('s40-tmp-partial', INSTALL, 'if [ "$present" -eq 0 ]; then', 'if [ "$present" -lt 4 ]; then', ['verify-partial:root/ci-runner-tmp-clean']),
    ('s41-unit-terminator', 'ci-clean.schema.json', r'\\.service$(?![\\s\\S])', r'\\.service$', ['config-unit-newline']),
    ('s42-name-terminator', 'ci-clean.schema.json', r'^[A-Za-z0-9][A-Za-z0-9._-]*$(?![\\s\\S])', r'^[A-Za-z0-9][A-Za-z0-9._-]*$', ['config-worker-newline']),
    ('s43-walk-ignore-errors', HELPER, 'followlinks=False, onerror=unavailable', 'followlinks=False', ['cgroup-child-unreadable', 'cgroup-parent-unreadable', 'cgroup-readdir-error']),
    ('s44-empty-days', HELPER, "os.environ.get('CI_ARTIFACTS_RETENTION_DAYS') or str(conf['retention_days'])", "os.environ.get('CI_ARTIFACTS_RETENTION_DAYS', str(conf['retention_days']))", ['env-empty-days', 'env-empty-all']),
    ('s45-empty-root', HELPER, "os.environ.get('CI_ARTIFACTS_ROOT') or conf['root']", "os.environ.get('CI_ARTIFACTS_ROOT', conf['root'])", ['env-empty-root', 'env-empty-all']),
    ('s46-empty-repos', HELPER, "os.environ.get('CI_ARTIFACTS_REPOS') or ' '.join(conf['repos'])", "os.environ.get('CI_ARTIFACTS_REPOS', ' '.join(conf['repos']))", ['env-empty-repos', 'env-empty-all']),
    ('s47-stat-ignore-error', HELPER, '(Path(parent) / child).lstat().st_mode', '0', ['cgroup-stat-error']),
    ('s48-early-worker-return', HELPER, '                    present = True', '                    return True', ['cgroup-busy-unreadable']),
]
# Поадресные мутации шага сверки: не усредняем файлы/два типа дефекта.
for index, rel in enumerate(FILES):
    needle = '      check_one "$dst" "$SRC_ROOT/$rel" || rc=1'
    replacement = f'      if [ "$rel" != "{rel}" ]; then check_one "$dst" "$SRC_ROOT/$rel" || rc=1; fi'
    MUTATIONS.append((f's{28 + index:02}-blind-file', INSTALL, needle, replacement,
                      ['verify-drift:' + rel, 'verify-missing:' + rel]))


def main():
    links = []
    for name, rel, needle, replacement, cases in MUTATIONS:
        source = (HERE / 'model' / rel).read_text()
        if source.count(needle) != 1:
            raise SystemExit('STAB_ANCHOR ' + name + ': ' + str(source.count(needle)))
        path = HERE / 'stabs' / name / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source.replace(needle, replacement))
        for case in cases:
            if case not in CASES: raise SystemExit('UNKNOWN_CASE ' + case)
            links.append([name, case])
    paths = sorted(p for directory in ('model', 'stabs', 'shims') for p in (HERE / directory).rglob('*') if p.is_file())
    paths += [HERE / 'probe.py', HERE / 'build.py', HERE / 'red_ci_clean_225.sh']
    payload = {'base': 'e7f2e9dab64b83a1226f63ab89f9c3b8abed19f5', 'kletki': CASES, 'stab_vhod': links,
               'nositeli': {str(p.relative_to(HERE)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}
    (HERE / 'source.json').write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n')
    print(f'KLETKI={len(CASES)} STABY={len(MUTATIONS)} SVJAZI={len(links)} NOSITELI={len(paths)}')


if __name__ == '__main__':
    main()
