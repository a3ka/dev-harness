#!/usr/bin/env python3
"""Exercise existing ESLint transport policy; no second source-scanning convention."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
from runtime_probe import installed


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--repo', type=Path, required=True)
    p.add_argument('--matrix', action='store_true')
    a = p.parse_args()
    mobile = a.repo.resolve() / 'mobile'
    eslint = mobile / 'node_modules/eslint/bin/eslint.js'
    if not a.matrix:
        files = [str(p) for root in ['src/app', 'src/features/auth', 'src/features/onboarding', 'src/bootstrap'] for p in (mobile / root).rglob('*.tsx') if '__tests__' not in p.parts]
        if not files: raise RuntimeError('EMPTY_SCREEN_SET')
        return subprocess.run(['node', str(eslint), '--format', 'json', *files], cwd=mobile).returncode
    rows = [
        ('honest', 'export const screen = (client: { getSession(): void }) => client.getSession();', 0, 'src/features/auth/pilot-app.tsx', ''),
        ('fetch', 'export const screen = () => fetch("https://example.invalid");', 1, 'src/features/auth/pilot-app.tsx', 'no-restricted-globals'),
        ('global', 'export const screen = () => global.fetch("https://example.invalid");', 1, 'src/features/auth/pilot-app.tsx', 'no-restricted-globals'),
        ('runtime-alias', 'export { runtime } from "@pilot/runtime";', 0, 'src/bootstrap/pilot-app.tsx', ''),
        ('bootstrap-mocks', 'export { default } from "../mocks/pilot-responses.json";', 1, 'src/bootstrap/pilot-app.tsx', 'import/no-restricted-paths'),
    ]
    config_path = mobile / 'tsconfig.json'
    config = json.loads(config_path.read_text())
    config['compilerOptions']['paths']['@pilot/runtime'] = ['./src/bootstrap/runtime-contract.d.ts']
    files = {
        config_path: json.dumps(config).encode(),
        mobile / 'src/bootstrap/runtime-contract.d.ts': b'export declare const runtime: { api: { getSession(): Promise<unknown> } };\n',
        mobile / 'src/mocks/pilot-responses.json': b'{}\n',
    }
    with installed(files):
        for name, text, expected, filename, rule in rows:
            run = subprocess.run(['node', str(eslint), '--format', 'json', '--stdin', '--stdin-filename', filename], cwd=mobile, input=text, text=True, capture_output=True)
            if run.returncode not in (0, 1): raise RuntimeError(run.stderr)
            messages = [m for f in json.loads(run.stdout) for m in f['messages']]
            rc = int(bool(messages))
            if rc != expected or (expected and not any(m['ruleId'] == rule for m in messages)):
                raise RuntimeError('WRONG_TRANSPORT_REASON: ' + run.stdout)
            print(f'995 transport/{name}: rc={run.returncode} rules={[m["ruleId"] for m in messages]}')
    print(f'995 transport checked={len(rows)}')
    return 0


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr); sys.exit(2)
