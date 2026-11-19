#!/usr/bin/env python3
# Снимок испорчен ПРИ удалённом каноне субъекта.
import runpy
import sys
from pathlib import Path

family = Path(sys.argv[1]).resolve()
runpy.run_path(str(Path(__file__).with_name('stab_s01_snimok_isporchen.py')))
(family / 'subject/mobile/scripts/ci-artefakty.cjs').unlink()
