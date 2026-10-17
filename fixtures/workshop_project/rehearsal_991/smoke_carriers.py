#!/usr/bin/env python3
"""991 Ds5 CLI regression with real Git B/C objects, no Android or cleanup exec.

Run: python3 fixtures/workshop_project/rehearsal_991/smoke_carriers.py
The synthetic workflow and approved Ds5 literal live here, not in /tmp.
Only disposable Git objects are created under this fixture directory and removed.
"""
from copy import deepcopy
from pathlib import Path
import subprocess
import sys
from tempfile import TemporaryDirectory

import yaml
from compare_carriers import PINS, parse, snapshot
from matrix_carriers import honest

HERE = Path(__file__).resolve().parent
MOBILE = '.github/workflows/mobile.yml'
CLOUD = '.github/workflows/mobile-cloud-e2e.yml'
DISK = yaml.safe_load('''
name: Освобождение диска перед cloud-эмулятором
id: rehearsal_disk_space
shell: bash
working-directory: .
run: |
  df -h /
  sudo rm -rf -- /usr/share/dotnet /usr/local/lib/android/sdk/ndk /opt/ghc /usr/local/.ghcup /opt/hostedtoolcache/CodeQL
  df -h /
''')


def workflow(cloud):
    return {
        'name': 'synthetic-cloud' if cloud else 'synthetic-station',
        'on': {'push': {'branches': ['main']}, 'workflow_dispatch': {}},
        'jobs': {
            'expo-versions' if cloud else 'quality': {
                'runs-on': 'ubuntu-24.04',
                'steps': [
                    {'uses': 'actions/checkout@v4', 'with': {'persist-credentials': False}},
                    {'run': 'npm test'},
                ],
            },
            'android-e2e-cloud' if cloud else 'android-e2e': {
                'runs-on': 'ubuntu-24.04',
                'steps': [
                    {'name': 'Maestro', 'run': 'install-maestro'},
                    {'name': 'Release APK', 'run': './gradlew assembleRelease'},
                    {'name': 'KVM', 'run': 'enable-kvm'},
                    {'name': 'Эмулятор API 36 + сценарии Maestro',
                     'uses': 'reactivecircus/android-emulator-runner@v2',
                     'with': {'api-level': 36, 'script': 'maestro test .maestro'}},
                    {'name': 'Артефакты (скриншоты, отчёт)',
                     'uses': 'actions/upload-artifact@v7', 'if': 'always()',
                     'with': {'name': 'maestro', 'path': 'mobile/maestro-out', 'if-no-files-found': 'warn'}},
                ],
            },
        },
    }


def main():
    with TemporaryDirectory(prefix='.carrier-smoke-', dir=HERE) as directory:
        repo = Path(directory)

        def git(*args):
            return subprocess.check_output([
                'git', '-C', str(repo), '-c', 'user.name=architect',
                '-c', 'user.email=architect@dev-harness.local', *args,
            ], stderr=subprocess.STDOUT).decode().strip()

        def put(path, data):
            target = repo / path
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(data)

        def commit(label):
            git('add', '--all', str(repo))
            git('commit', '-qm', label)
            return git('rev-parse', 'HEAD')

        def run(label, base, head=None, phase=None, expected=0):
            args = [sys.executable, str(HERE / 'compare_carriers.py'),
                    '--repo', str(repo), '--base', base]
            args += ['--head', head, '--phase', phase] if head else ['--matrix']
            result = subprocess.run(args, capture_output=True, text=True)
            print(result.stdout, end='')
            print(result.stderr, end='', file=sys.stderr)
            print(f'991 CLI/{label}: rc={result.returncode} expected={expected}', flush=True)
            if result.returncode != expected:
                raise AssertionError(label)
            if expected == 1 and 'CARRIER_CHANGED:' not in result.stdout:
                raise AssertionError(f'{label}: wrong diagnosis')

        git('init', '-q')
        for path, cloud in ((MOBILE, False), (CLOUD, True)):
            put(path, yaml.safe_dump(workflow(cloud), allow_unicode=True).encode())
        put('mobile/src/features/start/__tests__/start-screen.test.tsx', b'// unchanged old test\n')
        put('mobile/.maestro/start.yaml', b'appId: com.complior.mobile\n---\n- launchApp\n')
        put('mobile/scripts/ci-e2e.sh', b'maestro test .maestro\n')
        original = commit('synthetic original B')
        pins = {path: (HERE / fixture).read_bytes() for path, (fixture, _) in PINS.items()}
        frozen = honest(snapshot(repo, original), 'freeze', pins)
        for path, data in frozen.items():
            put(path, data)
        base = commit('synthetic freeze B')
        candidate = honest(frozen, 'positive', pins)
        cloud = parse(candidate[CLOUD])
        steps = cloud['jobs']['android-e2e-cloud']['steps']
        steps[3] = deepcopy(DISK)  # Independent approved YAML literal above.
        candidate[CLOUD] = yaml.safe_dump(cloud, allow_unicode=True).encode()
        for path, data in candidate.items():
            put(path, data)
        positive = commit('honest Ds5 C')
        run('honest-positive', base, positive, 'positive')
        missing_cloud = deepcopy(cloud)
        missing_cloud['jobs']['android-e2e-cloud']['steps'].pop(3)
        put(CLOUD, yaml.safe_dump(missing_cloud, allow_unicode=True).encode())
        missing = commit('positive C without Ds5')
        run('missing-Ds5', base, missing, 'positive', 1)
        steps[3]['run'] += 'true\n'
        put(CLOUD, yaml.safe_dump(cloud, allow_unicode=True).encode())
        altered = commit('changed Ds5 text')
        run('altered-Ds5', base, altered, 'positive', 1)
        steps[3] = deepcopy(DISK)
        steps.insert(4, steps.pop(3))
        put(CLOUD, yaml.safe_dump(cloud, allow_unicode=True).encode())
        moved = commit('moved Ds5 after emulator')
        run('moved-Ds5', base, moved, 'positive', 1)
        run('matrix', original)
    return 0


if __name__ == '__main__':
    sys.exit(main())
