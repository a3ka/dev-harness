#!/usr/bin/env -S python3 -B
"""Replay Rev227 R9 against production in a disposable committed-tree clone."""
from pathlib import Path
import sys
import tempfile

import build
import probe


def main():
    parent = probe.ROOT / 'tmp' / 'scratch-arch227c'
    parent.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='reviewer-r9-', dir=parent) as tmp:
        root = Path(tmp) / 'repo'
        probe.required(['git', 'clone', '--shared', '--quiet', str(probe.ROOT), str(root)], probe.ROOT)
        script = root / build.SCRIPT
        text = script.read_text()
        for old, new in (("':(top,literal)'", "':(top)'"),
                         ("':(exclude,top,literal)'", "':(exclude,top)'")):
            if text.count(old) != 1:
                raise probe.Unavailable('REVIEWER_R9_ANCHOR: ' + old)
            text = text.replace(old, new, 1)
        script.write_text(text)
        probe.required(['bash', '-n', str(script)], root)
        family = root / build.HERE.relative_to(probe.ROOT)
        result = probe.run(['bash', str(family / 'red_zashivki_otchet_227.sh'), '--repo', str(root)], root)
        print('REVIEWER_R9 --repo rc', result.returncode, flush=True)
        sys.stdout.buffer.write(result.stdout)
        sys.stderr.buffer.write(result.stderr)
        lines = result.stdout.decode().splitlines()
        red = {line.split(' RED ', 1)[0]: line.split(' RED ', 1)[1]
               for line in lines if ' RED ' in line}
        expected = set(build.LITERAL_INCLUDES + build.LITERAL_EXCLUDES)
        valid = (result.returncode == 1 and set(red) == expected and
                 all(reason == 'REPORT_CONTENT' for reason in red.values()) and
                 lines[-1] == f'KLETKI {len(probe.NAMES)} KRASNYH {len(expected)}')
        return 0 if valid else 1


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (probe.Unavailable, OSError, ValueError) as error:
        print('NOT_IMPLEMENTED: VERIFIER_UNAVAILABLE:', error, file=sys.stderr)
        sys.exit(2)
