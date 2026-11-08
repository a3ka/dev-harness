#!/usr/bin/python3
"""Pretend the broken live gate ran; delegate all other bash scripts normally."""
import os
import subprocess
import sys
import time


if len(sys.argv) > 2 and os.path.basename(sys.argv[1]) == 'check_pustoj_produkt.sh':
    marker = os.environ.get('PUSTOJ_PATH_SPOOF_MARKER')
    if marker:
        with open(marker, 'w', encoding='utf-8') as output:
            output.write('fake bash intercepted gate\n')
    trace = os.environ.get('PUSTOJ_PRODUKT_TRACE')
    if trace:
        with open(trace, 'a', encoding='utf-8') as output:
            output.write('%d GATE %s\n' % (time.time_ns(), ' '.join(sys.argv[2:])))
    sys.exit(subprocess.call([sys.executable, os.environ['PUSTOJ_PATH_MODEL'],
                              *sys.argv[2:]]))
os.execv('/usr/bin/bash', ['/usr/bin/bash', *sys.argv[1:]])
