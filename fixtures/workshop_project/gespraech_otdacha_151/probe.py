#!/usr/bin/env python3
"""External oracle for the 151 haptic seam; Jest exercises the actual product preset."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
SUBJECT = 'mobile/src/lib/otdacha/index.ts'
DESIGN_SHA256 = '02fc041ab9d482a10571a096d0175cc8a6c60205bfc168e06fc1de07515debbf'
STABS = {
    'ios-only': ("policy.platform === 'android'", "policy.platform === 'never'", 'EMIT_ANDROID_GA_T28_0_E1_V1_Q0'),
    'android-only': ("policy.platform === 'ios'", "policy.platform === 'never'", 'EMIT_IOS_GA_T28_0_E1_V1_Q0'),
    'weak-long': ("'impactOccurred(.medium)'", "'impactOccurred(.light)'", 'EMIT_IOS_GA_T35_500_E1_V1_Q0'),
    'early-long': ("const pattern = patternFor(scene, at);", "const pattern = patternFor(scene, scene === 'GA-T35' ? 500 : at);", 'ABSENT_IOS_GA_T35_499'),
    'late-r2': ("id === scene && time === at", "id === scene && time === at && at !== 4820", 'PATTERN_IOS_GA_R2_4820'),
    'ignore-quiet': ("policy.quietMode !== false", "false", 'EMIT_IOS_GA_T28_0_E1_V1_Q1'),
    'ignore-vibration': ("policy.vibrationEnabled !== true", "false", 'EMIT_IOS_GA_T28_0_E1_V0_Q0'),
    'ignore-disabled': ("policy.enabled !== true", "false", 'EMIT_IOS_GA_T28_0_E0_V1_Q0'),
    'selection-impact': ("if (pattern.ios === 'selection') await Haptics.selectionAsync();", "if (pattern.ios === 'selection') await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);", 'EMIT_IOS_GA_T30_0_E1_V1_Q0'),
    'deferred-disabled': ("if (policy.enabled !== true || policy.vibrationEnabled !== true || policy.quietMode !== false) return;",
                          "if (policy.enabled !== true) { setTimeout(() => Haptics.selectionAsync(), 1); return; } if (policy.vibrationEnabled !== true || policy.quietMode !== false) return;",
                          'EMIT_IOS_GA_T28_0_E0_V1_Q0'),
    'double-delayed': ("else if (pattern.ios === 'impactOccurred(.light)')\n      await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);",
                       "else if (pattern.ios === 'impactOccurred(.light)') { await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); setTimeout(() => Haptics.selectionAsync(), 1); }",
                       'EMIT_IOS_GA_T28_0_E1_V1_Q0'),
    'threshold': ("id === scene && time === at", "id === scene && time <= at", 'ABSENT_IOS_GA_T28_1'),
    'oracle-cache': ("const rows = require('../../../oracle.json').haptics;", "const rows = require('../../../oracle.json').haptics; rows.splice(0);", 'PATTERN_IOS_GA_T28_0'),
    'global-test': ("module.exports = { patternFor, playHaptic };", "globalThis.test = (n, f) => {}; module.exports = { patternFor: () => null, playHaptic: async () => {} };", 'PATTERN_IOS_GA_T28_0'),
    'no-await': ("await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);", "void Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});", 'SETTLES_AFTER_SDK_IOS_GA_T28_0'),
    'swallow': ("await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);", "try { await Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light); } catch (_) {}", 'REJECTS_AFTER_SDK_IOS_GA_T28_0'),
}


def case_matrix(oracle):
    rows, absent, flags, settlements = [], [], [], []
    expected = {'PRODUCT_MODULE_RESOLUTION'}
    times_by_scene = {}
    for scene, at, ip, ap in oracle:
        times_by_scene.setdefault(scene, set()).add(at)
        for platform in ('ios', 'android'):
            name = f'{platform.upper()}_{scene.replace("-", "_")}_{at}'
            rows.append(dict(scene=scene, at=at, iosPattern=ip, androidPattern=ap, platform=platform, name=name))
            expected.add('PATTERN_' + name)
            for e in (0, 1):
                for v in (0, 1):
                    for q in (0, 1):
                        expected.add(f'EMIT_{name}_E{e}_V{v}_Q{q}')
    for scene, times in times_by_scene.items():
        ordered = sorted(times)
        candidates = {ordered[0] - 1, ordered[-1] + 1}
        for at in ordered:
            candidates.update((at - 1, at + 1, at + 0.5))
        for a, b in zip(ordered, ordered[1:]):
            candidates.add((a + b) / 2)
        for at in sorted(candidates - times):
            marker = str(at).replace('-', 'm').replace('.', 'p')
            for platform in ('ios', 'android'):
                name = f'{platform.upper()}_{scene.replace("-", "_")}_{marker}'
                absent.append(dict(scene=scene, at=at, platform=platform, name=name))
                expected.add('ABSENT_' + name)
    for scene in ('GA-UNKNOWN', ''):
        for platform in ('ios', 'android'):
            name = f'{platform.upper()}_{scene.replace("-", "_") or "EMPTY"}_0'
            absent.append(dict(scene=scene, at=0, platform=platform, name=name))
            expected.add('ABSENT_' + name)
    for platform in ('ios', 'android'):
        scene, at = oracle[0][:2]
        name = f'{platform.upper()}_{scene.replace("-", "_")}_{at}'
        flags.append(dict(scene=scene, at=at, platform=platform, name=name))
        for flag in ('enabled', 'vibrationEnabled', 'quietMode'):
            for state in ('MISSING', 'NULL'):
                expected.add(f'UNKNOWN_FLAG_{name}_{flag}_{state}')
    for method, pattern, platform in (('impactAsync', 'impactOccurred(.light)', 'ios'),
                                       ('selectionAsync', 'selection', 'ios'),
                                       ('notificationAsync', 'notificationOccurred(.warning)', 'ios'),
                                       ('performAndroidHapticsAsync', 'VIRTUAL_KEY', 'android')):
        scene, at = next((row[0], row[1]) for row in oracle if row[2 if platform == 'ios' else 3] == pattern)
        name = f'{platform.upper()}_{scene.replace("-", "_")}_{at}'
        settlements.append(dict(scene=scene, at=at, platform=platform, method=method, name=name))
        expected.update((f'SETTLES_AFTER_SDK_{name}', f'REJECTS_AFTER_SDK_{name}'))
    return dict(rows=rows, absent=absent, flags=flags, settlements=settlements), expected


def dependency_status(repo, runtime):
    mobile = repo / 'mobile'
    if not (mobile / 'package.json').is_file() or not (mobile / 'package-lock.json').is_file():
        return False
    package = json.loads((mobile / 'package.json').read_text())
    lock = json.loads((mobile / 'package-lock.json').read_text())
    bundled = json.loads((runtime / 'mobile/node_modules/expo/bundledNativeModules.json').read_text())['expo-haptics']
    declared = package.get('dependencies', {}).get('expo-haptics')
    record = lock.get('packages', {}).get('node_modules/expo-haptics', {})
    installed = mobile / 'node_modules/expo-haptics/package.json'
    if declared != bundled or not installed.is_file():
        return False
    version = record.get('version', '')
    minimum = re.fullmatch(r'~(\d+)\.(\d+)\.(\d+)', bundled)
    parsed = re.fullmatch(r'(\d+)\.(\d+)\.(\d+)', version)
    if not minimum or not parsed:
        return False
    lo, actual = tuple(map(int, minimum.groups())), tuple(map(int, parsed.groups()))
    return (actual[:2] == lo[:2] and actual >= lo
            and record.get('resolved', '').startswith('https://') and bool(record.get('integrity'))
            and json.loads(installed.read_text()).get('version') == version)



def dependency_stab(runtime):
    """Exercise the same product preflight with conforming and fake metadata."""
    with tempfile.TemporaryDirectory(prefix='otdacha-151-dependency-') as temp:
        root = Path(temp)
        mobile = root / 'mobile'
        installed = mobile / 'node_modules/expo-haptics'
        installed.mkdir(parents=True)
        bundled = json.loads((runtime / 'mobile/node_modules/expo/bundledNativeModules.json').read_text())['expo-haptics']
        version = bundled[1:]
        package = {'dependencies': {'expo-haptics': bundled}}
        record = {'version': version, 'resolved': 'https://registry.npmjs.org/expo-haptics/-/expo-haptics-' + version + '.tgz',
                  'integrity': 'sha512-control'}
        lock = {'packages': {'node_modules/expo-haptics': record}}
        (mobile / 'package.json').write_text(json.dumps(package))
        (mobile / 'package-lock.json').write_text(json.dumps(lock))
        (installed / 'package.json').write_text(json.dumps({'version': version}))
        if not dependency_status(root, runtime):
            raise RuntimeError('DEPENDENCY_HONEST_CONTROL_RED')
        package['dependencies']['expo-haptics'] = '0.0.1-not-expo'
        record['version'] = '0.0.1-not-expo'
        (installed / 'package.json').write_text(json.dumps({'version': '0.0.1-not-expo'}))
        (mobile / 'package.json').write_text(json.dumps(package))
        (mobile / 'package-lock.json').write_text(json.dumps(lock))
        return not dependency_status(root, runtime)

def execute(runtime, subject, matrix, expected, mutation=None, product_layout=False):
    mobile = runtime / 'mobile'
    with tempfile.TemporaryDirectory(prefix='otdacha-151-') as temp:
        root = Path(temp)
        (root / 'node_modules').symlink_to(mobile / 'node_modules', target_is_directory=True)
        for filename in ('jest.config.js', 'jest.setup.ts', 'package.json'):
            shutil.copy2(mobile / filename, root / filename)
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
        (target / ('index.ts' if product_layout else 'index' + subject.suffix)).write_text(data)
        if subject == HERE / 'model.js' and not product_layout:
            shutil.copy2(HERE / 'haptics.json', root / 'oracle.json')
        template = (HERE / 'otdacha.test.js').read_text()
        (target / 'otdacha.test.js').write_text(template.replace('__CASES_PLACEHOLDER__', json.dumps(matrix)))
        out = root / 'results.json'
        cmd = [str(mobile / 'node_modules/.bin/jest'), '--ci', '--runInBand', '--silent',
               '--config', str(root / 'jest.config.js'), '--runTestsByPath', str(target / 'otdacha.test.js'),
               '--json', '--outputFile', str(out)]
        env = {**os.environ, 'NODE_ENV': 'test', 'EXPO_PUBLIC_API_MODE': 'production'}
        p = subprocess.run(cmd, cwd=root, capture_output=True, text=True, timeout=120, env=env)
        if not out.exists():
            raise RuntimeError(f'JEST_NIE_VYPOLNEN rc={p.returncode}: {p.stderr[-1500:]}')
        results = json.loads(out.read_text())
        assertions = [row for suite in results.get('testResults', []) for row in suite.get('assertionResults', [])]
        names = [row['fullName'].split(' ')[-1] for row in assertions]
        failures = {name for name, row in zip(names, assertions) if row['status'] != 'passed'}
        if len(names) != len(expected) or set(names) != expected or len(names) != len(set(names)):
            return 1, len(names), failures | (expected - set(names)), False
        return p.returncode, len(names), failures, True


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
    design = runtime / 'docs/ux/04_Gespraech_D24/motion/haptics.json'
    if not design.is_file() or hashlib.sha256(design.read_bytes()).hexdigest() != DESIGN_SHA256:
        print('ORACLE_DESIGN_DRIFT', file=sys.stderr)
        return 2
    original = json.loads(design.read_text())
    oracle = json.loads((HERE / 'haptics.json').read_text())['haptics']
    if [[r['scene'], r['at'], r['ios'], r['android']] for r in original['haptics']] != oracle or not oracle:
        print('ORACLE_DESIGN_DRIFT', file=sys.stderr)
        return 2
    matrix, expected = case_matrix(oracle)
    subject = args.repo / SUBJECT if args.repo else HERE / 'model.js'
    if not subject.is_file():
        print(f'SUBJECT_ABSENT: {subject}')
        return 1
    try:
        if args.repo and not dependency_status(args.repo, runtime):
            print('DEPENDENCY_ABSENT')
            return 1
        code, total, failures, complete = execute(runtime, subject, matrix, expected)
        if args.stabs:
            if code != 0 or failures or not complete:
                print('HONEST_CONTROL_RED', total, sorted(failures)); return 2
            for label, (old, new, witness) in STABS.items():
                mutant_code, n, failed, full = execute(runtime, subject, matrix, expected, (old, new))
                if mutant_code == 0 or witness not in failed or not full:
                    print('STAB_UZHE_ZELEN', label, witness, sorted(failed)); return 1
                print('STAB', label, 'KRASEN', witness)
            mutant_code, n, failed, full = execute(runtime, subject, matrix, expected, product_layout=True)
            if mutant_code == 0 or 'PRODUCT_MODULE_RESOLUTION' not in failed or not full:
                print('STAB_UZHE_ZELEN', 'model-in-product', 'PRODUCT_MODULE_RESOLUTION', sorted(failed)); return 1
            print('STAB model-in-product KRASEN PRODUCT_MODULE_RESOLUTION')
            if not dependency_stab(runtime):
                print('STAB_UZHE_ZELEN fake-dependency DEPENDENCY_ABSENT'); return 1
            print('STAB fake-dependency KRASEN DEPENDENCY_ABSENT')
            print('SVJAZI', len(STABS) + 2, 'CASE', total)
            return 0
        for name in sorted(failures):
            print('KRASNO', name)
        if not complete:
            print('CASE_SET_MISMATCH expected', len(expected), 'actual', total)
        print('CASE', total, 'GREEN', total - len(failures), 'RED', len(failures))
        return 0 if code == 0 and not failures and complete else 1
    except (RuntimeError, subprocess.TimeoutExpired, KeyError, ValueError) as exc:
        print('INFRASTRUCTURE:', exc, file=sys.stderr)
        return 2


if __name__ == '__main__':
    sys.exit(main())
