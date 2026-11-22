#!/usr/bin/env python3
"""Print the actual 187 cell/mutant census; reject empty or dangling coverage."""
import json

from workflow_probe import CASES, STABS
from ci_ancestor import CASES as ANCESTOR_CASES, STABS as ANCESTOR_STABS

labels = [case[0] for case in CASES]
missing = sorted({case for case, _ in STABS.values()} - set(labels))
print(json.dumps({'CELLS': len(CASES), 'STABS': len(STABS),
                  'ANCESTOR_CELLS': len(ANCESTOR_CASES),
                  'ANCESTOR_STABS': len(ANCESTOR_STABS),
                  'OLD_CELLS': len(CASES) - len(ANCESTOR_CASES),
                  'OLD_STABS': len(STABS) - len(ANCESTOR_STABS),
                  'DANGLING': missing,
                  'ANCESTOR_LABELS': [case[0] for case in ANCESTOR_CASES]},
                 ensure_ascii=False, indent=2))
raise SystemExit(int(not labels or len(labels) != len(set(labels)) or bool(missing)))
