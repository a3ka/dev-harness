#!/usr/bin/env python3
"""221: CLI/commit seam in real Git worlds; expectations stay in memory."""
import argparse
import hashlib
import json
import os
import random
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
CASES = ('p01-no-hook', 'p02-foreign-config', 'p03-empty-config', 'p04-email-only',
         'p05-foreign-env', 'p06-disabled-config-hook', 'p07-live-door-refusal',
         'p08-repeat', 'p09-no-verify-argument', 'p10-not-repository',
         'p11-multivalue-config', 'p12-user-family-config',
         's01-live-hook', 's02-no-hook', 's03-foreign-config', 's04-repeat',
         's05-live-door-refusal')
ENV = {k: v for k, v in os.environ.items()
       if not k.startswith(('GIT_', 'HARNESS_'))}
ENV.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
           GIT_AUTHOR_DATE='2026-11-24T00:00:00+0000',
           GIT_COMMITTER_DATE='2026-11-24T00:00:00+0000',
           PYTHONDONTWRITEBYTECODE='1', LC_ALL='C.UTF-8')


def run(cmd, cwd=None, env=None):
    return subprocess.run(list(map(str, cmd)), cwd=cwd, env=env or ENV,
                          capture_output=True, timeout=90)


def checked(cmd, cwd=None):
    result = run(cmd, cwd)
    if result.returncode:
        raise RuntimeError('COMMAND rc=' + str(result.returncode) + ': ' + repr(cmd) + ': ' + repr(result.stdout + result.stderr))
    return result.stdout


class World:
    def __init__(self, root, tools, case):
        self.root, self.tools, self.case = root, tools, case
        self.project = case.startswith('p')
        self.n = '%03d' % random.SystemRandom().randrange(880, 940)
        self.registry = '.harness/registry/contracts.tsv' if self.project else 'registry/contracts.tsv'
        # Existing door 031 still reads remote registry/contracts.tsv literally.
        # Use a conforming root-registry project for the refusal seam; changing
        # that independent project-path defect is not subject 221.
        if case == 'p07-live-door-refusal':
            self.registry = 'registry/contracts.tsv'
        if case == 'p03-empty-config':
            self.registry = '.workflow/book/contracts.tsv'
        # p12: positive mint on the root-registry layout (same shape as the
        # refusal seam p07) — door 031 reads HEAD/origin manifests literally,
        # so dual-control runs fully live here.
        if case == 'p12-user-family-config':
            self.registry = 'registry/contracts.tsv'
        self.contracts = '.harness/contracts' if self.project else 'contracts'
        root.mkdir()
        self.git('init', '-q', '-b', 'main')
        for directory in (self.contracts, str(Path(self.registry).parent), '.harness/verdicts', '.harness/fixtures'):
            (root / directory).mkdir(parents=True, exist_ok=True)
        (root / self.contracts / '001-world.md').write_text(
            '# 001\n\n## Предмет\nworld\n\nЗОНА orchestrator: HANDOFF.md\n')
        (root / 'HANDOFF.md').write_text('world\n')
        if self.project:
            (root / '.harness/project-layer.json').write_text(json.dumps({
                'schemaVersion': 1, 'version': '1', 'projectId': 'world221',
                'workspaceId': 'world221', 'defaults': {}}))
            (root / 'harness.project.json').write_text(json.dumps({
                'schemaVersion': 1, 'repoId': 'product221', 'language': 'bash',
                'projectLayer': {'version': '1', 'profilePath': '.harness/project-layer.json'},
                'workflowPaths': {'contracts': self.contracts, 'verdicts': '.harness/verdicts',
                                  'registry': str(Path(self.registry).parent), 'fixtures': '.harness/fixtures'}}))
        self.g('add', '-A')
        self.g('commit', '-q', '-m', 'world')
        self.file.write_text('000 → ' + self.rev('HEAD') + '\n')
        self.g('add', '-A')
        self.g('commit', '-q', '-m', 'registry')
        self.g('tag', '-a', 'frozen/contracts/001/1', '-m', 'frozen')
        self.origin = root.parent / 'origin.git'
        checked(['git', 'init', '-q', '--bare', self.origin])
        checked(['git', '-C', self.origin, 'symbolic-ref', 'HEAD', 'refs/heads/main'])
        self.git('remote', 'add', 'origin', str(self.origin))
        self.g('push', '-q', 'origin', 'main', 'refs/tags/frozen/contracts/001/1')
        self.g('tag', '-a', 'id/CONTRACT/' + self.n, '-m', 'reserved')
        self.g('push', '-q', 'origin', 'refs/tags/id/CONTRACT/' + self.n)
        self.tag = self.rev('refs/tags/id/CONTRACT/' + self.n)
        self.line = (self.n + ' → ' + self.tag + '\n').encode()
        if case in ('p08-repeat', 's04-repeat'):
            self.file.write_bytes(self.file.read_bytes() + self.line)
            self.g('add', '-A')
            self.g('commit', '-q', '-m', 'already minted')
            self.g('push', '-q', 'origin', 'main')
        if case in ('p07-live-door-refusal', 's05-live-door-refusal'):
            before = self.rev('HEAD')
            self.file.write_bytes(self.file.read_bytes() + self.line)
            self.g('add', '-A')
            self.g('commit', '-q', '-m', 'remote raced')
            self.g('push', '-q', 'origin', 'main')
            self.g('reset', '--hard', before)
        if not self.project and case != 's02-no-hook':
            hook = root / '.git/hooks/pre-commit'
            hook.write_text('#!/usr/bin/env bash\nexec bash ' + str(tools / 'scripts/check_staged.sh') + ' ' + str(root) + '\n')
            hook.chmod(0o755)
        if case in ('p02-foreign-config', 's03-foreign-config'):
            self.git('config', 'user.name', 'foreign-person')
            self.git('config', 'user.email', 'foreign@example.invalid')
        if case == 'p03-empty-config':
            self.git('config', 'user.name', '')
            self.git('config', 'user.email', '')
        if case == 'p04-email-only':
            self.git('config', 'user.email', 'foreign@example.invalid')
        if case == 'p11-multivalue-config':
            self.git('config', '--add', 'user.name', 'one')
            self.git('config', '--add', 'user.name', 'two')
            self.git('config', '--add', 'user.email', 'one@example.invalid')
            self.git('config', '--add', 'user.email', 'two@example.invalid')
        # К-09 (Crit221 v1 БЛОК-2): [user]-семейство вне запрещённых ключей —
        # нормализация обязана сохранить их байт-в-байт, удалив только
        # user.name/user.email (инвариант 3).
        if case == 'p12-user-family-config':
            self.git('config', 'user.name', 'foreign-person')
            self.git('config', 'user.email', 'foreign@example.invalid')
            self.git('config', 'user.signingkey', 'ABCDEF0123456789ABCDEF0123456789ABCDEF12')
            self.git('config', 'user.useConfigOnly', 'true')
        if case == 'p06-disabled-config-hook':
            self.git('config', 'core.hooksPath', '/dev/null')
        self.before = self.rev('HEAD')
        self.manifest = self.file.read_bytes()
        self.cfg = (root / '.git/config').read_bytes()
        self.hooks = self.hook_snapshot()
        self.refs = self.git('show-ref').stdout
        self.remote = checked(['git', '-C', self.origin, 'show-ref'])
        self.other_config = [row for row in self.git('config', '--local', '--null', '--list').stdout.split(b'\0')
                             if not row.startswith((b'user.name\n', b'user.email\n'))]

    @property
    def file(self):
        return self.root / self.registry

    def git(self, *args):
        return run(['git', '-C', self.root, *args])

    def g(self, *args):
        return checked(['git', '-C', self.root, '-c', 'core.hooksPath=/dev/null',
                        '-c', 'commit.gpgsign=false', '-c', 'user.name=orchestrator',
                        '-c', 'user.email=orchestrator@dev-harness.local', *args])

    def rev(self, ref):
        return self.git('rev-parse', ref).stdout.decode().strip()

    def hook_snapshot(self):
        hooks = self.root / '.git/hooks'
        return {p.name: (p.read_bytes(), p.stat().st_mode) for p in hooks.iterdir() if p.is_file()}

    def invoke(self, subject):
        scratch = self.root.parent / 'scratch'
        scratch.mkdir(exist_ok=True)
        env = dict(ENV, HARNESS_TOOLS_ROOT=str(self.tools),
                   HARNESS_PROJECT_LAYER_ROOT=str(self.root), TMPDIR=str(scratch))
        if self.case == 'p05-foreign-env':
            env.update(GIT_AUTHOR_NAME='foreign-env', GIT_AUTHOR_EMAIL='env@example.invalid',
                       GIT_COMMITTER_NAME='foreign-env', GIT_COMMITTER_EMAIL='env@example.invalid')
        args = ['bash', subject, '--root', self.root, '--nnn', self.n]
        if self.case == 'p09-no-verify-argument':
            args.append('--no-verify')
        if self.case == 'p10-not-repository':
            outside = self.root.parent / 'not-repo'
            outside.mkdir(exist_ok=True)
            args[3] = outside
        return run(args, self.root, env)

    def observe(self, result):
        head = self.rev('HEAD')
        return (result.returncode, result.stdout, result.stderr, head,
                self.git('status', '--porcelain').stdout, self.file.read_bytes(),
                self.git('show', 'HEAD:' + self.registry).stdout,
                self.git('log', '-1', '--format=%an%n%ae%n%cn%n%ce').stdout,
                (self.root / '.git/config').read_bytes(), self.hook_snapshot(),
                checked(['git', '-C', self.origin, 'show-ref']))

    def restore(self):
        self.g('reset', '--hard', self.before)
        (self.root / '.git/config').write_bytes(self.cfg)

def normalized_config(cfg):
    """Expected local .git/config bytes after honest normalization: only the
    [user] name/email entry lines are removed, every other byte is intact
    (К-09: byte-in-byte preservation of the rest of the configuration)."""
    out, section = [], None
    for line in cfg.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith(b'[') and stripped.endswith(b']'):
            section = stripped
            out.append(line)
        elif section == b'[user]' and stripped.split(b' = ')[0] in (b'name', b'email'):
            continue
        else:
            out.append(line)
    return b''.join(out)


def once_hook_residue(scratch):
    """Leftovers of the SUBJECT's one-time hook in its TMPDIR world (К-08):
    any surviving pre-commit file anywhere under scratch, or any temp catalog
    other than the live door's own lib_zones.* scratch (dir + .active marker —
    a station-tooling leak of check_staged/lib_zones, observed on the honest
    model; not subject 221 and not part of invariant 2)."""
    residue = set()
    if scratch.is_dir():
        for entry in scratch.iterdir():
            if not entry.name.startswith('lib_zones.'):
                residue.add(entry.name)
        for path in scratch.rglob('pre-commit'):
            residue.add(str(path.relative_to(scratch)))
    return sorted(residue)



def cell(tools, candidate, baseline, case, root):
    world = World(root, tools, case)
    if case.startswith('s'):
        expected = world.observe(world.invoke(baseline))
        world.restore()
        observed = world.observe(world.invoke(candidate))
        return observed == expected, 'STATION_BYTE_PARITY ' + repr(observed[:3])
    result = world.invoke(candidate)
    obs = world.observe(result)
    problems = []
    failure = {'p07-live-door-refusal': (1, 'дверь минта 031'),
               'p08-repeat': (1, 'повторный минт'),
               'p09-no-verify-argument': (1, 'неизвестный аргумент: --no-verify'),
               'p10-not-repository': (2, '--root не репозиторий git')}
    if case in failure:
        code, reason = failure[case]
        if result.returncode != code or reason.encode() not in result.stderr:
            problems.append('REFUSAL_REASON')
        if result.stdout or obs[3] != world.before or obs[4] or obs[5] != world.manifest or obs[6] != world.manifest:
            problems.append('REFUSAL_NOT_ATOMIC')
    else:
        if result.returncode != 0:
            problems.append('MINT_RC')
        expected_stdout = ('MINTED nnn=' + world.n + ' sha=' + world.tag + ' commit=' + obs[3] + '\n').encode()
        if result.stdout != expected_stdout:
            problems.append('MINT_STDOUT')
        door = ('judged: ' + world.registry + ' (дверь минта 031: +1 строк ↔ живые dual-control теги)\n'
                'ok: staged в зоне автора orchestrator (1 путь/путей)\n').encode()
        if result.stderr != door:
            problems.append('LIVE_DOOR_OUTPUT')
        if obs[5] != world.manifest + world.line or obs[6] != world.manifest + world.line or obs[4]:
            problems.append('REGISTRY_DELTA')
        if world.git('rev-list', '--count', world.before + '..HEAD').stdout != b'1\n':
            problems.append('COMMIT_COUNT')
        if world.git('diff-tree', '--no-commit-id', '--name-only', '-r', 'HEAD').stdout != (world.registry + '\n').encode():
            problems.append('ONLY_REGISTRY')
        if obs[7] != b'orchestrator\norchestrator@dev-harness.local\norchestrator\norchestrator@dev-harness.local\n':
            problems.append('IDENTITY')
    if case not in ('p09-no-verify-argument', 'p10-not-repository'):
        for key in ('user.name', 'user.email'):
            if world.git('config', '--local', '--get', key).returncode != 1:
                problems.append('FILE_IDENTITY_LEFT')
    remaining_config = [row for row in world.git('config', '--local', '--null', '--list').stdout.split(b'\0')
                        if not row.startswith((b'user.name\n', b'user.email\n'))]
    if case not in ('p09-no-verify-argument', 'p10-not-repository') and remaining_config != world.other_config:
        problems.append('UNRELATED_CONFIG_CHANGED')
    if world.git('config', '--get', 'core.hooksPath').stdout != (b'/dev/null\n' if case == 'p06-disabled-config-hook' else b''):
        problems.append('HOOK_CONFIG_CHANGED')
    if obs[9] != world.hooks or obs[10] != world.remote:
        problems.append('HOOKS_OR_ORIGIN_CHANGED')
    # К-08 (Crit221 v1 БЛОК-1): the one-time hook must be gone on EVERY exit
    # path of a project call — success and door refusal alike. The probe
    # localizes the subject's TMPDIR to <world>/scratch; a surviving
    # pre-commit or a foreign temp catalog there is the un-removed hook.
    residue = once_hook_residue(root.parent / 'scratch')
    if residue:
        problems.append('ONCE_HOOK_LEFT(' + ','.join(residue) + ')')
    # К-09: raw bytes of the surviving configuration (invariant 3).
    if case == 'p12-user-family-config' and obs[8] != normalized_config(world.cfg):
        problems.append('RAW_CONFIG_PARITY')
    return not problems, ','.join(problems) + ' rc=' + str(result.returncode) + ' stderr=' + repr(result.stderr)


def install(work, carrier):
    tools = work / 'tools'
    shutil.copytree(REPO / 'scripts', tools / 'scripts')
    (tools / 'scripts/mint_line.sh').write_bytes(carrier)
    return tools


def check_carriers():
    source = json.loads((HERE / 'source.json').read_text())
    saved = {}
    for rel, sha in source['nositeli'].items():
        data = (HERE / rel).read_bytes()
        if hashlib.sha256(data).hexdigest() != sha:
            raise RuntimeError('ORACLE_TAMPERED ' + rel)
        saved[rel] = data
    return source, saved


def suite(carrier, baseline_data, cases, label):
    red = 0
    with tempfile.TemporaryDirectory(prefix='mint221-', dir=os.environ.get('TMPDIR')) as tmp:
        work = Path(tmp)
        tools = install(work, carrier)
        checked(['bash', '-n', tools / 'scripts/mint_line.sh'])
        baseline = tools / 'scripts/station221.sh'
        baseline.write_bytes(baseline_data)
        for index, case in enumerate(cases):
            directory = work / str(index)
            directory.mkdir()
            ok, detail = cell(tools, tools / 'scripts/mint_line.sh', baseline, case, directory / 'product')
            print(label, case, 'GREEN' if ok else 'RED', detail if not ok else '')
            red += not ok
    return red


def main():
    parser = argparse.ArgumentParser()
    modes = parser.add_mutually_exclusive_group()
    modes.add_argument('--repo', type=Path, default=None)
    modes.add_argument('--model', action='store_true')
    modes.add_argument('--stabs', action='store_true')
    modes.add_argument('--sintaksis', action='store_true')
    args = parser.parse_args()
    for tool in ('git', 'bash', 'jq'):
        if not shutil.which(tool):
            raise RuntimeError('NOT_IMPLEMENTED: missing ' + tool)
    source, saved = check_carriers()
    baseline = saved['model/station.sh']
    model = saved['model/mint_line.sh']
    if args.sintaksis:
        files = [HERE / rel for rel in saved] + [HERE / 'red_mint_line_proekt_221.sh']
        for file in files:
            checked(['bash', '-n', file])
        for file in [HERE / 'model/mint_line.sh', HERE / 'red_mint_line_proekt_221.sh']:
            checked(['bash', REPO / 'scripts/validate_std.sh', 'bash', file])
        compile(Path(__file__).read_bytes(), str(__file__), 'exec')
        compile((HERE / 'build.py').read_bytes(), str(HERE / 'build.py'), 'exec')
        print('SINTAKSIS', len(files), 'SHELLCHECK', 2)
        return 0
    if args.stabs:
        control = suite(model, baseline, CASES, 'CONTROL')
        if control:
            print('MODEL_RED', control)
            return 1
        alive = 0
        for link in source['stab_vhod']:
            red = suite(saved[link['stab']], baseline, [link['case']], link['stab'])
            alive += red == 0
        print('STABY', len({link['stab'] for link in source['stab_vhod']}),
              'SVJAZI', len(source['stab_vhod']), 'ZHIVYH', alive)
        return int(alive != 0)
    candidate = model if args.model else ((args.repo or REPO).resolve() / 'scripts/mint_line.sh').read_bytes()
    red = suite(candidate, baseline, CASES, 'MODEL' if args.model else 'REPO')
    print('KLETKI', len(CASES), 'KRASNYH', red)
    return int(red != 0)


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (RuntimeError, OSError, subprocess.SubprocessError, ValueError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(2)
