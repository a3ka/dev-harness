#!/usr/bin/env python3
"""Red battery for the 151 haptic seam; executes Jest in a disposable product environment."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
SUBJECT = 'mobile/src/lib/otdacha/index.ts'
DESIGN_SHA256 = '02fc041ab9d482a10571a096d0175cc8a6c60205bfc168e06fc1de07515debbf'
STABS = {
    # Each witness is where the mutant's behavior differs from the honest control.
    'ios-only': ('if (policy.platform === \'android\') {', "if (policy.platform === 'never') {", 'EMIT_ANDROID_GA_T28_0_E1_V1_Q0'),
    'android-only': ("} else if (policy.platform === 'ios') {", "} else if (policy.platform === 'never') {", 'EMIT_IOS_GA_T28_0_E1_V1_Q0'),
    'weak-long': ("'impactOccurred(.medium)'", "'impactOccurred(.light)'", 'EMIT_IOS_GA_T35_500_E1_V1_Q0'),
    'early-long': ("const pattern = patternFor(scene, at);", "const pattern = patternFor(scene, scene === 'GA-T35' ? 500 : at);", 'UNKNOWN_GA-T35_0'),
    'late-r2': ("id === scene && time === at", "id === scene && time === at && at !== 4820", 'PATTERN_IOS_GA_R2_4820'),
    'ignore-quiet': ('|| policy.quietMode', '', 'EMIT_IOS_GA_T28_0_E1_V1_Q1'),
    'ignore-vibration': ('|| !policy.vibrationEnabled', '', 'EMIT_IOS_GA_T28_0_E1_V0_Q0'),
    'ignore-disabled': ('!policy.enabled ||', '', 'EMIT_IOS_GA_T28_0_E0_V1_Q0'),
    'selection-impact': ("if (pattern.ios === 'selection') await Haptics.selectionAsync();", "if (pattern.ios === 'selection') await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);", 'EMIT_IOS_GA_T30_0_E1_V1_Q0'),
    'deferred-disabled': ("if (!policy.enabled || !policy.vibrationEnabled || policy.quietMode) return;",
                          "if (!policy.enabled) { setTimeout(() => Haptics.selectionAsync(), 1); return; } if (!policy.vibrationEnabled || policy.quietMode) return;",
                          'EMIT_IOS_GA_T28_0_E0_V1_Q0'),
    'double-delayed': ("else if (pattern.ios === 'impactOccurred(.light)')\n      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);",
                       "else if (pattern.ios === 'impactOccurred(.light)') { await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); setTimeout(() => Haptics.selectionAsync(), 1); }",
                       'EMIT_IOS_GA_T28_0_E1_V1_Q0'),
}


def execute(runtime, subject, mutation=None):
    mobile = runtime / 'mobile'
    with tempfile.TemporaryDirectory(prefix='otdacha-151-') as temp:
        root = Path(temp)
        (root / 'node_modules').symlink_to(mobile / 'node_modules', target_is_directory=True)
        shutil.copy2(mobile / 'jest.config.js', root / 'jest.config.js')
        shutil.copy2(mobile / 'jest.setup.ts', root / 'jest.setup.ts')
        shutil.copy2(mobile / 'package.json', root / 'package.json')
        target = root / 'src/lib/otdacha'
        if subject != HERE / 'model.js':
            shutil.copytree(subject.parent, target, ignore=shutil.ignore_patterns('*.test.*', '__tests__'))
        else:
            target.mkdir(parents=True)
        data = subject.read_text()
        if mutation:
            old, new = mutation
            if data.count(old) != 1:
                raise RuntimeError('MUTANT_ANCHOR_NIE_UNIKALEN')
            data = data.replace(old, new)
        (target / ('index' + subject.suffix)).write_text(data)
        shutil.copy2(HERE / 'haptics.json', root / 'oracle.json')
        shutil.copy2(HERE / 'otdacha.test.js', target / 'otdacha.test.js')
        out = root / 'results.json'
        cmd = [str(mobile / 'node_modules/.bin/jest'), '--ci', '--runInBand', '--silent',
               '--config', str(root / 'jest.config.js'), '--runTestsByPath', str(target / 'otdacha.test.js'),
               '--json', '--outputFile', str(out)]
        p = subprocess.run(cmd, cwd=root, capture_output=True, text=True, timeout=120,
                           env={**os.environ, 'NODE_ENV': 'test'})
        if not out.exists():
            raise RuntimeError(f'JEST_NIE_VYPOLNEN rc={p.returncode}: {p.stderr[-1500:]}')
        results = json.loads(out.read_text())
        tests = results.get('testResults', [])
        if not tests or not tests[0].get('assertionResults'):
            raise RuntimeError(f'JEST_PUSTOJ rc={p.returncode}: {p.stderr[-1500:]}')
        failures = {row['fullName'].split(' ')[-1] for suite in tests for row in suite['assertionResults']
                    if row['status'] != 'passed'}
        total = sum(len(suite['assertionResults']) for suite in tests)
        return p.returncode, total, failures


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--model', action='store_true')
    parser.add_argument('--stabs', action='store_true')
    parser.add_argument('--repo', type=Path)
    parser.add_argument('--runtime', type=Path)
    args = parser.parse_args()
    if args.model and args.repo or args.stabs and args.repo:
        parser.error('choose model/stabs or repo')
    runtime = args.runtime or args.repo or (Path(os.environ['MOB_151_RUNTIME']) if os.environ.get('MOB_151_RUNTIME') else None)
    if runtime is None and not (args.model or args.stabs):
        print('SUBJECT_ABSENT: mobile/src/lib/otdacha/index.ts')
        return 1
    if runtime is None or not (runtime / 'mobile/node_modules/.bin/jest').is_file():
        print('INFRASTRUCTURE: --runtime R or --repo R with installed mobile/node_modules is required', file=sys.stderr)
        return 2
    # Pin the real product copy of the designer's archive before importing any subject.
    design = runtime / 'docs/ux/04_Gespraech_D24/motion/haptics.json'
    if not design.is_file() or hashlib.sha256(design.read_bytes()).hexdigest() != DESIGN_SHA256:
        print('ORACLE_DESIGN_DRIFT', file=sys.stderr)
        return 2
    original = json.loads(design.read_text())
    oracle = json.loads((HERE / 'haptics.json').read_text())['haptics']
    if [[r['scene'], r['at'], r['ios'], r['android']] for r in original['haptics']] != oracle:
        print('ORACLE_DESIGN_DRIFT', file=sys.stderr)
        return 2
    subject = args.repo / SUBJECT if args.repo else HERE / 'model.js'
    if not subject.is_file():
        print(f'SUBJECT_ABSENT: {subject}')
        return 1
    if args.repo:
        if not (args.repo / 'mobile/package.json').is_file() or not (args.repo / 'mobile/package-lock.json').is_file():
            print('DEPENDENCY_ABSENT')
            return 1
        package = json.loads((args.repo / 'mobile/package.json').read_text())
        lock = json.loads((args.repo / 'mobile/package-lock.json').read_text())
        if 'expo-haptics' not in package.get('dependencies', {}) or 'node_modules/expo-haptics' not in lock.get('packages', {}):
            print('DEPENDENCY_ABSENT')
            return 1
    try:
        code, total, failures = execute(runtime, subject)
        if args.stabs:
            if code != 0 or failures:
                print('HONEST_CONTROL_RED', total, sorted(failures)); return 2
            for label, (old, new, witness) in STABS.items():
                code, n, failed = execute(runtime, subject, (old, new))
                if code == 0 or witness not in failed or n != total:
                    print('STAB_UZHE_ZELEN', label, witness, sorted(failed)); return 1
                print('STAB', label, 'KRASEN', witness)
            print('SVJAZI', len(STABS), 'CASE', total)
            return 0
        for name in sorted(failures):
            print('KRASNO', name)
        print('CASE', total, 'GREEN', total - len(failures), 'RED', len(failures))
        return 0 if code == 0 and not failures else 1
    except (RuntimeError, subprocess.TimeoutExpired) as exc:
        print('INFRASTRUCTURE:', exc, file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
