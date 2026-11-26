#!/usr/bin/env bash
# Reference only: the implementation may choose another parser with the same API.
owner_override_validate() {
  owner_override_has --validate -
}

owner_override_has() { # <key> <sha40|-> [path] [author]; ROOT is the judged repo.
  python3 - "${ROOT:?owner_override ROOT is required}" "$@" <<'PY'
import datetime
from pathlib import Path
import re
import sys

root, key, sha, *context = sys.argv[1:]
path = context[0] if context else '-'
author = context[1] if len(context) > 1 else '*'
registry = Path(root) / 'registry/owner-overrides.tsv'
keys = {'check_charter/grandfather', 'check_charter/permit', 'check_protected/delete',
        'check_zones/mint', 'check_zones/process', 'check_zones/skip-version',
        'check_contract_frozen/skip-version'}


def fail(line, reason):
    print(f'OWNER_OVERRIDES_INVALID: registry/owner-overrides.tsv:{line}: {reason}', file=sys.stderr)
    sys.exit(2)


def scope_ok(value):
    if value == '*':
        return True
    return (re.fullmatch(r'[A-Za-z0-9._/-]+(?:\*)?', value) is not None
            and not value.startswith('/') and all(p not in ('.', '..', '') for p in value.removesuffix('/*').split('/'))
            and ('*' not in value or value.endswith('/*')))


if key != '--validate':
    if key not in keys:
        fail('argument', 'unknown key')
    if not (re.fullmatch('[0-9a-f]{40}', sha) or sha == '-' and key.endswith('/skip-version')):
        fail('argument', 'sha')
if len(context) > 2:
    fail('argument', 'arity')
try:
    raw = registry.read_bytes()
except FileNotFoundError:
    sys.exit(0 if key == '--validate' else 1)
except OSError:
    fail(0, 'unreadable file')
if raw and not raw.endswith(b'\n'):
    fail(raw.count(b'\n') + 1, 'missing LF')
if b'\0' in raw:
    fail(raw[:raw.index(b'\0')].count(b'\n') + 1, 'NUL')
try:
    text = raw.decode('ascii')
except UnicodeDecodeError:
    fail(0, 'non-ASCII')
rows = []
seen = set()
for line_no, line in enumerate(text.split('\n')[:-1], 1):
    fields = line.split('\t')
    if len(fields) != 6:
        fail(line_no, 'six TAB fields required')
    gate, oid, scope, actor, reason, until = fields
    if gate not in keys:
        fail(line_no, 'unknown key')
    if not (re.fullmatch('[0-9a-f]{40}', oid) or oid == '-' and gate.endswith('/skip-version')):
        fail(line_no, 'sha')
    if not scope_ok(scope) or not re.fullmatch(r'\*|[A-Za-z0-9._-]+', actor):
        fail(line_no, 'scope or actor')
    if not re.fullmatch('R-[0-9]{4}', reason):
        fail(line_no, 'reason')
    if until != 'never':
        try:
            if datetime.date.fromisoformat(until).isoformat() != until:
                raise ValueError()
        except ValueError:
            fail(line_no, 'expiry')
    identity = tuple(fields[:4])
    if identity in seen:
        fail(line_no, 'duplicate')
    seen.add(identity)
    rows.append(fields)
if key == '--validate':
    sys.exit(0)
for gate, oid, scope, actor, reason, until in rows:
    if until != 'never' and datetime.date.today().isoformat() > until:
        continue
    if gate != key or oid != sha:
        continue
    if context and scope != '*' and not (scope == path or scope.endswith('/*') and path.startswith(scope[:-1])):
        continue
    if context and actor != '*' and actor != author:
        continue
    sys.exit(0)
sys.exit(1)
PY
}
