"""Стаб: в каталоге кадров нет ни одного PNG — «нечего проверять», rc 0."""
import glob
import os
import sys

from _model import m

_orig = m.main


def main(argv=None):
    args = sys.argv[1:] if argv is None else argv
    kadry = args[args.index('--kadry') + 1]
    if not glob.glob(os.path.join(glob.escape(kadry), '**', '*.png'), recursive=True):
        return 0
    return _orig(argv)


sys.exit(main())
