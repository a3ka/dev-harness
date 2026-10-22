#!/usr/bin/env python3
"""Стаб: вместо отдельных областей CTA судит весь экран глобально.
На узком исчезновении нижнего Dokument öffnen принятие ошибочно зелёное.
"""
import json
import sys
from pathlib import Path
from _model import m, run

pack = Path(sys.argv[sys.argv.index('--pack') + 1])
repo = Path(sys.argv[sys.argv.index('--repo') + 1])
for path in (pack/'kadry.json', repo/'.harness123/kadry.json'):
    man = json.loads(path.read_text())
    for k in man['kadry']:
        k['elementy'] = [{'imja':'ekran','bbox_pt':[0,0,390,844]}]
    path.write_text(json.dumps(man))
run()
