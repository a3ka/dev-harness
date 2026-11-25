#!/usr/bin/env python3
"""Print installed runtime source windows, not a reimplementation of its API."""
import hashlib
import pathlib
import shutil
import sys


def main():
    exe = shutil.which('omp')
    if not exe:
        print('NOT_IMPLEMENTED: omp absent', file=sys.stderr)
        return 2
    data = pathlib.Path(exe).read_bytes()
    print('binary', exe, 'sha256', hashlib.sha256(data).hexdigest())
    needles = sys.argv[1:] or ['function $xe(i) {', 'function zDe(t, e) {', 'async function npt(o, e) {', 'sendUserMessage: (e, t) => {', 'function jte(t, i, o) {', 'var be = /\\bcyber_policy\\b', 'var vt = /\\b(?:incomplete:\\s*)?content_filter']
    count = 0
    for needle in needles:
        start = 140_000_000
        for _ in range(8):
            pos = data.find(needle.encode(), start)
            if pos < 0:
                break
            print('\nSOURCE', needle, 'byte', pos)
            count += 1
            source = data.rfind(b'// packages/', 140_000_000, pos)
            if source >= 0:
                end = data.find(b'\n', source)
                print('FILE', data[source:end].decode(), 'line', data[source:pos].count(b'\n') + 1)
            print(data[max(0, pos - 250):pos + 2000].decode('utf-8', errors='replace'))
            start = pos + len(needle)
    print('sources=%d' % count)
    return 0 if count else 2


if __name__ == '__main__':
    sys.exit(main())
