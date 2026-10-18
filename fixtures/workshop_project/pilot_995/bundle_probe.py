#!/usr/bin/env python3
"""Observe Metro's Android export graph, independently of the Jest resolver."""
import argparse
from contextlib import nullcontext
import json
import os
from pathlib import Path
import posixpath
import subprocess
import sys
import tempfile
import time
from runtime_probe import HERE, installed

MUTANTS = [
    ('metro-always-mock', 'BUNDLE_HTTP_HAS_MOCKS'),
    ('metro-always-http', 'BUNDLE_MOCK_HAS_HTTP_RUNTIME'),
]


def sources(payload):
    result = set()
    for source in payload.get('sources', []):
        path = posixpath.normpath(source.replace('\\', '/'))
        parts = path.split('/')
        if 'node_modules' not in parts and 'src' in parts:
            result.add('/'.join(parts[parts.index('src'):]))
    for section in payload.get('sections', []):
        result.update(sources(section['map']))
    return result


def model_files(mobile, model):
    # Capture fixture bytes before any export process executes subject code.
    composition = (HERE / 'model.tsx').read_text()
    composition = composition.replace('./__tests__/source.json', './bundle-source.json')
    composition = "import { runtime } from '@pilot/runtime';\n" + composition
    composition = composition.replace('demoAuth, api = demoApi', 'runtime.auth, api = runtime.api')
    composition = composition.replace("setChallenge(result.challenge || email); setFrame('code');", "setChallenge(result.challenge || email); setFrame(result.status === 'unavailable' ? 'unavailable' : 'code');")
    composition = composition.replace("{frame === 'first'", "{frame === 'unavailable' && <Text testID=\"auth-unavailable\">Unavailable</Text>}\n    {frame === 'first'")
    source_bytes = (HERE / 'source.json').read_bytes()
    source = json.loads(source_bytes)
    values = json.dumps({'getSession': source['session'], 'getDisclosure': source['disclosure']}).encode()
    runtime = (HERE / 'runtime-model.ts').read_text().replace("const mutant = process.env.PILOT_995_MODEL;", 'const mutant = undefined;')
    metro = (HERE / 'bundle-metro.js').read_text()
    if model != 'honest':
        mode = 'mock' if model == 'metro-always-mock' else 'http'
        metro = metro.replace("process.env.EXPO_PUBLIC_API_MODE || 'mock'", repr(mode))
    return {
        mobile / 'metro.config.js': metro.encode(),
        mobile / 'src/app/index.tsx': b"export { PilotApp as default } from '../bootstrap/pilot-app';\n",
        mobile / 'src/bootstrap/pilot-app.tsx': composition.encode(),
        mobile / 'src/bootstrap/bundle-source.json': source_bytes,
        mobile / 'src/bootstrap/runtime-values.json': values,
        mobile / 'src/bootstrap/http-runtime.ts': runtime.replace("process.env.EXPO_PUBLIC_API_MODE || 'mock'", "'http'").encode(),
        mobile / 'src/mocks/runtime-values.json': values,
        mobile / 'src/mocks/runtime.ts': runtime.replace("process.env.EXPO_PUBLIC_API_MODE || 'mock'", "'mock'").encode(),
    }


def run(repo, model=None):
    repo = repo.resolve()
    if not repo.is_relative_to('/tmp/dev-harness-verify'):
        raise RuntimeError('DISPOSABLE_REQUIRED')
    mobile = repo / 'mobile'
    if model is None and not (mobile / 'src/bootstrap/pilot-app.tsx').exists():
        print('995 BUNDLE_SEAM_ABSENT')
        return 1, ['BUNDLE_SEAM_ABSENT']
    failures = []
    started = time.monotonic()
    with installed(model_files(mobile, model)) if model else nullcontext():
        for mode in ('http', 'mock'):
            with tempfile.TemporaryDirectory(prefix='bundle995-') as output:
                env = dict(os.environ, EXPO_PUBLIC_API_MODE=mode, CI='1', EXPO_NO_TELEMETRY='1')
                env.pop('PILOT_DEMO_CODE', None)
                proc = subprocess.run(
                    ['npx', 'expo', 'export', '--platform', 'android', '--source-maps', '--clear', '--output-dir', output],
                    cwd=mobile, env=env, capture_output=True, text=True, timeout=180)
                if proc.returncode:
                    raise RuntimeError('EXPO_EXPORT_FAILED:' + mode + ':' + proc.stdout[-1500:] + proc.stderr[-1500:])
                maps = list(Path(output).rglob('*.map'))
                if not maps:
                    raise RuntimeError('SOURCE_MAP_ABSENT:' + mode)
                graph = set()
                for path in maps:
                    graph.update(sources(json.loads(path.read_bytes())))
                reasons = []
                if mode == 'http':
                    if any(p.startswith('src/mocks/') for p in graph): reasons.append('BUNDLE_HTTP_HAS_MOCKS')
                    if 'src/bootstrap/http-runtime.ts' not in graph: reasons.append('BUNDLE_HTTP_RUNTIME_ABSENT')
                else:
                    if 'src/bootstrap/http-runtime.ts' in graph: reasons.append('BUNDLE_MOCK_HAS_HTTP_RUNTIME')
                    if 'src/mocks/runtime.ts' not in graph: reasons.append('BUNDLE_MOCK_RUNTIME_ABSENT')
                failures.extend(reasons)
                print(f'995 bundle/{model or "actual"}/{mode}: rc={int(bool(reasons))} maps={len(maps)} sources={len(graph)} reasons={reasons}', flush=True)
    print(f'995 bundle elapsed={time.monotonic() - started:.1f}s')
    return int(bool(failures)), failures


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo', type=Path, required=True)
    parser.add_argument('--matrix', action='store_true')
    parser.add_argument('--model', choices=['honest'] + [name for name, _ in MUTANTS])
    args = parser.parse_args()
    if not args.matrix: return run(args.repo, args.model)[0]
    rows = [('honest', 0, None)] + [(name, 1, reason) for name, reason in MUTANTS]
    mismatches = 0
    for model, expected, reason in rows:
        rc, failures = run(args.repo, model)
        if rc != expected or (reason is not None and reason not in failures): mismatches += 1
    print(f'995 bundle checked={len(rows)} mismatches={mismatches}')
    return int(bool(mismatches))


if __name__ == '__main__':
    try: sys.exit(main())
    except (OSError, RuntimeError, ValueError, KeyError, subprocess.TimeoutExpired) as error:
        print('995 INFRASTRUCTURE:', error, file=sys.stderr)
        sys.exit(2)
