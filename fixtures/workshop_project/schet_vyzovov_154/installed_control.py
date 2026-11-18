#!/usr/bin/env python3
"""Exercise installed-mode CLI paths against an honest insertion, never production files."""
import sys
import tempfile
from pathlib import Path

import probe


def main():
    modes = sys.argv[1:] or ['repo', 'domain', 'live', 'grammar']
    if any(m not in ('repo', 'domain', 'live', 'grammar') for m in modes):
        print('NOT_IMPLEMENTED: expected repo/domain/live/grammar', file=sys.stderr)
        return 2
    original = probe.ROOT
    with tempfile.TemporaryDirectory(prefix='schet154-installed-') as tmp:
        root = Path(tmp)
        # These are real copies of both CLI scripts, patched by the existing model
        # seam. Subsequent repo/live/grammar calls only read the installed scripts.
        probe.prepare_scripts(root, 'model')
        (root / 'fixtures').symlink_to(original / 'fixtures', target_is_directory=True)
        probe.ROOT = root
        try:
            for mode in modes:
                sys.argv = ['probe.py', mode]
                rc = probe.main()
                print(f'INSTALLED_CONTROL {mode} rc={rc}', flush=True)
                if rc:
                    return rc
        finally:
            probe.ROOT = original
    return 0


if __name__ == '__main__':
    sys.exit(main())
