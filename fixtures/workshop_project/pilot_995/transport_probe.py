#!/usr/bin/env python3
"""Exercise existing ESLint transport policy; no second source-scanning convention."""
import argparse
import json
from pathlib import Path
import subprocess
import sys


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, required=True)
    p.add_argument('--matrix', action='store_true')
    a = p.parse_args()
    mobile = a.repo.resolve() / 'mobile'
    eslint = mobile / 'node_modules/eslint/bin/eslint.js'
    if not a.matrix:
        files = [str(p) for root in ['src/app', 'src/features/auth'] for p in (mobile / root).rglob('*.tsx') if '__tests__' not in p.parts]
        if not files: raise RuntimeError('EMPTY_SCREEN_SET')
        return subprocess.run(['node', str(eslint), '--format', 'json', *files], cwd=mobile).returncode
    rows = [
        ('honest', 'export const screen = (client: { getSession(): void }) => client.getSession();', 0),
        ('fetch', 'export const screen = () => fetch("https://example.invalid");', 1),
        ('global', 'export const screen = () => global.fetch("https://example.invalid");', 1),
    ]
    for name, text, expected in rows:
        run = subprocess.run(['node', str(eslint), '--format', 'json', '--stdin', '--stdin-filename', 'src/features/auth/pilot-app.tsx'], cwd=mobile, input=text, text=True, capture_output=True)
        if run.returncode not in (0, 1): raise RuntimeError(run.stderr)
        messages = [m for f in json.loads(run.stdout) for m in f['messages']]
        rc = int(bool(messages))
        if rc != expected or (expected and not any(m['ruleId'] == 'no-restricted-globals' for m in messages)):
            raise RuntimeError('WRONG_TRANSPORT_REASON: ' + run.stdout)
        print(f'995 transport/{name}: rc={run.returncode} rules={[m["ruleId"] for m in messages]}')
    print('995 transport checked=3')
    return 0


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
