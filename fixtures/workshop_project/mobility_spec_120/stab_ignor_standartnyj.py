#!/usr/bin/env python3
# Обманный оракул: честный оракул 120 с ОДНОЙ подменённой функцией — neotslezhivaemye
# видит неотслеживаемое через `--exclude-standard` (верит `.git/info/exclude` и
# core.excludesFile, как оракул круга 2). Батарея обязана поймать его на d50 (таблица STABS
# раннера) и НЕ ловить на d51 той же причины: самоигнорирующий .gitignore ловит соседняя ветвь.
import importlib.util
import os
import subprocess
import sys

_p = os.path.join(os.path.dirname(os.path.abspath(__file__)), "mobility_spec_oracle.py")
_s = importlib.util.spec_from_file_location("mobility_spec_oracle", _p)
O = importlib.util.module_from_spec(_s)
_s.loader.exec_module(O)


def _standart(repo, spec_pre):
    u = subprocess.run(["git", "-C", repo, "ls-files", "-z", "--others", "--exclude-standard"],
                       capture_output=True)
    return [x for x in u.stdout.decode("utf-8", "surrogateescape").split("\0") if x and not x.startswith(spec_pre)]


O.neotslezhivaemye = _standart
sys.exit(O.main(sys.argv[1:]))
