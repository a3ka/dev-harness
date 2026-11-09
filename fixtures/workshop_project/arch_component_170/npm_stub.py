#!/usr/bin/env python3
"""Project npm boundary: accept exactly the published compact-brief argv."""
import os
from pathlib import Path
import sys

args = sys.argv[1:]
root = Path(os.environ['ARCH170_PROJECT'])
if (len(args) not in (8, 9) or args[:2] != ['--prefix', str(root / 'architecture')]
        or args[2:6] != ['run', 'brief', '--', '--compact']):
    sys.stderr.write('INVALID_BRIEF_ARGV\n')
    sys.exit(41)
if args[6:8] == ['--with-rules', '--component'] and len(args) == 9:
    rules, component = True, args[8]
elif args[6] == '--component' and len(args) == 8:
    rules, component = False, args[7]
else:
    sys.stderr.write('INVALID_BRIEF_ARGV\n')
    sys.exit(41)
if component not in ('api.identity', 'worker.events'):
    sys.stderr.write('UNKNOWN_COMPONENT\n')
    sys.exit(42)
if os.environ.get('ARCH170_FAIL_ID') == component:
    print('npm notice: brief command failed', file=sys.stderr)
    sys.exit(17)
print('# ARCH-BRIEF:' + component)
print('OWN-CONTRACT:' + component + ':' + os.environ['ARCH170_NONCE'])
if os.environ.get('ARCH170_PADDING'):
    print('ARCH-BRIEF-PADDING:' + 'X' * int(os.environ['ARCH170_PADDING']))
if rules:
    print('FITNESS-RULE-FOR:' + component)
