#!/usr/bin/env python3
"""Шов systemctl. Не оракул: эффект freeze виден в cgroup.events."""
import json
import os
from pathlib import Path
import sys

state = json.loads(Path(os.environ['CI225_STATE']).read_text())
command, unit = sys.argv[1:3]
with Path(os.environ['CI225_JOURNAL']).open('a') as stream:
    stream.write(json.dumps([command, unit]) + '\n')
if state['fail'] == command:
    sys.exit(1)
info = state['units'][unit]
group = Path(os.environ['CI225_CGROUP']) / info['group'].lstrip('/')
if command == 'show':
    print('ActiveState=' + info['active'])
    print('ControlGroup=' + info['group'])
elif command == 'freeze':
    if state['fail'] != 'not-frozen':
        (group / 'cgroup.events').write_text('populated 1\nfrozen 1\n')
    if state['race']:
        (group / 'cgroup.procs').write_text('65432\n')
        proc = Path(os.environ['CI225_PROC']) / '65432'
        proc.mkdir(exist_ok=True)
        conf = json.loads(Path(os.environ['CI_CLEAN_CONFIG']).read_text())
        (proc / 'comm').write_text(conf['tmp']['worker_names'][0] + '\n')
elif command == 'thaw':
    (group / 'cgroup.events').write_text('populated 1\nfrozen 0\n')
else:
    sys.exit(1)
