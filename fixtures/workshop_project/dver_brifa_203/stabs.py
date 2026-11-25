"""Mutation-to-input bindings live here, not in the contract prose."""
from model import once

# Each binding is a conforming input on which this single defect is observable.
STABS = {
    'unchecked-lock': ('lock-different', 'arch',
        '! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"', 'false'),
    'lock-name-only': ('lock-same-size', 'arch',
        '! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"',
        '[ "$(basename "$tmp/package-lock.json")" != "$(basename "$root/package-lock.json")" ]'),
    'missing-donor-accepted': ('donor-lock-missing', 'arch',
        '[ ! -f "$root/package-lock.json" ] || ! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"',
        '[ -f "$root/package-lock.json" ] && ! cmp -s "$tmp/package-lock.json" "$root/package-lock.json"'),
    'lockless-dependencies': ('pin-lock-missing', 'arch',
        "jq -e '(.dependencies // {}) | length > 0'", "jq -e 'false'"),
    'raised-cap': ('budget-large', 'task', '[ "$VK" -gt 40000 ]', '[ "$VK" -gt 140000 ]'),
    'silent-truncate': ('budget-large', 'arch',
        "  printf '%s\\n' \"$out\"\n", "  printf '%s\\n' \"${out:0:1200}\"\n"),
    'stderr-lost': ('stderr-first', 'arch',
        '"$comp" "$rc" "$err" >&2', '"$comp" "$rc" "" >&2'),
    'stderr-last': ('stderr-first', 'arch',
        'sys.stdin.readline()', 'sys.stdin.readlines()[-1]'),
    'pin-from-head': ('dependencies', 'arch', 'archive "$pin"', 'archive HEAD'),
    'rules-removed': ('rules-architect', 'arch', '--compact --with-rules --component', '--compact --component'),
    'second-diagnostic-lost': ('stderr-second', 'task',
        'die "${_arch_hint:-ARCH_BRIEF_OTKAZ: $_arch_id (пустая диагностика)}"',
        'die "ARCH_BRIEF_OTKAZ: $_arch_id"'),
    'budget-generic': ('budget-large', 'task', 'ARCH_BRIEF_BUDGET:', 'режь задачу:'),
}


def mutate(root, name):
    _, kind, old, new = STABS[name]
    filename = 'check_architecture_contract.sh' if kind == 'arch' else 'make_task.sh'
    file = root / 'scripts' / filename
    text = file.read_text()
    file.write_text(once(text, old, new))
