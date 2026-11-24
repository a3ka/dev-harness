"""Addressed transport probes on real Git worlds; expectations precede invocation.

Production seams are extracted byte-for-byte, without rewriting their bodies. This
avoids unrelated early CLI guards masking the reader being exercised. Full charter
and hook integration remains in probe.py. Reader models preserve the same policy.
"""
from pathlib import Path
import tempfile
import shutil


def function(raw, name):
    text = raw.decode()
    start = text.index(name + '() {')
    end = text.index('\n}', start) + 2
    return text[start:end] + '\n'


def between(raw, first, last):
    text = raw.decode()
    start = text.index(first)
    return text[start:text.index(last, start)]


def cells(p):
    result = []
    for form, slug in (('quote', 'a"quote'), ('slash', 'a\\slash'), ('tab', 'a\ttab'),
                       ('lf', 'a\nline'), ('cr', 'a\rcr'), ('soh', 'a\x01soh'), ('del', 'a\x7fdel')):
        result.append(p.Cell(f'wire-route-{form}', 'history', 'seam', slug=slug))
    for variant in ('scope', 'log', 'empty', 'truncated'):
        result.append(p.Cell(f'wire-errors-{variant}', 'history', 'seam'))
    for seam in ('diff', 'head', 'history', 'backfill', 'frozen', 'zones', 'owner', 'ownerread'):
        for form, slug in (('ascii', 'ascii'), ('quote', 'a"quote'), ('slash', 'a\\slash'),
                           ('tab', 'a\ttab'), ('lf', 'a\nline')):
            result.append(p.Cell(f'wire-{seam}-{form}', 'edit', 'seam', slug=slug))
        if seam in ('frozen', 'zones', 'owner', 'ownerread'):
            result.append(p.Cell(f'wire-{seam}-clean', 'history', 'seam', slug='a"quote'))
    for site in ('d1', 'd2', 'cm', 'cm2'):
        for decision in ('allow', 'deny'):
            result.append(p.Cell(f'wire-167-{site}-{decision}', 'history', 'seam', slug='a"quote'))
    for form, slug in (('ascii', 'ascii'), ('quote', 'a"quote'), ('slash', 'a\\slash'),
                       ('cyrillic', 'кириллица'), ('nfc', 'café'),
                       ('nfd', 'cafe\u0301'), ('space', 'a space')):
        for shape in ('draft', 'history', 'land', 'edit'):
            result.append(p.Cell(f'wire-frozenscope-{form}-{shape}', shape, 'seam', slug=slug))
        for seam in ('zoneshead', 'zonestag'):
            for decision in ('valid', 'invalid'):
                result.append(p.Cell(f'wire-{seam}-{form}-{decision}', 'history', 'seam', slug=slug))
    return result


def observe(p, cell, sources, scratch, override=None):
    with tempfile.TemporaryDirectory(prefix=cell.name + '-', dir=scratch) as directory:
        world = p.World(directory, cell)
        root = world.root
        tmp = Path(directory) / 'reader-tmp'
        tmp.mkdir()
        for name, raw in sources.items():
            dest = root / name
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_bytes(raw)
        if cell.name.startswith('wire-route-'):
            return route(p, cell, world, sources)
        if cell.name.startswith('wire-frozenscope-'):
            return frozen_scope(p, cell, world, sources, override)
        if cell.name.startswith(('wire-zoneshead-', 'wire-zonestag-')):
            return zones_tree(p, cell, world, sources, tmp, override)
        model = sources.get('reader-model.sh')
        libs = '''set -uo pipefail
NEXT_ID_LIB=1
. "$ROOT/scripts/next_id.sh"
CHARTER_LIB=1
. "$ROOT/scripts/check_charter.sh"
g() { git -C "$ROOT" "$@"; }
fails=0
bad() { fails=$((fails+1)); }
set +e
export GIT_COMMITTER_NAME=architect GIT_COMMITTER_EMAIL=architect@dev-harness.local
'''
        prefix = f'ROOT={quote(str(root))}\nroot="$ROOT"\nTMP={quote(str(tmp))}\n' + libs
        expected = (0, b'', b'')
        seam = cell.name.split('-')[1]
        if seam in ('head', 'history', 'backfill'):
            prefix += '''original_parser="$(declare -f parse_artifact_basename)"
eval "${original_parser/parse_artifact_basename/parse_original_210}"
parse_artifact_basename() { printf '%s\\0' "$1" >> "$TMP/audit"; parse_original_210 "$1"; }
: > "$TMP/audit"
'''
        if seam == 'errors':
            variant = cell.name.split('-')[2]
            fail = {'scope': 'ls-tree', 'log': 'log', 'empty': 'log', 'truncated': 'log'}[variant]
            effect = 'return 128'
            reason = ('  FAIL область устава (plans/, contracts/) не читается (ls-tree rc=128): проверить невозможно — git fsck и повтор\n'
                      if variant == 'scope' else
                      '  FAIL история не читается (git log rc=128): проверить невозможно — git fsck и повтор\n')
            if variant in ('empty', 'truncated'):
                effect = ('return 0' if variant == 'empty' else
                          f"printf '\\0{world.commits[world.head]}\\0\\ncontracts/unclosed'; return 0")
                reason = '  FAIL пустой или оборванный протокол git log: проверить невозможно\n'
            program = prefix + f'''git() {{
  case " $* " in
    *" {fail} "*) case " $* " in
      *" --name-only "*) {effect} ;;
    esac ;;
  esac
  command git "$@"
}}
export -f git
bash "$ROOT/scripts/check_charter.sh" "$ROOT"
'''
            clean = p.Cell('error-control', 'history')
            world.cell = clean
            clean_expected = world.expected()
            expected = (1, b'', reason.encode() + (b'' if variant == 'scope' else clean_expected[2]))
        elif seam == 'diff':
            sha = world.commits[world.head]
            program = prefix + f'charter_diff_paths {sha} "$ROOT"\n'
            expected = (0, world.path.encode() + b'\0', b'')
        elif seam in ('head', 'history'):
            # Source maxima are tested separately: the other source cannot mask one.
            if seam == 'history':
                world.commit('removed', {world.path: None})
                p.git(root, 'update-ref', 'refs/heads/main', world.commits['removed'])
            if model:
                body = model.decode() + f'next_{seam}_210 "$ROOT"\n'
            elif seam == 'head':
                body = '''max=0
locations=(contracts/)
''' + between(sources['scripts/next_id.sh'], '  for loc in "${locations[@]}"; do\n    while', '\n  # Источник 4:') + '\nprintf "%s\\n" "$max"\n'
            else:
                body = 'max=0\nlocations=(contracts/)\n' + between(sources['scripts/next_id.sh'], '  local joined=', '\n  printf \'%d\\n\' "$max"')
                body = body.replace('  local joined=', '  joined=') + '\nprintf "%s\\n" "$max"\n'
            program = prefix + 'reader() {\n' + body + '\n}\nreader\ncat "$TMP/audit"\n'
            expected = (0, b'810\n' + (cell.number + '-' + cell.slug + '.md').encode() + b'\0', b'')
        elif seam == 'backfill':
            # LF names must not create a second record, even on the find route.
            target = root / world.path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(b'draft\n')
            if model:
                program = prefix + model.decode() + 'backfill_210 "$ROOT"\n'
            else:
                raw = sources['scripts/next_id.sh']
                body = between(raw, '  created=0; skipped=0', '\n  printf \'  ok   backfill')
                program = prefix + 'HERE="$ROOT"\nclass=CONTRACT\nlocations=(contracts/)\ndie() { return 1; }\n' + body
            program += '\ngit -C "$ROOT" for-each-ref --format="%(refname)" refs/tags/id/\ncat "$TMP/audit"\n'
            expected = (0, b'refs/tags/id/CONTRACT/810\n' + (cell.number + '-' + cell.slug + '.md').encode() + b'\0', b'')
        elif seam in ('frozen', 'zones'):
            # Hold f ASCII to isolate the external consumer from unrelated ls-tree.
            # The changed companion uses real quoting/control bytes.
            clean = cell.shape == 'history'
            f = 'contracts/800-subject.md'
            world.commit('external-base', {f: b'old\n', world.path: b'old\n'})
            message = f'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {f} authorized\n'
            world.commit('external-edit', {f: b'new\n', world.path: b'new\n'} if not clean else {f: b'new\n'}, message=message)
            if model:
                body = model.decode() + f'{seam}_reader_210\n'
            elif seam == 'frozen':
                body = between(sources['scripts/check_contract_frozen.sh'], '        soglasno=1; chuzhoj=""', '\n        if [ "$soglasno" -eq 1 ]; then')
            else:
                body = between(sources['scripts/check_zones.sh'], '  razrechen=1\n  while IFS= read -r c;', '\n  [ "$razrechen" -eq 1 ] || continue')
            # Same number in zones, no authorization for the companion.
            if seam == 'zones':
                nnn = '810'
            else:
                nnn = '800'
            program = prefix + f'f={quote(f)}\nnnn={nnn}\npred_komity={world.commits["external-edit"]}\n' + body
            if seam == 'frozen':
                program += '\nprintf "%s\\0%s\\0" "$soglasno" "$chuzhoj"\n'
                expected = (0, (b'1\0\0' if clean else b'0\0' + world.path.encode() + b'\0'), b'')
            else:
                program += '\nprintf "%s\\n" "$razrechen"\n'
                expected = (0, b'1\n' if clean else b'0\n', b'')
        elif seam in ('owner', 'ownerread'):
            path = 'docs/owner/' + cell.slug + '.md'
            world.commit('owner-base', {path: b'old\n'})
            if cell.shape == 'history':
                world.commit('owner-left', {'left.txt': b'left\n'})
                world.commit('owner-right', {path: b'new\n'}, ['owner-base'])
                world.commit('owner-merge', {path: b'new\n'}, ['owner-left', 'owner-right'])
                sha = world.commits['owner-merge']
                payload = b''
            else:
                world.commit('owner-edit', {path: b'new\n'})
                sha = world.commits['owner-edit']
                payload = path.encode() + b'\0'
            program = prefix + function(sources['.githooks/pre-push'], 'owner_docs_paths') + f'owner_docs_paths {sha}\n'
            expected = (0, payload, b'')
            if seam == 'ownerread':
                body = between(sources['.githooks/pre-push'],
                               '    if [ "$author" != "owner" ]; then',
                               '\n    case "$rref" in')
                program = prefix + function(sources['.githooks/pre-push'], 'owner_docs_paths')
                program += f'c={sha}\nlref=refs/heads/main\nauthor=architect\nrc=0\n' + body
                expected = (0, b'', (f'ОТКАЗ: pre-push: docs/owner/ пишет только owner (канал владельца): ref=refs/heads/main коммит={sha} автор=architect путь={path}\n'.encode() if payload else b''))
        elif seam == '167':
            site, decision = cell.name.split('-')[2:]
            path = 'notes/a"quote.md'
            registry = 'registry/contracts.tsv'
            row1 = b'801 \xe2\x86\x92 ' + b'a' * 40 + b'\n'
            row2 = b'802 \xe2\x86\x92 ' + b'b' * 40 + b'\n'
            world.commit('merge-base', {registry: b'', path: b'base\n'})
            if site in ('d1', 'd2'):
                # Identical overlap merges cleanly, but 167 disallows it.
                left = {path: b'same\n'}
                right = {path: b'same\n'}
                if decision == 'allow':
                    right = {'other.txt': b'other\n'}
                world.commit('left', left)
                world.commit('right', right, ['merge-base'])
                merged = {**left, **right}
                wanted = 1 if decision == 'deny' else 0
            else:
                # Registry union enters the second pair of diff readers.
                left = {registry: row1, path if site == 'cm2' else 'left.txt': b'left\n'}
                right = {registry: row2, path if site == 'cm' else 'right.txt': b'right\n'}
                world.commit('left', left)
                world.commit('right', right, ['merge-base'])
                merged = {**left, **right, registry: row1 + row2}
                if decision == 'deny':
                    merged[path] = b'evil merge\n'
                wanted = 1 if decision == 'deny' else 0
            world.commit('merge-result', merged, ['left', 'right'])
            program = prefix + function(sources['.githooks/pre-push'], 'reg_167_stroka') + function(sources['.githooks/pre-push'], 'merge_167_razreshen')
            program += f'LIVE_MAIN={world.commits["right"]}\nmerge_167_razreshen {world.commits["merge-result"]} refs/heads/wip/810/architect\nprintf "%s\\n" "$?"\n'
            expected = (0, str(wanted).encode() + b'\n', b'')
        else:
            raise p.Prerequisite('UNKNOWN_SEAM: ' + seam)
        if override:
            # Explicit alternate expectations for each addressed mutant, never any rc.
            kind = next(iter(override.values()))
            if kind == 'wire-empty':
                expected = (0, b'', b'')
            elif kind == 'wire-zero':
                expected = (0, b'0\n', b'')
            elif kind == 'wire-frozen-clean':
                expected = (0, b'1\0\0', b'')
            elif kind == 'wire-zones-clean':
                expected = (0, b'1\n', b'')
            elif kind == 'wire-167-allow':
                expected = (0, b'0\n', b'')
            elif kind == 'wire-167-deny':
                expected = (0, b'1\n', b'')
            elif kind == 'wire-owner-line':
                expected = (0, b'"docs/owner/a\\"quote.md"\n', b'')
            elif kind == 'wire-diff-line':
                expected = (0, b'"contracts/810-a\\"quote.md"\n', b'')
            else:
                raise p.Prerequisite('UNKNOWN_MUTANT_EXPECTATION: ' + kind)
        actual = p.command(['bash', '-c', program], cwd=root)
        if actual[0] not in (0, 1):
            raise p.Prerequisite(f'SEAM_ENVIRONMENT {cell.name}: {actual!r}')
        return actual, expected


def quote(value):
    return "'" + value.replace("'", "'\\''") + "'"


def frozen_scope(p, cell, world, sources, override):
    """Whole external CLI: discovery, blob judgment and census, not only v+1."""
    root = world.root
    world.commit('scope-verdict', {'verdicts/critic/contracts-810-v1.md': b'accept\n'},
                 [world.head])
    p.git(root, 'update-ref', 'refs/heads/main', world.commits['scope-verdict'])
    summary = '\nпланов и контрактов на HEAD: 1 · черновиков: {} · заморожено: {} · реестр: full\n'
    path = world.path
    if cell.shape == 'draft':
        expected = (0, b'', (f'  ok   {path} — черновик, не заморожен\n' + summary.format(1, 0)).encode())
    elif cell.shape == 'edit':
        # Blob IDs are taken from the input bytes before invoking the subject.
        head_blob = p.git(root, 'hash-object', '--stdin', data=b'after freeze\n').strip().decode()
        tag_blob = p.git(root, 'hash-object', '--stdin', data=cell.value).strip().decode()
        reason = (f'  FAIL {path} изменён без новой заморозки: на HEAD блоб {head_blob}, '
                  f'в заморозке v1 — {tag_blob}. Выход: новый вердикт критика v2, '
                  'freeze_contract.sh и строка РАЗРЕШИЛ-ВЛАДЕЛЕЦ: в изменяющем коммите\n')
        expected = (1, b'', (reason + summary.format(0, 1)).encode())
    else:
        expected = (0, b'', (f'  ok   {path} — заморожен v1, блоб совпадает побайтово, '
                            'вердикты v1..v1 разрешают\n' + summary.format(0, 1)).encode())
    if override:
        expected = (0, b'', '\nпланов и контрактов на HEAD: 0 · черновиков: 0 · заморожено: 0 · реестр: full\n'.encode())
    if 'reader-model.sh' in sources:
        raw = sources['scripts/check_contract_frozen.sh']
        start = raw.index(b'\ng ls-tree', raw.index('# ── предмет:'.encode()))
        end = raw.index('# Все теги'.encode(), start)
        old = raw[start:end]
        raw = raw.replace(old, b'\n. "$ROOT/reader-model.sh"\nfrozen_scope_210\n\n', 1)
        loop = b'while IFS= read -r f; do'
        if raw.count(loop) != 1:
            raise p.Prerequisite('FROZEN_SCOPE_LOOP_NOT_UNIQUE')
        raw = raw.replace(loop, b'while IFS= read -r -d "$scope_delimiter_210" f; do', 1)
        (root / 'scripts/check_contract_frozen.sh').write_bytes(raw)
    before = p.snapshot(root)
    actual = p.command(['bash', root / 'scripts/check_contract_frozen.sh', root], cwd=root)
    if actual[0] not in (0, 1):
        raise p.Prerequisite(f'FROZEN_SCOPE_ENVIRONMENT: {actual!r}')
    if p.snapshot(root) != before:
        raise p.Prerequisite('FROZEN_SCOPE_MUTATED_WORLD')
    return actual, expected


def zones_tree(p, cell, world, sources, tmp, override):
    """Address the two independent selectors, with the real zone parser downstream."""
    root = world.root
    head = cell.name.startswith('wire-zoneshead-')
    invalid = cell.name.endswith('-invalid')
    body = 'ЗОНА broken\n'.encode() if invalid else ('ЗОНА architect: ' + ('head/' if head else 'frozen/') + '\n').encode()
    # The frozen source and HEAD deliberately disagree: reading the wrong ref is red.
    if not head:
        world.commit('zones-freeze', {world.path: body})
        p.git(root, 'tag', '-d', 'frozen/contracts/810/1')
        world.annotate('frozen/contracts/810/1', 'zones-freeze')
    world.commit('zones-head', {world.path: body if head else 'ЗОНА architect: decoy/\n'.encode(),
                               'verdicts/critic/contracts-810-v2.md': b'accept\n'},
                 message=f'РАЗРЕШИЛ-ВЛАДЕЛЕЦ: {world.path} authorized\n')
    p.git(root, 'update-ref', 'refs/heads/main', world.commits['zones-head'])
    raw = sources['scripts/check_zones.sh']
    if head:
        reader = between(raw, '  file_head="$(', '\n  [ -n "$body_head" ]')
        selected, contents = 'file_head', 'body_head'
        entry = 'zones_head_tree_210'
    else:
        reader = between(raw, '    file="$(g ls-tree', '\n  fi\n\n  declared=0')
        selected, contents = 'file', 'body'
        entry = 'zones_tag_tree_210'
    if 'reader-model.sh' in sources:
        reader = sources['reader-model.sh'].decode() + '\n' + entry + '\n'
    program = f'ROOT={quote(str(root))}\nTMP={quote(str(tmp))}\n' + '''
set -euo pipefail
. "$ROOT/scripts/lib_zones.sh"
g() { git -C "$ROOT" "$@"; }
file= body= file_head= body_head= vmax=1
: > "$TMP/zones_scoped"
: > "$TMP/zones_violations"
for nnn in 810; do
''' + reader + f'''
  zones_declare_rows "$nnn" "${{{selected}}}" "$TMP" < <(printf '%s\\n' "${{{contents}}}" | grep '^ЗОНА ' || true)
done
printf '%s\\0%s\\0' "${{{selected}}}" "${{{contents}}}"
cat "$TMP/zones_scoped" "$TMP/zones_violations"
'''
    payload = world.path.encode() + b'\0' + body.rstrip(b'\n') + b'\0'
    if invalid:
        payload += b'810\0' + world.path.encode() + b'\0bad_author\0broken\0\0' + body
    else:
        payload += b'architect\t' + (b'head/' if head else b'frozen/') + b'\t810\n'
    expected = (0, b'\0\0' if override else payload, b'')
    actual = p.command(['bash', '-c', program], cwd=root)
    if actual[0] not in (0, 1):
        raise p.Prerequisite(f'ZONES_TREE_ENVIRONMENT: {actual!r}')
    return actual, expected

def route(p, cell, world, sources):
    """Live next_id -> mint_line -> ordinary commit, with the real pre-commit."""
    root = world.root
    changes = {**sources, 'contracts/900-zones.md':
               b'ZONES\n\n\xd0\x97\xd0\x9e\xd0\x9d\xd0\x90 architect: contracts/ plans/\n\xd0\x97\xd0\x9e\xd0\x9d\xd0\x90 orchestrator: registry/\n',
               'registry/contracts.tsv': b''}
    world.commit('route-seed', changes)
    world.annotate('frozen/contracts/900/1', 'route-seed')
    p.git(root, 'update-ref', 'refs/heads/main', world.commits['route-seed'])
    p.git(root, 'read-tree', '--reset', '-u', 'HEAD')
    p.git(root, 'config', 'core.fileMode', 'false')
    (root / '.githooks/pre-commit').chmod(0o755)
    p.git(root, 'config', 'core.hooksPath', '.githooks')

    def publish():
        shutil.rmtree(world.origin)
        p.git(root, 'clone', '-q', '--bare', '--no-hardlinks', root, world.origin)

    publish()
    identity = 'export GIT_AUTHOR_NAME=architect GIT_AUTHOR_EMAIL=architect@dev-harness.local GIT_COMMITTER_NAME=architect GIT_COMMITTER_EMAIL=architect@dev-harness.local; '
    issue = p.command(['bash', '-c', identity + 'bash "$1/scripts/next_id.sh" "$1" CONTRACT', 'route', root], cwd=root)
    if issue != (0, b'901\n', b''):
        raise p.Prerequisite(f'LIVE_ROUTE_ISSUE: {issue!r}')
    publish()
    mint = p.command(['bash', root / 'scripts/mint_line.sh', '--root', root, '--nnn', '901'], cwd=root)
    if mint[0] != 0 or not mint[1].startswith(b'MINTED nnn=901 sha='):
        raise p.Prerequisite(f'LIVE_ROUTE_MINT: {mint!r}')
    publish()
    p.git(root, 'switch', '-q', '-c', 'wip/901/architect')
    path = 'contracts/901-' + cell.slug + '.md'
    target = root / path
    target.write_bytes(b'draft\n')
    p.git(root, 'add', '--', path)
    before = p.git(root, 'rev-parse', 'HEAD')
    commit = p.command(['git', '-C', root, *p.IDENTITY, 'commit', '-q', '-m', '210 live draft'], cwd=root)
    control = any(ord(c) < 32 or ord(c) == 127 for c in cell.slug)
    wanted_rc = 1 if control else 0
    good = commit[0] == wanted_rc
    if control:
        good = good and b'\xd0\x9e\xd0\xa2\xd0\x9a\xd0\x90\xd0\x97: \xd0\xb8\xd0\xbc\xd1\x8f \xd1\x81 control-\xd1\x81\xd0\xb8\xd0\xbc\xd0\xb2\xd0\xbe\xd0\xbb\xd0\xbe\xd0\xbc:' in commit[2]
        good = good and p.git(root, 'rev-parse', 'HEAD') == before
    else:
        good = good and path.encode() in commit[2]
        good = good and p.git(root, 'show', 'HEAD:' + path) == b'draft\n'
    actual = (0 if good else 1, b'ISSUE=0 MINT=0 DRAFT=' + str(commit[0]).encode() + b'\n', b'' if good else repr(commit).encode())
    return actual, (0, b'ISSUE=0 MINT=0 DRAFT=' + str(wanted_rc).encode() + b'\n', b'')
