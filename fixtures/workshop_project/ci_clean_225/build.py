#!/usr/bin/env python3
"""Единственный реестр адресных мутаций и генератор каталога 225 (Н-39)."""
import hashlib
import json
from pathlib import Path
import sys
import subprocess

sys.dont_write_bytecode = True
from probe import CASES, FILES

HERE = Path(__file__).resolve().parent
HELPER = 'root/ci-clean.py'
INSTALL = 'install-ci-clean.sh'
ARTIFACTS = 'root/ci-artifacts-clean'
LEGACY_BLOB = 'b81b1e105d4daea14eea66539475ee9c519b0c6a'


def artifact_source():
    source = subprocess.check_output(['git', 'show', 'done/contracts/196/1:ops/server/root/ci-artifacts-clean'])
    digest = hashlib.sha1(b'blob ' + str(len(source)).encode() + b'\0' + source).hexdigest()
    if digest != LEGACY_BLOB:
        raise SystemExit('LEGACY_BLOB_CHANGED')
    bootstrap = """HERE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mapfile -d '' -t CI_DEFAULTS < <(python3 "$HERE/ci-clean.py" artifacts; printf '%s\\0' "$?")
rc="${CI_DEFAULTS[-1]}"
[ "$rc" -eq 0 ] || exit "$rc"
[ "${#CI_DEFAULTS[@]}" -eq 4 ] || exit 2
"""
    text = source.decode()
    text = text.replace('set -u\n', 'set -u\n\n' + bootstrap, 1)
    for old, new in (('/var/lib/ci-artifacts', '${CI_DEFAULTS[0]}'),
                     ('14}', '${CI_DEFAULTS[1]}}'),
                     ('Complior-mob Complior-back}', '${CI_DEFAULTS[2]}}')):
        # Only the three assignment lines change; comments remain the frozen text.
        lines = text.splitlines(keepends=True)
        text = ''.join(line.replace(old, new) if line.startswith(('ROOT_ENV=', 'RET_ENV=', 'REPOS_ENV=')) else line
                       for line in lines)
    return text

# Имя, файл, уникальная замена, предъявления. Отдельный зачёт каждой связи.
MUTATIONS = [
    ('s01-tmp-hardcoded', HELPER, "cutoff = time.time() - conf['retention_days'] * 86400", 'cutoff = time.time() - 2 * 86400', ['tmp-retention']),
    ('s02-artifact-hardcoded', ARTIFACTS, 'RET_ENV="${CI_ARTIFACTS_RETENTION_DAYS:-${CI_DEFAULTS[1]}}"', 'RET_ENV=2', ['artifact-retention', 'artifact-env']),
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
    ('s18-artifact-root-ignored', HELPER, "conf['root'], str(conf['retention_days'])", "str(Path(cfg['tmp']['proc_root']).parent / 'artifacts'), str(conf['retention_days'])", ['artifact-root-config']),
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
    ('s44-empty-days', ARTIFACTS, '${CI_ARTIFACTS_RETENTION_DAYS:-', '${CI_ARTIFACTS_RETENTION_DAYS-', ['env-empty-days', 'env-empty-all']),
    ('s45-empty-root', ARTIFACTS, '${CI_ARTIFACTS_ROOT:-', '${CI_ARTIFACTS_ROOT-', ['env-empty-root', 'env-empty-all']),
    ('s46-empty-repos', ARTIFACTS, '${CI_ARTIFACTS_REPOS:-', '${CI_ARTIFACTS_REPOS-', ['env-empty-repos', 'env-empty-all']),
    ('s47-stat-ignore-error', HELPER, '(Path(parent) / child).lstat().st_mode', '0', ['cgroup-stat-error']),
    ('s48-early-worker-return', HELPER, '                    present = True', '                    return True', ['cgroup-busy-unreadable']),
    ('s49-zero-repos-refusal', ARTIFACTS, "case \"$REPOS\" in\n  ' ')", "case \"$REPOS\" in\n  ''|' ')", ['grid-zero-0']),
    ('s50-zero-repos-fallback', ARTIFACTS, "case \"$REPOS\" in", '[ -n "$REPOS" ] || REPOS="${CI_DEFAULTS[2]}"\ncase "$REPOS" in', ['grid-zero-0']),
    ('s51-unicode-split', ARTIFACTS, "REPOS=''", """REPOS_ENV="$(python3 -c 'import sys; print(" ".join(sys.argv[1].split()))' "$REPOS_ENV")"
REPOS=''""", ['grid-nonbash-0', 'grid-nonbash-1']),
    ('s52-trim-days', ARTIFACTS, 'case "$RET_ENV" in', """RET_ENV="$(python3 -c 'import sys; print(sys.argv[1].strip())' "$RET_ENV")"
case "$RET_ENV" in""", ['grid-days-12']),
    ('s53-trim-root', ARTIFACTS, 'if [ -L "$ROOT_ENV" ]', """ROOT_ENV="$(python3 -c 'import sys; print(sys.argv[1].strip())' "$ROOT_ENV")"
if [ -L "$ROOT_ENV" ]""", ['grid-root-2']),
    ('s54-canonical-env-root', ARTIFACTS, 'if [ -L "$ROOT_ENV" ]', """if [[ "$ROOT_ENV" != /* || "$ROOT_ENV" == */ || "$ROOT_ENV" == *"/../"* ]]; then
  printf 'ОТКАЗ: корень не каталог: %s\\n' "$ROOT_ENV" >&2; exit 1
fi
if [ -L "$ROOT_ENV" ]""", ['grid-root-3', 'grid-root-4', 'grid-root-5']),
    ('s55-delete-young-v1', HELPER, 'if entry.lstat().st_mtime >= cutoff:', 'if False and entry.lstat().st_mtime >= cutoff:', ['old-young']),
    ('s56-worker-second-v1', HELPER, 'if worker_present(conf, group):', "if unit != 'toy-b.service' and worker_present(conf, group):", ['busy-second']),
    ('s57-thaw-after-freeze-v1', HELPER, "                thaw = True\n                ctl(conf, 'freeze', unit)", "                thaw = False\n                ctl(conf, 'freeze', unit)\n                thaw = True", ['freeze-fail']),
    ('s58-one-day-v1', HELPER, "cutoff = time.time() - conf['retention_days'] * 86400", 'cutoff = time.time() - 86400', ['tmp-retention']),
    ('s59-error-busy-v2', HELPER, '    except OSError as exc:\n        unavailable(exc)', '    except OSError as exc:\n        return True', ['cgroup-procs-unreadable', 'proc-comm-unreadable', 'cgroup-stat-error']),
]
# Поадресные мутации шага сверки: не усредняем файлы/два типа дефекта.
for index, rel in enumerate(FILES):
    needle = '      check_one "$dst" "$SRC_ROOT/$rel" || rc=1'
    replacement = f'      if [ "$rel" != "{rel}" ]; then check_one "$dst" "$SRC_ROOT/$rel" || rc=1; fi'
    MUTATIONS.append((f's{28 + index:02}-blind-file', INSTALL, needle, replacement,
                      ['verify-drift:' + rel, 'verify-missing:' + rel]))


def main():
    (HERE / 'model' / ARTIFACTS).write_text(artifact_source())
    links = []
    for name, rel, needle, replacement, cases in MUTATIONS:
        source = (HERE / 'model' / rel).read_text()
        if source.count(needle) != 1:
            raise SystemExit('STAB_ANCHOR ' + name + ': ' + str(source.count(needle)))
        path = HERE / 'stabs' / name / rel
        for stale in (HERE / 'stabs' / name).rglob('*'):
            if stale.is_file() and stale != path:
                stale.unlink()
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(source.replace(needle, replacement))
        for case in cases:
            if case not in CASES: raise SystemExit('UNKNOWN_CASE ' + case)
            links.append([name, case])
    paths = sorted(p for directory in ('model', 'stabs', 'shims') for p in (HERE / directory).rglob('*') if p.is_file())
    paths += [HERE / name for name in ('probe.py', 'env_grid.py', 'build.py', 'red_ci_clean_225.sh')]
    payload = {'base': 'e7f2e9dab64b83a1226f63ab89f9c3b8abed19f5', 'kletki': CASES, 'stab_vhod': links,
               'nositeli': {str(p.relative_to(HERE)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}}
    (HERE / 'source.json').write_text(json.dumps(payload, ensure_ascii=False, indent=2) + '\n')
    print(f'KLETKI={len(CASES)} STABY={len(MUTATIONS)} SVJAZI={len(links)} NOSITELI={len(paths)}')


if __name__ == '__main__':
    main()
