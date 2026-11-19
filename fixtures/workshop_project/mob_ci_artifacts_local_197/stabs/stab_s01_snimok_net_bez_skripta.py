#!/usr/bin/env python3
# Снимок отсутствует ПРИ удалённом каноне субъекта, не модели оракула.
import runpy
import sys
from pathlib import Path

family = Path(sys.argv[1]).resolve()
runpy.run_path(str(Path(__file__).with_name('stab_s01_snimok_otsutstvuet.py')))
(family / 'subject/mobile/scripts/ci-artefakty.cjs').unlink()
