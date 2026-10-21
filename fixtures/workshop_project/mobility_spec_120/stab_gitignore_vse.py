#!/usr/bin/env python3
# Обманный оракул (строже честного): честный оракул 120 с ОДНОЙ подменённой функцией —
# gitignore_neotslezhivaemye считает вне зоны КАЖДЫЙ неотслеживаемый .gitignore, не сверяя,
# скрыт ли он отслеживаемым .gitignore. Батарея обязана поймать его на g01 (честные
# node_modules краснеют) и НЕ ловить на d51, где краснота честна.
import importlib.util
import os
import subprocess
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)


def _vse(repo, spec_pre):
    gi = subprocess.run(["git", "-C", repo, "ls-files", "-z", "--others", "--", ":(glob)**/.gitignore"],
                        capture_output=True)
    return [x for x in gi.stdout.decode("utf-8", "surrogateescape").split("\0") if x and not x.startswith(spec_pre)]


O.gitignore_neotslezhivaemye = _vse
sys.exit(O.main(sys.argv[1:]))
