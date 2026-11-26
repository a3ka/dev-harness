#!/usr/bin/env python3
"""218: real PR DAGs; independent semantic expectations and pinned legacy oracle."""
import argparse
import dataclasses
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
TREE = HERE.parents[2]
SOURCE = json.loads((HERE / 'source.json').read_bytes())
FILES = ('check_contract_frozen.sh', 'check_charter.sh', 'lib_incr.sh',
         'next_id.sh', 'lib_registry.sh')
GUARDS = ('frozen', 'charter')
SCRIPT = dict(zip(GUARDS, FILES))


class Prerequisite(RuntimeError):
    pass


def environment(extra=None):
    env = {k: v for k, v in os.environ.items() if not k.startswith('GIT_')}
    for key in ('BASH_ENV', 'ENV', 'CHARTER_LIB', 'NEXT_ID_LIB', 'LIB_INCR_LOADED',
                'INCR_GIT_ROOT', 'GITHUB_EVENT_NAME', 'HARNESS_PROJECT_LAYER_ROOT',
                'HARNESS_WORKFLOW_ROOT'):
        env.pop(key, None)
    env.update(GIT_CONFIG_GLOBAL='/dev/null', GIT_CONFIG_SYSTEM='/dev/null',
               GIT_AUTHOR_NAME='architect', GIT_AUTHOR_EMAIL='architect@dev-harness.local',
               GIT_COMMITTER_NAME='architect', GIT_COMMITTER_EMAIL='architect@dev-harness.local',
               GIT_AUTHOR_DATE='1700000000 +0000', GIT_COMMITTER_DATE='1700000000 +0000',
               LC_ALL='C.UTF-8', TMPDIR=str(TREE / 'tmp/scratch-arch218'))
    if extra:
        env.update(extra)
    return env


def command(argv, cwd, data=None, extra=None):
    proc = subprocess.Popen(list(map(str, argv)), cwd=cwd, env=environment(extra),
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, start_new_session=True)
    try:
        out, err = proc.communicate(data, timeout=SOURCE['runner']['timeout_seconds'])
    except subprocess.TimeoutExpired:
        os.killpg(proc.pid, signal.SIGKILL)
        proc.communicate()
        raise Prerequisite('TIMEOUT: ' + repr(argv))
    return proc.returncode, out, err


def git(root, *args, data=None):
    result = command(['git', '-C', root, *args], root, data=data)
    if result[0]:
        raise Prerequisite(f'GIT_WORLD {args!r}: {result!r}')
    return result[1]


def replace(data, old, new):
    if data.count(old) != 1:
        raise Prerequisite('ANCHOR_NOT_UNIQUE: ' + repr(old))
    return data.replace(old, new)


def sources(root, pinned=False):
    return {name: (git(root, 'show', f"{SOURCE['baseline']}:scripts/{name}")
                   if pinned else (root / 'scripts' / name).read_bytes()) for name in FILES}


def model_sources(baseline):
    result = dict(baseline)
    result['pr_window.sh'] = (HERE / 'model/pr_window.sh').read_bytes()
    # Library import remains before CLI dispatch and has no PR side effects.
    header = b'''# 218 reference CLI dispatch: event, never branch-name heuristics.
PR_ACTIVE=0
[ "${GITHUB_EVENT_NAME:-}" != pull_request ] || PR_ACTIVE=1
__pr_args=()
for __pr_arg in "$@"; do
  if [ "$__pr_arg" = --pr ]; then PR_ACTIVE=1; else __pr_args+=("$__pr_arg"); fi
done
set -- "${__pr_args[@]}"
unset __pr_args __pr_arg
'''
    charter = result['check_charter.sh']
    charter = replace(charter, b'ORACLE=0\n', header + b'ORACLE=0\n')
    # PR checks the entire own DAG even when CI restored an incr cache at HEAD.
    charter = replace(charter, b'incr_parse "$@"\n', b'''if [ "$PR_ACTIVE" -eq 1 ]; then
  __pr_args=()
  while [ "$#" -gt 0 ]; do
    case "$1" in --incr) shift 2 ;; --incr=*) shift ;; *) __pr_args+=("$1"); shift ;; esac
  done
  set -- "${__pr_args[@]}"
fi
incr_parse "$@"
''')
    start = b'g() { git -C "$ROOT" "$@"; }\n'
    common = b'''# shellcheck disable=SC1091
. "$SELF_DIR/pr_window.sh"
mkdir -p "$ROOT/tmp"
pr_prepare
'''
    charter = replace(charter, start, start + b'if [ "$PR_ACTIVE" -eq 1 ]; then\nPR_NAME=check_charter\n' + common + b'pr_charter\nexit $?\nfi\n')
    result['check_charter.sh'] = charter
    frozen = replace(result['check_contract_frozen.sh'], b'ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"\n', header + b'ROOT="$(cd "${1:-"$SELF_DIR/.."}" && pwd)"\n')
    frozen = replace(frozen, start, start + b'if [ "$PR_ACTIVE" -eq 1 ]; then\nPR_NAME=check_contract_frozen\n' + common + b'fi\n')
    old = b"g ls-tree -r -z --name-only HEAD -- ':(literal)plans/' ':(literal)contracts/' > \"$TMP/ls-raw\" 2>/dev/null || true\n"
    frozen = replace(frozen, old, b'''if [ "$PR_ACTIVE" -eq 1 ]; then
  pr_files > "$TMP/pr-files"
  while IFS= read -r p; do printf '%s\\0' "$p"; done < "$TMP/pr-files" > "$TMP/ls-raw"
else
''' + old + b'fi\n')
    old = b'g for-each-ref --format=\'%(refname)\' \'refs/tags/frozen/\' 2>/dev/null | sort > "$TMP/tags" || true\n'
    frozen = replace(frozen, old, b'if [ "$PR_ACTIVE" -eq 1 ]; then\npr_tags > "$TMP/tags"\nelse\n' + old + b'fi\n')
    old = b'''      pred_komity="$(g log -s --format=%H --no-renames --diff-merges=first-parent \\
        "refs/tags/frozen/$dir/$NNN/$vmax"..HEAD -- "$f" 2>/dev/null || true)"
'''
    frozen = replace(frozen, old, b'''      if [ "$PR_ACTIVE" -eq 1 ]; then
        pred_komity="$(pr_changes)"
      else
''' + old + b'      fi\n')
    # Frozen history remains subject to the existing v+1 conjunction even when
    # a later own commit restores the final frozen blob.
    frozen = replace(frozen, b'  if [ -z "$tag_blob" ]; then\n', b'''  pr_pending=""
  if [ "$PR_ACTIVE" -eq 1 ]; then pr_pending="$(pr_changes)"; fi
  if [ -z "$tag_blob" ]; then
''')
    frozen = replace(frozen, b'  elif [ "$head_blob" != "$tag_blob" ]; then\n',
                     b'  elif [ "$head_blob" != "$tag_blob" ] || [ -n "$pr_pending" ]; then\n')
    old = b'    body="$(g cat-file -p "HEAD:$verdict" 2>/dev/null || true)"\n'
    frozen = replace(frozen, old, b'''    if [ "$PR_ACTIVE" -eq 1 ]; then
      pr_verdict "$PR_HEAD" "$verdict"
      body="$PR_VERDICT_BODY"
    else
''' + old + b'''    fi
    # Keep the legacy empty-body check, but absence is a separate tree fact.
    if [ "$PR_ACTIVE" -eq 1 ] && [ -z "$body" ]; then
      if [ "$PR_VERDICT_PRESENT" -eq 0 ]; then
        anchor="$(g rev-parse --verify "refs/tags/frozen/$dir/$NNN/$k^{commit}")" || pr_refuse TAG_UNREADABLE
        case $'\\n'"$PR_COMMITS"$'\\n' in *$'\\n'"$anchor"$'\\n'*)
          pr_verdict "$anchor" "$verdict"
          body="$PR_VERDICT_BODY"
          ;;
        esac
      fi
    fi
''')
    result['check_contract_frozen.sh'] = frozen
    return result


@dataclasses.dataclass(frozen=True)
class Cell:
    name: str
    world: str
    guard: str
    rc: int = 0
    diagnosis: str = ''
    mode: str = 'event'
    legacy: bool = False


def cells():
    result = []
    for guard in GUARDS:
        for world in ('clean', 'late-tag', 'neighbor-before', 'neighbor-after',
                      'owner-update', 'owner-update-allowed', 'draft', 'long-main'):
            result.append(Cell(f'{guard}-{world}', world, guard))
        for world in ('frozen-revert-allowed', 'frozen-revert-refrozen', 'code-revert',
                      'unique-base', 'carrier-main-first'):
            result.append(Cell(f'{guard}-{world}', world, guard))
        for world, diagnosis in (('missing-base', 'BASE_MISSING'), ('shallow', 'SHALLOW'),
                                 ('forged-base', 'BASE_UNTRUSTED'), ('no-origin', 'ORIGIN_UNAVAILABLE'),
                                 ('unrelated', 'BASE_UNRELATED'),
                                 ('ambiguous-base', 'BASE_AMBIGUOUS'),
                                 ('ambiguous-base-descendant', 'BASE_AMBIGUOUS')):
            result.append(Cell(f'{guard}-{world}', world, guard, 1, 'PR_WINDOW_' + diagnosis))
        for world in ('own-frozen', 'retroactive-frozen', 'delete-frozen', 'verdict-fail'):
            reason = 'без новой заморозки' if guard == 'frozen' else 'без разрешения владельца'
            if world == 'verdict-fail':
                if guard == 'charter':
                    continue
                reason = 'вердикта, который её не разрешил'
            result.append(Cell(f'{guard}-{world}', world, guard, 1, reason))
        for world in ('frozen-revert', 'carrier-main-first-revert'):
            reason = 'без новой заморозки' if guard == 'frozen' else 'без разрешения владельца'
            result.append(Cell(f'{guard}-{world}', world, guard, 1, reason))
        for world in ('push-clean', 'push-bad', 'push-incr-empty', 'push-oracle'):
            result.append(Cell(f'{guard}-{world}', world, guard, legacy=True, mode='push'))
    for world in ('own-charter', 'reverted-charter', 'evil-merge', 'side-charter'):
        result.append(Cell('charter-' + world, world, 'charter', 1, 'без разрешения владельца'))
    result.extend([
        Cell('frozen-main-merges-1284', 'main-merges', 'frozen'),
        Cell('charter-explicit-owner', 'owner-update', 'charter', mode='explicit'),
        Cell('frozen-explicit-late-tag', 'late-tag', 'frozen', mode='explicit'),
        Cell('charter-pr-oracle', 'owner-update', 'charter', mode='oracle'),
        Cell('charter-pr-cache-head', 'own-charter', 'charter', 1, 'без разрешения владельца', mode='cache'),
        Cell('charter-pr-cache-green', 'owner-update', 'charter', mode='cache'),
        Cell('frozen-renamed-values', 'late-tag-alt', 'frozen'),
        Cell('charter-renamed-values', 'own-charter-alt', 'charter', 1, 'без разрешения владельца'),
    ])
    # Adv218: every version and both artifact kinds are independently scoped.
    for directory in ('contracts', 'plans'):
        for version in (1, 2, 3):
            for verdict in ('fail', 'accept'):
                world = f'verdict-{directory}-v{version}-{verdict}'
                reason = f'заморозка v{version} лежит поверх вердикта, который её не разрешил'
                result.append(Cell('frozen-' + world, world, 'frozen',
                                   int(verdict == 'fail'), reason if verdict == 'fail' else ''))
    for guard in GUARDS:
        for removed in ('contract', 'verdict', 'both'):
            for stage in ('before', 'after'):
                world = f'own-v2-delete-{removed}-{stage}'
                reason = ('заморозка v2 лежит поверх вердикта, который её не разрешил'
                          if guard == 'frozen' else 'без разрешения владельца')
                result.append(Cell(f'{guard}-{world}', world, guard, 1, reason))
        for fault, reason in (('diff-all', 'DELTA_UNREADABLE'),
                              ('diff-md', 'DELTA_UNREADABLE'),
                              ('history', 'HISTORY_UNREADABLE')):
            result.append(Cell(f'{guard}-git-fault-{fault}', 'git-fault-' + fault,
                               guard, 1, 'PR_WINDOW_' + reason))
    for fault, reason in (('scope', 'SCOPE_UNREADABLE'), ('tags', 'TAGS_UNREADABLE'),
                          ('tag', 'TAG_UNREADABLE')):
        result.append(Cell('frozen-git-fault-' + fault, 'git-fault-' + fault,
                           'frozen', 1, 'PR_WINDOW_' + reason))
    for permission in ('agents', 'roadmap', 'both', 'neither'):
        denied = {'agents': 'ROADMAP.md', 'roadmap': 'AGENTS.md', 'neither': 'ROADMAP.md'}
        reason = ('без разрешения владельца: ' + denied[permission]
                  if permission in denied else '')
        result.append(Cell('charter-two-documents-' + permission,
                           'two-documents-' + permission, 'charter',
                           int(permission != 'both'), reason))
    # Arb218: HEAD evidence outranks an own freeze's historical accept.
    # Expectations are literals; no post-subject Git read supplies this oracle.
    for directory in ('contracts', 'plans'):
        for version in (2, 3):
            for state in ('head-accept', 'head-fail', 'head-empty',
                          'head-missingblob', 'head-catfault', 'head-treefault',
                          'anchor-accept', 'anchor-fail', 'anchor-empty',
                          'anchor-absent', 'anchor-foreign',
                          'anchor-missingblob', 'anchor-catfault', 'anchor-treefault'):
                reason = ''
                rc = int(state not in ('head-accept', 'anchor-accept'))
                if state.endswith(('missingblob', 'catfault', 'treefault')):
                    reason = 'PR_WINDOW_TAG_UNREADABLE'
                elif state.endswith('fail'):
                    reason = f'заморозка v{version} лежит поверх вердикта, который её не разрешил: первая строка «FAIL»'
                elif rc:
                    reason = f'заморозка v{version} без вердикта критика'
                world = f'evidence-{directory}-v{version}-{state}'
                result.append(Cell('frozen-' + world, world, 'frozen', rc, reason))
    return result


class World:
    def __init__(self, directory, cell):
        self.root = directory / 'repo'
        self.origin = directory / 'origin.git'
        self.root.mkdir()
        self.cell = cell
        self.counter = 0
        self.number = SOURCE['worlds']['alternate_number'] if cell.world.endswith('-alt') else SOURCE['worlds']['number']
        self.path = f'contracts/{self.number:03d}-fixture.md'
        self.foreign = f"contracts/{SOURCE['worlds']['foreign_number']:03d}-neighbor.md"
        self.verdict = f'verdicts/critic/contracts-{self.number:03d}-v1.md'
        git(self.root, 'init', '-q', '-b', 'main')
        self.files = {'AGENTS.md': b'charter\n', 'ROADMAP.md': b'roadmap\n',
                      self.path: b'frozen one\n', self.foreign: b'draft\n', self.verdict: b'accept\n'}
        self.seed = self.commit(self.files, (), 'seed')
        git(self.root, 'tag', '-a', 'ustav/1', self.seed, '-m', 'fixture charter')
        git(self.root, 'tag', '-a', f'frozen/contracts/{self.number:03d}/1', self.seed, '-m', 'fixture freeze')
        self.main = self.seed
        self.head = self.seed
        self.build(cell.world.removesuffix('-alt'))
        git(self.root, 'update-ref', 'refs/heads/main', self.main)
        git(self.root, 'symbolic-ref', 'HEAD', 'refs/heads/owner/fixture')
        git(self.root, 'update-ref', 'HEAD', self.head)
        git(self.root, 'reset', '--hard', '-q', self.head)
        git(self.root, 'init', '--bare', '-q', self.origin)
        git(self.origin, 'fetch', '-q', self.root, '+refs/heads/main:refs/heads/main', '+refs/tags/*:refs/tags/*')
        git(self.root, 'remote', 'add', 'origin', str(self.origin))
        git(self.root, 'update-ref', 'refs/remotes/origin/main', self.main)
        if cell.world == 'missing-base':
            git(self.root, 'update-ref', '-d', 'refs/remotes/origin/main')
        elif cell.world == 'forged-base':
            git(self.root, 'update-ref', 'refs/remotes/origin/main', self.head)
        elif cell.world == 'no-origin':
            git(self.root, 'remote', 'remove', 'origin')
            git(self.root, 'update-ref', 'refs/remotes/origin/main', self.main)
        elif cell.world == 'shallow':
            (self.root / '.git/shallow').write_text(self.seed + '\n')
        elif cell.world == 'unrelated':
            unrelated = self.commit({'isolated': b'other root\n'}, (), 'other root')
            git(self.origin, 'fetch', '-q', self.root, f'+{unrelated}:refs/heads/main')
            git(self.root, 'update-ref', 'refs/remotes/origin/main', unrelated)
            git(self.root, 'read-tree', self.head)
        self.cache = directory / 'cache.sha'
        self.cache.write_text(self.head + '\n')
        self.original_cache = self.cache.read_bytes()
        self.before = git(self.root, 'status', '--porcelain=v1', '-z')
        if self.before:
            raise Prerequisite('WORLD_DIRTY')
        # Git plumbing and the constructor establish expected DAG facts before subject.
        if cell.world not in ('missing-base', 'forged-base', 'no-origin', 'shallow', 'unrelated'):
            self.own = git(self.root, 'rev-list', self.head, '--not', self.main).decode().splitlines()
            if not self.own:
                raise Prerequisite('EMPTY_OWN_HISTORY')
        else:
            self.own = []
        if cell.world in ('ambiguous-base', 'ambiguous-base-descendant', 'unique-base'):
            bases = git(self.root, 'merge-base', '--all', self.main, self.head).decode().splitlines()
            expected_bases = {self.cross_a, self.cross_b} if cell.world != 'unique-base' else {self.cross_b}
            if set(bases) != expected_bases or len(bases) != len(expected_bases):
                raise Prerequisite('WORLD_MERGE_BASES: ' + repr(bases))
        if cell.world.startswith('carrier-main-first'):
            parents = git(self.root, 'rev-list', '--parents', '-n', '1', self.head).decode().split()[1:]
            if parents != [self.main, self.carrier]:
                raise Prerequisite('WORLD_CARRIER_PARENTS')
        if cell.world.startswith('evidence-'):
            self.evidence_oid = git(self.root, 'rev-parse',
                                    f'{self.evidence_ref}:{self.evidence_path}').decode().strip() if self.evidence_fault else ''
            if self.evidence_fault:
                self.evidence_object = self.root / '.git/objects' / self.evidence_oid[:2] / self.evidence_oid[2:]
                self.evidence_bytes = self.evidence_object.read_bytes()

    def tree_files(self, commit):
        names = git(self.root, 'ls-tree', '-r', '-z', '--name-only', commit).split(b'\0')
        return {os.fsdecode(p): git(self.root, 'show', f'{commit}:{os.fsdecode(p)}') for p in names if p}

    def commit(self, updates, parents, message):
        files = self.tree_files(parents[0]) if parents else {}
        for name, value in updates.items():
            if value is None:
                files.pop(name, None)
            else:
                files[name] = value
        git(self.root, 'read-tree', '--empty')
        records = bytearray()
        for name, value in sorted(files.items()):
            oid = git(self.root, 'hash-object', '-w', '--stdin', data=value).strip()
            records += b'100644 ' + oid + b'\t' + os.fsencode(name) + b'\0'
        git(self.root, 'update-index', '-z', '--index-info', data=bytes(records))
        tree = git(self.root, 'write-tree').decode().strip()
        args = ['commit-tree', tree]
        for parent in parents:
            args += ['-p', parent]
        self.counter += 1
        sha = git(self.root, *args, data=f'{message}\n\nfixture sequence {self.counter}\n'.encode()).decode().strip()
        return sha

    def allowed(self, path):
        return f'fixture permission\n\nРАЗРЕШИЛ-ВЛАДЕЛЕЦ: {path} synthetic test input'

    def main_change(self):
        self.main = self.commit({self.foreign: b'published neighbor\n',
                                 f"verdicts/critic/contracts-{SOURCE['worlds']['foreign_number']:03d}-v1.md": b'accept\n'},
                                (self.main,), 'neighbor publication')
        git(self.root, 'tag', '-a', f"frozen/contracts/{SOURCE['worlds']['foreign_number']:03d}/1", self.main, '-m', 'neighbor')

    def build(self, kind):
        self.head = self.commit({'code.txt': b'own work\n'}, (self.seed,), 'own PR')
        if kind in ('late-tag', 'neighbor-after', 'owner-update', 'owner-update-allowed',
                    'own-charter', 'reverted-charter', 'evil-merge', 'retroactive-frozen',
                    'main-merges', 'long-main'):
            self.main_change()
        if kind == 'long-main':
            for i in range(SOURCE['worlds']['history_commits']):
                self.main = self.commit({'main-code.txt': str(i).encode()}, (self.main,), f'main {i}')
        if kind in ('owner-update', 'owner-update-allowed', 'own-charter', 'reverted-charter', 'evil-merge'):
            self.main = self.commit({'AGENTS.md': b'main-only unauthorized charter\n'}, (self.main,), 'main-only charter')
            if kind in ('own-charter', 'reverted-charter', 'owner-update-allowed'):
                message = self.allowed('ROADMAP.md') if kind == 'owner-update-allowed' else 'own forbidden charter'
                self.head = self.commit({'ROADMAP.md': b'own roadmap\n'}, (self.head,), message)
                if kind == 'reverted-charter':
                    self.head = self.commit({'ROADMAP.md': b'roadmap\n'}, (self.head,), 'revert own charter')
            imported = self.tree_files(self.main)
            imported['code.txt'] = b'own work\n'
            imported['ROADMAP.md'] = self.tree_files(self.head)['ROADMAP.md']
            if kind == 'evil-merge':
                imported['AGENTS.md'] = b'novel evil merge charter\n'
            self.head = self.commit(imported, (self.head, self.main), 'update-branch')
        elif kind in ('own-frozen', 'retroactive-frozen', 'delete-frozen', 'verdict-fail'):
            if kind == 'verdict-fail':
                self.head = self.commit({self.verdict: b'FAIL\n'}, (self.head,), 'replace verdict')
            else:
                self.head = self.commit({self.path: None if kind == 'delete-frozen' else b'own forbidden frozen\n'},
                                        (self.head,), 'own forbidden frozen')
            if kind == 'retroactive-frozen':
                updates = self.tree_files(self.main)
                updates[self.path] = b'own forbidden frozen\n'
                updates['code.txt'] = b'own work\n'
                self.head = self.commit(updates, (self.head, self.main), 'update-branch after own frozen edit')
        elif kind == 'side-charter':
            side = self.commit({'ROADMAP.md': b'own roadmap\n'}, (self.seed,), 'side forbidden charter')
            self.head = self.commit({'ROADMAP.md': b'own roadmap\n'}, (self.head,), self.allowed('ROADMAP.md'))
            self.head = self.commit({}, (self.head, side), 'merge matching first parent')
        elif kind == 'draft':
            self.head = self.commit({self.foreign: b'own draft revision\n'}, (self.head,), 'draft revision')
        elif kind == 'main-merges':
            next_verdict = f'verdicts/critic/contracts-{self.number:03d}-v2.md'
            self.head = self.commit({self.path: b'next frozen\n', next_verdict: b'accept\n'},
                                    (self.head,), self.allowed(self.path))
            self.main = self.commit({self.path: b'next frozen\n', next_verdict: b'accept\n'}, (self.main,), 'main text without own PR permission')
            for i in range(SOURCE['worlds']['main_merges']):
                side = self.commit({f'side-{i}': b'side\n'}, (self.main,), f'neighbor {i}')
                self.main = self.commit({f'side-{i}': b'side\n'}, (self.main, side), f'main merge {i}')
            updates = self.tree_files(self.main)
            updates['code.txt'] = b'own work\n'
            self.head = self.commit(updates, (self.head, self.main), 'update-branch main merges')
        elif kind == 'push-bad':
            self.head = self.commit({'ROADMAP.md': b'forbidden\n', self.path: b'forbidden\n'}, (self.head,), 'forbidden')
        elif kind in ('frozen-revert', 'frozen-revert-allowed', 'frozen-revert-refrozen',
                      'carrier-main-first-revert'):
            permitted = kind in ('frozen-revert-allowed', 'frozen-revert-refrozen')
            next_verdict = f'verdicts/critic/contracts-{self.number:03d}-v2.md'
            updates = {self.path: b'own intermediate frozen\n'}
            if permitted:
                updates[next_verdict] = b'accept\n'
            message = self.allowed(self.path) if permitted else 'own forbidden frozen'
            self.head = self.commit(updates, (self.head,), message)
            self.head = self.commit({self.path: b'frozen one\n'}, (self.head,),
                                    self.allowed(self.path) if permitted else 'revert own frozen')
            if kind == 'frozen-revert-refrozen':
                git(self.root, 'tag', '-a', f'frozen/contracts/{self.number:03d}/2',
                    self.head, '-m', 'fixture next freeze')
        elif kind == 'code-revert':
            self.head = self.commit({'code.txt': b'intermediate code\n'}, (self.head,), 'code edit')
            self.head = self.commit({'code.txt': b'own work\n'}, (self.head,), 'revert code only')
        elif kind in ('ambiguous-base', 'ambiguous-base-descendant', 'unique-base'):
            self.cross_a = self.commit({'a.txt': b'A\n'}, (self.seed,), 'cross A')
            self.cross_b = self.commit({'b.txt': b'B\n'}, (self.seed,), 'cross B')
            updates = {'a.txt': b'A\n', 'b.txt': b'B\n'}
            self.main = self.commit(updates, (self.cross_a, self.cross_b), 'main A B')
            parents = (self.cross_b,) if kind == 'unique-base' else (self.cross_b, self.cross_a)
            self.head = self.commit(updates, parents, 'PR B A')
            if kind == 'ambiguous-base-descendant':
                self.head = self.commit({'code.txt': b'own descendant\n'}, (self.head,), 'after cross')
        elif kind.startswith('evidence-'):
            _, directory, version_text, location, state = kind.split('-')
            version = int(version_text[1:])
            if directory == 'plans':
                self.path = f'plans/{self.number:03d}-fixture.md'
                self.main = self.commit({self.path: b'frozen one\n',
                                        f'verdicts/critic/plans-{self.number:03d}-v1.md': b'accept\n'},
                                       (self.seed,), 'main plan')
                git(self.root, 'tag', '-a', f'frozen/plans/{self.number:03d}/1',
                    self.main, '-m', 'plan v1')
                self.head = self.commit({'code.txt': b'own work\n'}, (self.main,), 'own plan PR')
            self.evidence_path = f'verdicts/critic/{directory}-{self.number:03d}-v{version}.md'
            self.evidence_fault = state if state in ('missingblob', 'catfault', 'treefault') else ''
            for k in range(2, version + 1):
                path = f'verdicts/critic/{directory}-{self.number:03d}-v{k}.md'
                body = f'accept\nown {directory} v{k}\n'.encode()
                if location == 'anchor' and k == version:
                    if state == 'fail':
                        body = b'FAIL\n'
                    elif state == 'empty':
                        body = b''
                    elif state == 'absent':
                        body = None
                parent = self.main if state == 'foreign' else self.head
                anchor = self.commit({path: body}, (parent,), f'own {directory} v{k}')
                git(self.root, 'tag', '-a', f'frozen/{directory}/{self.number:03d}/{k}',
                    anchor, '-m', f'own v{k}')
                if state == 'foreign':
                    self.main = anchor
                else:
                    self.head = anchor
            if state == 'foreign':
                self.head = self.commit({'code.txt': b'own work\n'}, (self.main,), 'own foreign-tag PR')
            if location == 'head':
                body = b'accept\nupdated HEAD explanation\n' if state == 'accept' else b'FAIL\n'
                if state == 'empty':
                    body = b''
                self.head = self.commit({self.evidence_path: body}, (self.head,), 'own HEAD evidence')
                self.evidence_ref = self.head
            else:
                self.evidence_ref = anchor
                if state == 'foreign':
                    self.head = self.commit({self.evidence_path: None}, (self.head,), 'own deletes foreign verdict')
                else:
                    self.main = self.commit({self.evidence_path: None}, (self.main,), 'main removes verdict')
                    self.head = self.commit({self.evidence_path: None}, (self.head, self.main), 'import verdict deletion')
                if git(self.root, 'ls-tree', '-r', '-z', '--full-tree', self.head,
                       '--', ':(literal)' + self.evidence_path):
                    raise Prerequisite('WORLD_EVIDENCE_NOT_ABSENT')
        elif kind.startswith('verdict-'):
            _, directory, version, outcome = kind.split('-')
            if directory == 'plans':
                self.path = f'plans/{self.number:03d}-fixture.md'
                self.main = self.commit({self.path: b'frozen one\n',
                                        f'verdicts/critic/plans-{self.number:03d}-v1.md': b'accept\n'},
                                       (self.seed,), 'main plan')
                git(self.root, 'tag', '-a', f'frozen/plans/{self.number:03d}/1',
                    self.main, '-m', 'plan v1')
            for k in (2, 3):
                self.main = self.commit({f'verdicts/critic/{directory}-{self.number:03d}-v{k}.md': b'accept\n'},
                                       (self.main,), f'main v{k}')
                git(self.root, 'tag', '-a', f'frozen/{directory}/{self.number:03d}/{k}',
                    self.main, '-m', f'main v{k}')
            verdict = f'verdicts/critic/{directory}-{self.number:03d}-{version}.md'
            body = b'FAIL\n' if outcome == 'fail' else b'accept\nupdated explanation\n'
            self.head = self.commit({verdict: body}, (self.main,), 'own verdict only')
        elif kind.startswith('own-v2-delete-'):
            _, _, _, removed, stage = kind.split('-')
            verdict = f'verdicts/critic/contracts-{self.number:03d}-v2.md'
            updates = {verdict: b'FAIL\n'}
            if self.cell.guard == 'charter':
                updates[self.path] = b'own forbidden frozen\n'
            own = self.commit(updates, (self.head,), 'own failing verdict')
            git(self.root, 'tag', '-a', f'frozen/contracts/{self.number:03d}/2',
                own, '-m', 'own v2')
            deleted = {}
            if removed in ('contract', 'both'):
                deleted[self.path] = None
            if removed in ('verdict', 'both'):
                deleted[verdict] = None
            self.main = self.commit(deleted, (self.seed,), 'main deletes artifact')
            merged = self.commit(deleted, (own, self.main), 'import main deletion')
            self.head = own if stage == 'before' else merged
            # Independent Git facts: the same own annotated tag survives import.
            if git(self.root, 'rev-parse', f'frozen/contracts/{self.number:03d}/2^{{commit}}').decode().strip() != own:
                raise Prerequisite('WORLD_OWN_TAG')
            if git(self.root, 'show', f'{own}:{verdict}') != b'FAIL\n':
                raise Prerequisite('WORLD_OWN_VERDICT')
            if stage == 'after':
                for path in deleted:
                    if path in self.tree_files(merged):
                        raise Prerequisite('WORLD_IMPORTED_DELETION')
        elif kind.startswith('two-documents-'):
            permission = kind.removeprefix('two-documents-')
            message = 'own two documents'
            if permission in ('agents', 'both'):
                message += '\n\n' + self.allowed('AGENTS.md')
            if permission in ('roadmap', 'both'):
                message += '\n\n' + self.allowed('ROADMAP.md')
            self.head = self.commit({'AGENTS.md': b'own agents\n', 'ROADMAP.md': b'own roadmap\n'},
                                    (self.head,), message)
        elif kind.startswith('git-fault-'):
            # Real Git still builds/verifies the world. Only subject invocations
            # receive the deterministic tool-error injector below.
            self.head = self.commit({'ROADMAP.md': b'own roadmap\n',
                                     self.verdict: b'FAIL\n'}, (self.head,), 'own scoped change')
        if kind in ('carrier-main-first', 'carrier-main-first-revert'):
            self.main_change()
            self.main = self.commit({'AGENTS.md': b'imported main charter\n'}, (self.main,),
                                    'main-only unauthorized charter')
            self.carrier = self.head
            imported = self.tree_files(self.main)
            imported['code.txt'] = b'own work\n'
            self.head = self.commit(imported, (self.main, self.carrier), 'carrier main first')

    def run(self, selected, directory, trace, fault=True):
        tool = directory / 'scripts'
        tool.mkdir()
        for name, data in selected.items():
            (tool / name).write_bytes(data)
        args = ['bash', tool / SCRIPT[self.cell.guard]]
        extra = {'GIT_TRACE2_EVENT': str(trace)}
        if self.cell.world.startswith('git-fault-'):
            fault = self.cell.world.removeprefix('git-fault-')
            injector = directory / 'bin'
            injector.mkdir()
            wrapper = injector / 'git'
            wrapper.write_text('''#!/usr/bin/env bash
set -eu
op=""
md=0
ref=""
for arg in "$@"; do
  case "$arg" in
    diff-tree|rev-list|ls-tree|for-each-ref|rev-parse) op="$arg" ;;
    --diff-filter=MD) md=1 ;;
    refs/tags/frozen/*^{commit}) ref=1 ;;
  esac
done
hit=0
case "$FAULT:$op:$md:$ref" in
  diff-all:diff-tree:0:*|diff-md:diff-tree:1:*|history:rev-list:*|scope:ls-tree:*|tags:for-each-ref:*|tag:rev-parse:*:1) hit=1 ;;
esac
# Let registry_state complete its first catalog read; fail subsequent reads
# in the PR scope/tag enumeration, rather than testing a different guard.
if [ "$FAULT:$op" = tags:for-each-ref ] && [ ! -e "$FAULT_MARKER.first" ]; then
  touch "$FAULT_MARKER.first"
  hit=0
fi
if [ "$hit" -eq 1 ]; then
  printf '%s\\n' "$FAULT" >> "$FAULT_MARKER"
  exit 127
fi
exec "$REAL_GIT" "$@"
''')
            wrapper.chmod(0o755)
            extra.update(PATH=str(injector) + os.pathsep + os.environ['PATH'],
                         REAL_GIT=shutil.which('git'), FAULT=fault,
                         FAULT_MARKER=str(directory / 'injected'))
        evidence = self.cell.world.startswith('evidence-')
        if evidence and fault and self.evidence_fault in ('catfault', 'treefault'):
            injector = directory / 'bin'
            injector.mkdir()
            wrapper = injector / 'git'
            wrapper.write_text('''#!/usr/bin/env bash
set -eu
op=""
hit=0
tree=0
for arg in "$@"; do
  [ "$arg" != "$EVIDENCE_REF" ] || tree=1
  case "$arg" in cat-file|ls-tree) op="$arg" ;; esac
  if [ "$arg" = "$EVIDENCE_OID" ] || [ "$arg" = "$EVIDENCE_REF:$EVIDENCE_PATH" ] ||
     [ "$arg" = "HEAD:$EVIDENCE_PATH" ] || [ "$arg" = "$EVIDENCE_PATH" ] ||
     [ "$arg" = ":(literal)$EVIDENCE_PATH" ]; then hit=1; fi
done
case "$EVIDENCE_FAULT:$op:$hit:$tree" in
  catfault:cat-file:1:*|treefault:ls-tree:1:1)
    printf '%s\\n' "$EVIDENCE_FAULT" >> "$FAULT_MARKER"; exit 127 ;;
esac
exec "$REAL_GIT" "$@"
''')
            wrapper.chmod(0o755)
            extra.update(PATH=str(injector) + os.pathsep + os.environ['PATH'],
                         REAL_GIT=shutil.which('git'), EVIDENCE_FAULT=self.evidence_fault,
                         EVIDENCE_REF=self.evidence_ref, EVIDENCE_PATH=self.evidence_path,
                         EVIDENCE_OID=self.evidence_oid, FAULT_MARKER=str(directory / 'injected'))
        if self.cell.mode in ('event', 'oracle', 'cache'):
            extra['GITHUB_EVENT_NAME'] = 'pull_request'
        elif self.cell.mode == 'explicit':
            args += ['--pr']
        else:
            extra['GITHUB_EVENT_NAME'] = 'push'
        if self.cell.mode == 'oracle' or self.cell.world == 'push-oracle':
            if self.cell.guard == 'charter':
                args += ['--oracle']
        if self.cell.mode == 'cache' or self.cell.world == 'push-incr-empty':
            if self.cell.guard == 'charter':
                args += ['--incr', self.cache]
        args += [self.root]
        missing = evidence and fault and self.evidence_fault == 'missingblob'
        if missing:
            self.evidence_object.unlink()
        try:
            return command(args, self.root, extra=extra)
        finally:
            # Restore the exact damaged loose object before the state observer.
            if missing:
                self.evidence_object.write_bytes(self.evidence_bytes)


def history_calls(path):
    if not path.is_file():
        raise Prerequisite('TRACE_ABSENT')
    starts = [json.loads(line) for line in path.read_bytes().splitlines()]
    return [e['argv'] for e in starts if e.get('event') == 'start' and 'argv' in e]


def observe(cell, selected, baseline, scratch, mutant=False):
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as temporary:
        directory = Path(temporary)
        world = World(directory, cell)
        expected = None
        errors = []
        if cell.legacy:
            oracle_dir = directory / 'oracle'
            oracle_dir.mkdir()
            expected = world.run(baseline, oracle_dir, directory / 'oracle.trace')
            # Oracle is saved before the tested process; reset only the known cache.
            world.cache.write_bytes(world.original_cache)
        if cell.world.startswith('evidence-') and world.evidence_fault:
            control_dir = directory / 'intact'
            control_dir.mkdir()
            head = '-head-' in cell.world
            control_rc = 1 if head else 0
            intact = world.run(selected, control_dir, directory / 'intact.trace', fault=False)
            if intact[0] == 2 or b'NOT_IMPLEMENTED' in intact[2] or b'syntax error' in intact[2]:
                raise Prerequisite('EVIDENCE_CONTROL_ENVIRONMENT: ' + repr(intact))
            if intact[0] != control_rc or intact[1] or (head and 'первая строка «FAIL»'.encode() not in intact[2]):
                errors.append('INTACT_CONTROL')
        target_dir = directory / 'subject'
        target_dir.mkdir()
        result = world.run(selected, target_dir, directory / 'subject.trace')
        if cell.legacy:
            if result != expected:
                errors.append('LEGACY_BYTES')
        else:
            if cell.world.startswith('git-fault-') and not (target_dir / 'injected').is_file():
                raise Prerequisite('GIT_FAULT_NOT_EXERCISED')
            if cell.world.startswith('evidence-') and world.evidence_fault in ('catfault', 'treefault'):
                if not (target_dir / 'injected').is_file():
                    # An implementation may avoid this read only by dropping evidence.
                    errors.append('EVIDENCE_FAULT_NOT_EXERCISED')
            if result[0] != cell.rc:
                errors.append('RC')
            if cell.diagnosis and cell.diagnosis.encode() not in result[2]:
                errors.append('DIAGNOSIS')
            if not cell.diagnosis.startswith('PR_WINDOW_'):
                marker = b'pr: ' + ('check_contract_frozen' if cell.guard == 'frozen' else 'check_charter').encode() + b' '
                if not any(line.startswith(marker) for line in result[2].splitlines()):
                    errors.append('PR_MODE')
            if result[1] != b'':
                errors.append('STDOUT')
            if world.cache.read_bytes() != world.original_cache:
                errors.append('PR_CACHE_CHANGED')
            # Structural witness for bounded history, not a self-reported count.
            trace_path = directory / 'subject.trace'
            if not trace_path.is_file() and cell.mode == 'explicit' and b'cd: --: invalid option' in result[2]:
                errors.append('PR_INTERFACE_ABSENT')
                calls = []
            else:
                calls = history_calls(trace_path)
            if cell.world.startswith('evidence-'):
                # Canonical tree witness (Arb218); not a body-empty heuristic.
                for argv in calls:
                    if 'ls-tree' not in argv:
                        continue
                    if any(a.endswith(world.evidence_path) for a in argv):
                        if '--full-tree' not in argv or ':(literal)' + world.evidence_path not in argv:
                            errors.append('EVIDENCE_TREE_CANON')
            for argv in calls:
                for op in ('log', 'rev-list'):
                    if op not in argv:
                        continue
                    rest = argv[argv.index(op) + 1:]
                    if op == 'log' and ('-1' in rest or '--no-walk' in rest):
                        continue
                    if op == 'rev-list' and '-n' in rest and rest[rest.index('-n') + 1:rest.index('-n') + 2] == ['1']:
                        continue
                    bounded = '--not' in rest and world.main in rest and world.head in rest
                    bounded |= any('..' in a and a.split('..')[0] in (world.main, world.seed) for a in rest)
                    if not bounded:
                        errors.append('UNBOUNDED_HISTORY')
        if git(world.root, 'rev-parse', 'HEAD').decode().strip() != world.head:
            errors.append('HEAD_CHANGED')
        if git(world.root, 'status', '--porcelain=v1', '-z') != world.before:
            errors.append('TRACKED_CHANGED')
        unsupported = cell.mode == 'explicit' and b'cd: --: invalid option' in result[2]
        if (result[0] == 2 and not unsupported) or b'NOT_IMPLEMENTED' in result[2] or b'syntax error' in result[2]:
            raise Prerequisite('SUBJECT_ENVIRONMENT: ' + repr(result))
        status = 'RED' if errors else 'GREEN'
        print(f'{cell.name} {status} rc={result[0]} {",".join(sorted(set(errors)))}', flush=True)
        if errors and not mutant:
            print('RAW ' + repr(result), flush=True)
        return not errors


def mutations():
    result = {}
    for path in sorted((HERE / 'stabs').glob('*.json')):
        row = json.loads(path.read_bytes())
        if path.stem != row['name'] or row['name'] in result:
            raise Prerequisite('MUTATION_NAME')
        result[row['name']] = row
    if not result:
        raise Prerequisite('EMPTY_MUTATIONS')
    return result


def catalog():
    cases = cells()
    changes = mutations()
    names = {c.name for c in cases}
    if len(names) != len(cases):
        raise Prerequisite('DUPLICATE_CELL')
    for change in changes.values():
        if not change['cells'] or any(n not in names for n in change['cells']):
            raise Prerequisite('MUTATION_BINDINGS')
    index = 'name\tcell\n' + ''.join(f"{m['name']}\t{n}\n"
                                    for m in changes.values() for n in m['cells'])
    if (HERE / 'stabs.tsv').read_bytes() != index.encode():
        raise Prerequisite('STABS_CATALOG')
    census = {'cells': len(cases), 'mutations': len(changes),
              'bindings': sum(len(m['cells']) for m in changes.values())}
    if SOURCE['census'] != census:
        raise Prerequisite('SOURCE_CENSUS: ' + repr(census))
    print(' '.join(f'{k.upper()}={v}' for k, v in census.items()))
    return cases, changes


def syntax(root, baseline):
    compile(Path(__file__).read_bytes(), str(__file__), 'exec')
    compile((HERE / 'context.py').read_bytes(), str(HERE / 'context.py'), 'exec')
    compile((HERE / 'production_mutants.py').read_bytes(), str(HERE / 'production_mutants.py'), 'exec')
    with tempfile.TemporaryDirectory(prefix='syntax-218-', dir=root) as temporary:
        directory = Path(temporary)
        for name, data in model_sources(baseline).items():
            path = directory / name
            path.write_bytes(data)
            result = command(['bash', '-n', path], TREE)
            if result[0]:
                raise Prerequisite('BASH_SYNTAX: ' + repr(result))
        for path in (HERE / 'model/pr_window.sh', HERE / 'red_okno_frozen_v_pr_218.sh'):
            result = command(['bash', TREE / 'scripts/validate_std.sh', 'bash', path], TREE)
            if result[0]:
                raise Prerequisite('BASH_VALIDATOR: ' + repr(result))
    print('SYNTAX rc=0')
    return 0


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=TREE)
    modes = parser.add_mutually_exclusive_group()
    for name in ('model', 'stabs', 'catalog', 'sintaksis', 'context'):
        modes.add_argument('--' + name, action='store_true')
    parser.add_argument('--cell')
    args = parser.parse_args(argv)
    try:
        cases, changes = catalog()
        if args.catalog:
            for case in cases:
                print('CELL ' + case.name)
            for change in changes.values():
                for name in change['cells']:
                    print(f"{change['name']} -> {name}")
            return 0
        if args.context:
            return command(['python3', HERE / 'context.py'], TREE)[0]
        scratch = TREE / 'tmp/scratch-arch218'
        scratch.mkdir(parents=True, exist_ok=True)
        baseline = sources(args.repo.resolve(), pinned=True)
        if args.sintaksis:
            return syntax(scratch, baseline)
        selected = model_sources(baseline) if args.model or args.stabs else sources(args.repo.resolve())
        if args.cell:
            cases = [c for c in cases if c.name == args.cell]
            if not cases:
                raise Prerequisite('EMPTY_SELECTION')
        if args.stabs:
            by_name = {c.name: c for c in cases}
            caught = count = 0
            for change in changes.values():
                altered = dict(selected)
                name = change['file']
                altered[name] = replace(altered[name], change['old'].encode(), change['new'].encode())
                checked = command(['bash', '-n'], TREE, data=altered[name])
                if checked[0]:
                    raise Prerequisite('MUTATION_SYNTAX: ' + change['name'])
                for name in change['cells']:
                    case = by_name[name]
                    if not observe(case, selected, baseline, scratch):
                        raise Prerequisite('HONEST_CONTROL_RED: ' + name)
                    dead = not observe(case, altered, baseline, scratch, mutant=True)
                    count += 1
                    caught += dead
                    print(f"{change['name']} -> {name}: {'POIMAN' if dead else 'ZHIV'}", flush=True)
            print(f'STABY={len(changes)} SVJAZI={count} POIMANY={caught} ZHIVYH={count-caught}')
            return int(caught != count)
        green = sum(observe(c, selected, baseline, scratch) for c in cases)
        print(f'KLETKI={len(cases)} ZELENYE={green} KRASNYE={len(cases)-green}')
        return int(green != len(cases))
    except (OSError, ValueError, KeyError, Prerequisite) as exc:
        print('NOT_IMPLEMENTED: ' + str(exc), file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
